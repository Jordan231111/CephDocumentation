---

# **Project Documentation for Ceph**

## Table of Contents

1. [Introduction](#introduction)
2. [Latest Updates](#latest-updates)
   - [Latest Updates (11-15-24)](#latest-updates-11-15-24)
   - [Latest Updates (11-8-24)](#latest-updates-11-8-24)
   - [Latest Updates (11-1-24)](#latest-updates-11-1-24)
   - [Latest Issues (10-22-24)](#latest-issues-10-22-24)
3. [Fixed Issues](#fixed-issues)
   - [Fixed Issues (11-8-24)](#fixed-issues-11-8-24)
   - [Fixed Issues (10-12-24)](#fixed-issues-10-12-24)
4. [Pending Tasks](#pending-tasks)
5. [Setup Instructions](#setup-instructions)
   - [1. Install `ccache`](#1-install-ccache-if-needed)
   - [2. Configure CMake with `ccache`](#2-configure-cmake-with-ccache-to-optimize-build-time)
   - [3. Run Ninja Build Incrementally and Efficiently](#3-run-ninja-build-incrementally-and-efficiently)
   - [4. Set Up the Test Cluster](#4-set-up-the-test-cluster)
   - [5. Verify the Setup](#5-verify-the-setup)
6. [Collaboration Guidelines](#collaboration-guidelines)
   - [Working with the Ceph Issue Tracker](#working-with-the-ceph-issue-tracker)
   - [Configuring Git User Information](#configuring-git-user-information)
   - [Signing Off Commits](#signing-off-commits)
   - [Commit Message Guidelines](#commit-message-guidelines)
     - [Example Commit Message](#example-commit-message)
   - [After Rewriting History (Rebasing)](#after-rewriting-history-rebasing)
   - [Otherwise](#otherwise)
7. [General Troubleshooting](#general-troubleshooting)
   - [Resetting All Changes and Syncing with Remote](#resetting-all-changes-and-syncing-with-remote)
8. [Appendix](#appendix)
   - [Glossary](#glossary)
   - [Useful Links](#useful-links)

---

## Introduction

Welcome to the project documentation for contributing to Ceph. This guide provides comprehensive information on the latest updates, fixed issues, setup instructions, collaboration guidelines, and troubleshooting steps to help you navigate and contribute effectively to the project.

---

## Latest Updates

### Latest Updates (11-15-24)

#### **Implementing FLAG_SECURE Option in Ceph Configuration**

- **Summary of the Issue:**
  - Issue [#54580](https://tracker.ceph.com/issues/54580) in the Ceph tracker proposes adding a `FLAG_SECURE` option to the Ceph configuration. This feature aims to enhance security by allowing administrators to enforce secure communication protocols across various Ceph components.

- **Plan:**

  - **Generate Keys to Test Redaction:**

    - Generate access and secret keys to test if the redaction works.

      ```bash
      ACCESS_KEY=$(openssl rand -base64 15 | tr -d /=+ | cut -c1-20)
      SECRET_KEY=$(openssl rand -base64 30 | tr -d /=+ | cut -c1-40)
      ```

    - Set the keys using:

      ```bash
      sudo ./bin/ceph config-key set mgr/mgr/dashboard/RGW_API_ACCESS_KEY "$ACCESS_KEY"
      sudo ./bin/ceph config-key set mgr/mgr/dashboard/RGW_API_ACCESS_KEY "$ACCESS_KEY"
      ```

    - Check:

      ```bash
      sudo ./bin/ceph config-key get mgr/mgr/dashboard/RGW_API_ACCESS_KEY
      sudo ./bin/ceph config-key get mgr/mgr/dashboard/RGW_API_ACCESS_KEY
      ```

    - Set in dashboard as well:

      ```bash
      ceph dashboard set-rgw-api-access-key "$ACCESS_KEY"
      ceph dashboard set-rgw-api-secret-key "$SECRET_KEY"
      ```

    - Optionally, set up this as well to expand the tests:

      ```bash
      radosgw-admin user create \
          --uid="testuser" \
          --display-name="Test User" \
          --access-key="$ACCESS_KEY" \
          --secret-key="$SECRET_KEY"
      ```

    - Verify:

      ```bash
      radosgw-admin user info --uid="testuser"
      ```

- **Relevant Code Section:**

  - File: `/workspaces/Ceph/src/mon/KVMonitor.cc`
  - Relevant line:

    ```cpp
    else if (prefix == "config-key list" ||
    ```

- **Implementation Steps:**

  - **Define the `--include-secrets` Option:**
    - Update the command definitions to include the `include-secrets` parameter:

      ```cpp
      bool include_secrets = false;
      cmdctx->op->cmd_getval("include-secrets", include_secrets);
      ```

  - **Implement a Function to Check Sensitive Keys:**
    - Create a function to determine if a key is sensitive based on the `FLAG_SECRET` flag:

      ```cpp
      bool is_sensitive_key(const std::string& key) {
        // Example implementation
        return key_has_flag(key, FLAG_SECRET);
      }
      ```

  - **Modify the Key Listing Logic:**
    - While looping through the keys in the `config-key list`, check if the key is sensitive:

      ```cpp
      // Check if the key is sensitive during the loop
      bool is_sensitive = is_sensitive_key(iter->key());

      if (!include_secrets && is_sensitive) {
        // Redact sensitive values
        f->dump_string(iter->key().c_str(), "***********");
      }
      ```

  - **Mark Sensitive Keys Appropriately:**
    - Ensure that sensitive keys are stored with `FLAG_SECRET`.

- **Additional Notes:**

  - The goal is to prevent sensitive information from being displayed when listing configuration keys unless explicitly requested with the `--include-secrets` option.
  - Testing will involve verifying that sensitive keys are redacted by default and only displayed when the `--include-secrets` flag is used.

#### **Alternative Build Command**

- **Note on Build Process:**
  - `sudo ninja start` is an alternative to `sudo ninja vstart-base cephfs cython_cephfs cython_rbd mds` for building the necessary components incrementally and efficiently.

---

### Latest Updates (11-8-24)

#### **Understanding and Working with the Ceph Issue Tracker**

- **Learning to Navigate the Issue Tracker:**
  - Explored the Ceph issue tracker to understand how issues are managed and tracked.
  - Example issue: [Issue #42593](https://tracker.ceph.com/issues/42593).

- **Best Practices for Issue Management:**
  - **Assigning Issues:**
    - It's best practice to assign an issue to yourself when you start working on it.
    - Set the issue status to "In Progress" to indicate that it's being actively worked on.
  - **Updating Issue Status:**
    - After creating a Pull Request (PR), update the issue status to "Under Review".
  - **Choosing Issues:**
    - Started with "low-hanging fruit" issues to get accustomed to fixing simple to moderately difficult problems.
    - This approach helps in understanding professional open-source development workflows and best practices.

- **Key Learnings from the Developer Guide:**
  - **Developer Guide Reference:**
    - Many insights were gained from the [Ceph Developer Guide - Basic Workflow](https://docs.ceph.com/en/reef/dev/developer_guide/basic-workflow/).
    - Highly recommend others working on the project to pay special attention to this page.

- **Finding the Right File to Edit:**
  - **Initial Challenge:**
    - As a newcomer to Ceph, locating the correct file to edit was challenging due to the lack of specific leads in the issue description.
  - **Solution Approach:**
    - Employed a brute-force method using the search function in Visual Studio Code (VSCode).
    - Found four occurrences related to the issue and identified the correct file needing modification.
    - In this case, the task was to set a configuration option to `true` by default.

- **Creating a Pull Request:**
  - **Following Guidelines:**
    - Created a PR adhering to the guidelines outlined in the [Submitting Patches](https://github.com/ceph/ceph/blob/main/SubmittingPatches.rst) document.
    - PR link: [PR #60678](https://github.com/ceph/ceph/pull/60678).
  - **Reviewer Selection:**
    - For issues similar to the one addressed, it's advisable to assign an experienced developer, preferably someone familiar with the codebase, as a reviewer.
    - For simple issues, this may not be necessary, but adapting to different scenarios is crucial.
    - Don't hesitate to ask questions in large projects to ensure clarity.

- **Commit Message and PR Format:**
  - **Dependence on Context:**
    - The commit message and PR format depend on the nature of the issue, the number of commits, and other specific scenarios.
  - **Best Practices:**
    - Gaining experience and seeking support when necessary helps in getting it right the first time.
    - A well-crafted PR format facilitates the review process and contributes to efficient collaboration.

---

### Latest Updates (11-1-24)

#### **Resolving Merge Conflicts**

- **What I Learned:**
  During a recent pull request, I encountered merge conflicts between the `Project3` and `Main` branches. The GitHub bot automatically labeled the pull request with "need-rebase" due to these conflicts. I can also click on details in each of the GitHub checks to view the failed checks more in-depth.

- **Approach:**
  To successfully resolve the conflicts, I retained the `<<<<<<< HEAD` sections to preserve the main branch's changes while carefully integrating my own modifications. This ensured that both sets of changes were harmoniously combined.

- **Steps Taken:**
  - **Reviewed Conflict Markers:**
    - Examined each conflict marker (`<<<<<<<`, `=======`, `>>>>>>>`) to determine the appropriate changes to keep.
  - **Preserved Critical Sections:**
    - Maintained essential parts of the `HEAD` to ensure the main branch's integrity.
    - Integrated personal work without overwriting important updates from the main branch.
  - **Executed Git Commands:**

    ```bash
    git fetch main
    git pull origin main --rebase
    ```

  - **Verified Merged Code:**
    - Checked the merged code for consistency and functionality to ensure the merge was successful.

- **Expected Outcome:**
  Successfully resolve all merge conflicts, resulting in a clean and functional codebase. This allowed the merge request to be completed without delays, enabling continued development without interruptions.

- **Reflection:**
  This experience enhanced my understanding of effective conflict resolution strategies in Git. It underscored the importance of carefully managing and integrating changes from multiple sources to maintain code integrity.

---

### Latest Issues (10-22-24)

#### **Build Failure**

- **Issue Description:**
  During the build process, a failure was encountered with the following error message:

  ```cpp
  strncpy(m_thread_name, Thread::get_thread_name().data(), 16);
  warning: ‘char* strncpy(char*, const char*, size_t)’ specified bound 16 equals destination size [-Wstringop-truncation]
  In constructor ‘ceph::logging::Entry::Entry(short int, short int)’, inlined from ‘ceph::logging::MutableEntry::MutableEntry(short int, short int)’ at /home/yejordan/ceph/src/log/Entry.h:64:52, inlined from ‘void Monitor::probe_timeout(int)’ at /home/yejordan/ceph/src/mon/Monitor.cc:1884:3: /home/yejordan/ceph/src/log/Entry.h:35:12:
  ```

- **Summary:**
  The `strncpy()` function is generating a warning because the specified bound (16) is exactly equal to the destination buffer size. This can lead to potential string truncation issues.

- **Impact:**
  The build process was halted due to this warning, resulting in the following message:

  ```
  ninja: build stopped: subcommand failed.
  ```

- **Suspected Cause:**
  The issue is believed to stem from recent optimizations made to the unordered map. It may require reverting the optimization to resolve the build failure.

- **Possible Solution:**
  - Review recent changes related to unordered map optimizations.
  - Consider reverting the optimization to identify if it resolves the build issue.

---

- **Issue Description:**
  During the build process, a failure was encountered with the following error message:

  ```cpp
  [27/454] Building CXX object src/mon/CMakeFiles/mon.dir/MgrMonitor.cc.o
  FAILED: src/mon/CMakeFiles/mon.dir/MgrMonitor.cc.o
  ccache /usr/bin/g++-11 -DBOOST_ASIO_DISABLE_THREAD_KEYWORD_EXTENSION -DBOOST_ASIO_HAS_IO_URING -DBOOST_ASIO_NO_TS_EXECUTORS -DHAVE_CONFIG_H -D_FILE_OFFSET_BITS=64 -D_FORTIFY_SOURCE=2 -D_GNU_SOURCE -D_REENTRANT -D_THREAD_SAFE -D__CEPH__ -D__STDC_FORMAT_MACROS -D__linux__ -I/home/yejordan/ceph/build/src/include -I/home/yejordan/ceph/src -isystem /home/yejordan/ceph/build/boost/include -isystem /home/yejordan/ceph/build/include -isystem /home/yejordan/ceph/src/jaegertracing/opentelemetry-cpp/api/include -isystem /home/yejordan/ceph/src/jaegertracing/opentelemetry-cpp/exporters/jaeger/include -isystem /home/yejordan/ceph/src/jaegertracing/opentelemetry-cpp/ext/include -isystem /home/yejordan/ceph/src/jaegertracing/opentelemetry-cpp/sdk/include -isystem /home/yejordan/ceph/src/xxHash -isystem /home/yejordan/ceph/src/fmt/include -isystem /home/yejordan/ceph/src/rocksdb/include -isystem /home/yejordan/ceph/build/src/liburing/src/include -O2 -g -DNDEBUG -fPIC -U_FORTIFY_SOURCE -fno-builtin-malloc -fno-builtin-calloc -fno-builtin-realloc -fno-builtin-free -Wall -fno-strict-aliasing -fsigned-char -Wtype-limits -Wignored-qualifiers -Wpointer-arith -Werror=format-security -Winit-self -Wno-unknown-pragmas -Wnon-virtual-dtor -Wno-ignored-qualifiers -ftemplate-depth-1024 -Wpessimizing-move -Wredundant-move -Wstrict-null-sentinel -Woverloaded-virtual -fstack-protector-strong -fdiagnostics-color=auto -std=c++20 -MD -MT src/mon/CMakeFiles/mon.dir/MgrMonitor.cc.o -MF src/mon/CMakeFiles/mon.dir/MgrMonitor.cc.o.d -o src/mon/CMakeFiles/mon.dir/MgrMonitor.cc.o -c /home/yejordan/ceph/src/mon/MgrMonitor.cc
  /home/yejordan/ceph/src/mon/MgrMonitor.cc: In member function ‘bool MgrMonitor::preprocess_command(MonOpRequestRef)’:
  /home/yejordan/ceph/src/mon/MgrMonitor.cc:1037:18: warning: variable ‘it’ set but not used [-Wunused-but-set-variable]
  1037 | auto it = module_info_map.find(module_name);
       |                  ^~
  /home/yejordan/ceph/src/mon/MgrMonitor.cc:1036:11: warning: this ‘if’ clause does not guard... [-Wmisleading-indentation]
  1036 | if (map.get_always_on_modules().count(module_name) == 0)
       |           ^~
  /home/yejordan/ceph/src/mon/MgrMonitor.cc:1038:13: note: ...this statement, but the latter is misleadingly indented as if it were guarded by the ‘if’
  1038 | if (it != module_info_map.end()) {
       |             ^~
  /home/yejordan/ceph/src/mon/MgrMonitor.cc:1038:17: error: ‘it’ was not declared in this scope; did you mean ‘int’?
  1038 | if (it != module_info_map.end()) {
       |                 ^~
       |                 int
  /home/yejordan/ceph/src/mon/MgrMonitor.cc:1005:14: error: label ‘reply’ used but not defined
  1005 | goto reply;
       |              ^~~~~
  /home/yejordan/ceph/src/mon/MgrMonitor.cc: At global scope:
  /home/yejordan/ceph/src/mon/MgrMonitor.cc:1057:7: error: expected unqualified-id before ‘else’
  1057 | } else {
       |       ^~~~
  /home/yejordan/ceph/src/mon/MgrMonitor.cc:1084:3: error: expected declaration before ‘}’ token
  1084 | } else if (prefix == "mgr services") {
       |       ^~~~
  /home/yejordan/ceph/src/mon/MgrMonitor.cc:1084:5: error: expected unqualified-id before ‘else’
  1084 | } else if (prefix == "mgr services") {
       |       ^~~~
  /home/yejordan/ceph/src/mon/MgrMonitor.cc:1094:5: error: expected unqualified-id before ‘else’
  1094 | } else if (prefix == "mgr metadata") {
       |       ^~~~
  /home/yejordan/ceph/src/mon/MgrMonitor.cc:1123:5: error: expected unqualified-id before ‘else’
  1123 | } else if (prefix == "mgr versions") {
       |       ^~~~
  /home/yejordan/ceph/src/mon/MgrMonitor.cc:1130:5: error: expected unqualified-id before ‘else’
  1130 | } else if (prefix == "mgr count-metadata") {
       |       ^~~~
  /home/yejordan/ceph/src/mon/MgrMonitor.cc:1139:5: error: expected unqualified-id before ‘else’
  1139 | } else {
       |       ^~~~
  /home/yejordan/ceph/src/mon/MgrMonitor.cc:1143:6: error: found ‘:’ in nested-name-specifier, expected ‘::’
  1143 | reply:
       |       ^~
       |       ::
  /home/yejordan/ceph/src/mon/MgrMonitor.cc:1143:1: error: ‘reply’ does not name a type
  1143 | reply:
       | ^~~~~
  /home/yejordan/ceph/src/mon/MgrMonitor.cc:1145:10: error: expected constructor, destructor, or type conversion before ‘(’ token
  1145 | getline(ss, rs);
       |          ^~~~
  /home/yejordan/ceph/src/mon/MgrMonitor.cc:1146:3: error: ‘mon’ does not name a type
  1146 | mon.reply_command(op, r, rs, rdata, get_last_committed());
       | ^~~
  /home/yejordan/ceph/src/mon/MgrMonitor.cc:1147:3: error: expected unqualified-id before ‘return’
  1147 | return true;
       | ^~~~~~
  /home/yejordan/ceph/src/mon/MgrMonitor.cc:1148:1: error: expected declaration before ‘}’ token
  1148 | }
       | ^
  /home/yejordan/ceph/src/mon/MgrMonitor.cc: In member function ‘bool MgrMonitor::preprocess_command(MonOpRequestRef)’:
  /home/yejordan/ceph/src/mon/MgrMonitor.cc:1057:5: warning: control reaches end of non-void function [-Wreturn-type]
  1057 | } else {
       |       ^~~~
  [34/454] Building CXX object src/mon/CMakeFiles/mon.dir/ConfigMonitor.cc.o
  ninja: build stopped: subcommand failed.
  ```

- **Summary:**
  The build process failed due to multiple errors and warnings in the `MgrMonitor.cc` file. These include unused variables, misleading indentation, undeclared variables, and syntax errors.

- **Impact:**
  The build process was halted due to these errors, resulting in the following message:

  ```
  ninja: build stopped: subcommand failed.
  ```

- **Suspected Cause:**
  The issue is likely due to recent changes in the `MgrMonitor.cc` file that introduced syntax errors and logical issues.

- **Possible Solution:**
  - Review the recent changes made to the `MgrMonitor.cc` file.
  - Correct the syntax errors and ensure proper variable declarations.
  - Fix the misleading indentation and ensure all labels and variables are properly defined.
  - Rebuild the project to verify if the issues are resolved.

---

## Fixed Issues

### Fixed Issues (11-8-24)

#### **Issue #42593: Remove `osd_op_complaint_time`**

- **Issue Description:**
  - The goal was to remove the `osd_op_complaint_time` configuration option and set it to `true` by default.

- **Resolution:**
  - **File Identification:**
    - Utilized VSCode's search functionality to locate relevant occurrences.
    - Identified the correct file to edit among four appearances.
  - **Code Modification:**
    - Edited the configuration option to set it to `true` by default.
  - **Pull Request:**
    - Submitted PR [#60678](https://github.com/ceph/ceph/pull/60678) following the project's contribution guidelines.
    - Ensured the commit message and PR description adhered to best practices.

- **Notes:**
  - **Learning Experience:**
    - The process enhanced understanding of navigating a large codebase and the importance of following contribution guidelines.
  - **Collaboration:**
    - Recognized the value of involving experienced developers as reviewers for certain issues.

### Fixed Issues (10-12-24)

#### **Command Execution**

- **Issue Description:**
  Commands were failing to execute properly on the local machine.

- **Resolution:**
  - Identified that the remote server provided by Ceph was malfunctioning.
  - Utilized `sudo` to execute the necessary commands successfully, bypassing permission-related obstacles.

- **Notes:**
  - The malfunctioning remote server issue occurs occasionally and requires patience until it is auto-resolved.

#### **File Permissions**

- **Issue Description:**
  Multiple file permission errors occurred when attempting to run commands.

- **Resolution:**
  - Attempts to resolve using `chmod` and `chown` were ineffective.
  - Using `sudo` before a command fixed the immediate permission issues.

- **Notes:**
  - Running commands with `sudo` can lead to files being owned by root, causing further permission problems.
  - It's recommended to check file ownership and ensure commands are run with appropriate permissions.
  - Avoid using `sudo` with Git commands to prevent committing as root.

---

## Pending Tasks

### **Implementing FLAG_SECURE Option**

- **Task Description:**
  - Implement the `FLAG_SECURE` option in the Ceph configuration to enhance security.
  - Ensure sensitive keys are appropriately flagged and redacted when necessary.

- **Next Steps:**
  - Follow the implementation steps outlined in the Latest Updates (11-15-24).
  - Test the changes thoroughly to verify that sensitive information is protected.

### **Incremental Builds**

- **Task Description:**
  - Test the functionality of incremental builds, as current attempts do not seem to be effective.

- **Update:**
  - Discovered that `sudo ninja start` can be used as an alternative command for building components incrementally and efficiently.

- **Next Steps:**
  - Investigate if `sudo ninja start` resolves the issues with incremental builds.
  - Document findings and update build instructions accordingly.

---

## Setup Instructions

### 1. Install `ccache` (If Needed)

`ccache` is a compiler cache that speeds up recompilation by caching previous compilations and detecting when the same compilation is being done again.

```bash
sudo apt update
sudo apt install ccache
```

### 2. Configure CMake with `ccache` to Optimize Build Time

Configure the CMake build system to utilize `ccache` for both C and C++ compilers.

```bash
sudo ./do_cmake.sh \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_C_COMPILER_LAUNCHER=ccache \
  -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
```

**Explanation:**

- `-DCMAKE_BUILD_TYPE=RelWithDebInfo`: Sets the build type to release with debugging information.
- `-DCMAKE_C_COMPILER_LAUNCHER=ccache`: Uses `ccache` as the launcher for the C compiler.
- `-DCMAKE_CXX_COMPILER_LAUNCHER=ccache`: Uses `ccache` as the launcher for the C++ compiler.

### 3. Run Ninja Build Incrementally and Efficiently

Ensure you are in the build directory before initiating the build process.

```bash
cd build
sudo ninja vstart-base cephfs cython_cephfs cython_rbd mds
```

**Alternative Command:**

- As an alternative, you can use the following command to build and start the cluster:

  ```bash
  sudo ninja start
  ```

**Notes:**

- `ninja` is a small build system with a focus on speed.
- The specified targets (`vstart-base`, `cephfs`, `cython_cephfs`, `cython_rbd`, `mds`) are built incrementally based on changes.
- The `sudo ninja start` command builds and starts the cluster with default components.

### 4. Set Up the Test Cluster

Initialize and start the test cluster with the following command:

```bash
sudo ../src/vstart.sh --debug --new -x --localhost --bluestore --without-dashboard
```

**Parameters Explained:**

- `--debug`: Enables debug mode for more verbose output.
- `--new`: Starts a new cluster.
- `-x`: Excludes certain services as per configuration.
- `--localhost`: Runs the cluster on the local machine.
- `--bluestore`: Uses Bluestore as the storage backend.
- `--without-dashboard`: Omits the dashboard service.

### 5. Verify the Setup

Check the status of the Ceph cluster to ensure everything is set up correctly.

```bash
sudo ./bin/ceph -s
```

**Expected Output:**

- A summary of the Ceph cluster status, including health, number of OSDs, MONs, etc.

---

## Collaboration Guidelines

### Working with the Ceph Issue Tracker

- **Navigating the Tracker:**
  - Access the Ceph issue tracker at [tracker.ceph.com](https://tracker.ceph.com).
  - Use filters and search functionality to find issues relevant to your interests or expertise.

- **Assigning Issues:**
  - Before starting work, assign the issue to yourself to indicate ownership.
  - Update the issue status to "In Progress" to reflect active development.

- **Updating Issue Status:**
  - After submitting a Pull Request, change the issue status to "Under Review".
  - Provide a link to the PR in the issue comments for easy reference.

- **Choosing Appropriate Issues:**
  - Start with "low-hanging fruit" or beginner-friendly issues to familiarize yourself with the codebase and contribution process.
  - As you gain experience, take on more complex issues.

- **Communication and Collaboration:**
  - For complex issues, consider reaching out to experienced developers for guidance.
  - Assign appropriate reviewers to your PRs, especially those familiar with the code or module you're modifying.

- **Additional Resources:**
  - Refer to the [Ceph Developer Guide - Basic Workflow](https://docs.ceph.com/en/reef/dev/developer_guide/basic-workflow/) for detailed instructions on the development process.

### Configuring Git User Information

To avoid committing as root and ensure proper attribution, set up your Git user information:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

**Notes:**

- Replace `"Your Name"` with your actual name.
- Replace `"your.email@example.com"` with your email address associated with your GitHub account.

### Signing Off Commits

When making commits, use the `-s` flag to add a "Signed-off-by" line, certifying that you wrote the code and have the right to submit it under the project's license:

```bash
git commit -s
```

### Commit Message Guidelines

Carefully read the [Submitting Patches](https://github.com/ceph/ceph/blob/main/SubmittingPatches.rst) document for detailed guidelines on:

- Crafting informative commit messages.
- Following best practices when committing and creating pull requests.
- Understanding the project's contribution workflow.

#### Example Commit Message

Below is an example of a well-formatted commit message:

```
mon: Fix memory leak in database connection pool

This fixes a memory leak issue that occurred when the connection pool
was not properly releasing resources. The bug was traced to the
DatabaseConnectionPool class where connections were held indefinitely.

- Added proper connection closing logic in the `closeConnection` method.
- Fixed unit tests to handle the new connection closing behavior.

Fixes: http://tracker.ceph.com/issues/12345
Signed-off-by: Jordan Ye <yejordan8888@gmail.com>
Co-authored-by: Another Developer <anotherdev@example.com>
```

This commit message follows best practices by:

- **Providing a concise and descriptive title.**
- **Including a detailed description** of the changes and the problem being solved.
- **Listing specific changes made** in bullet points.
- **Linking to the issue being fixed**, e.g., `Fixes #789`.
- **Including sign-off and co-author information** for proper attribution.

---

### After Rewriting History (Rebasing)

*Use these steps **only** after rewriting history (rebasing):*

1. **Fetch from Jun's Fork:**

   ```bash
   git fetch <jun-fork>
   ```

2. **Reset Hard to Jun's Branch:**

   ```bash
   git reset --hard <jun-fork>/<project-branch-name>
   ```

**Warning:**

- This will overwrite your current branch to match Jun's fork.
- Ensure that all important changes are backed up before performing a hard reset.

### Otherwise

*To incorporate your project mates' changes without overwriting your commits:*

1. **Fetch from Jun's Fork:**

   ```bash
   git fetch <jun-fork>
   ```

2. **Pull and Rebase:**

   ```bash
   git pull <jun-fork> <branch-name> --rebase
   ```

**Explanation:**

- `--rebase` ensures that your local commits are reapplied on top of the fetched commits, maintaining a linear project history.

**Best Practices:**

- Regularly fetch and rebase to minimize merge conflicts.
- Communicate with team members when performing significant history rewrites.

---

## General Troubleshooting

### Resetting All Changes and Syncing with Remote

> **Warning:** This process will remove all your changes (committed, uncommitted, staged, unstaged, etc.). Make sure to back up any important work before proceeding.

Follow these steps to reset your repository and synchronize with the remote branch:

#### 1. Reset the Repository and Submodules

Reset your local repository to the latest commit and do the same for all submodules.

```bash
git reset --hard HEAD
git submodule foreach --recursive git reset --hard
```

#### 2. Clean Untracked Files

Remove all untracked files and directories. **Caution:** This will delete them permanently.

```bash
git clean -fdx
git submodule foreach --recursive git clean -fdx
```

**Options Explained:**

- `-f`: Force the clean operation.
- `-d`: Remove untracked directories in addition to untracked files.
- `-x`: Remove ignored files as well.

#### 3. Update Submodules

Ensure all submodules are initialized and updated to match the repository.

```bash
git submodule update --init --recursive
```

#### 4. Fetch and Pull the Latest Changes

Synchronize your local repository with the remote branch.

```bash
git fetch <jun-fork>
git pull <jun-fork> <branch-name> --rebase
```

**Notes:**

- Replace `<jun-fork>` with the actual remote name if different.
- Replace `<branch-name>` with the target branch you intend to sync with.

**Outcome:**

- Your local repository and all submodules will be reset to match the state of the remote branch, ensuring consistency across your development environment.

---

## Appendix

### Glossary

- **Ceph:** A scalable, high-performance distributed storage system.
- **VSCode:** Visual Studio Code, a popular source-code editor developed by Microsoft.
- **Issue Tracker:** A tool used by software development teams to track tasks, bugs, and feature requests.
- **Pull Request (PR):** A method of submitting contributions to a project, where the maintainer can review and merge changes.
- **Reviewer:** A person responsible for reviewing code changes before they are merged into the main codebase.
- **Ninja:** A build system focused on speed, designed to run builds as efficiently as possible.
- **CMake:** An open-source, cross-platform family of tools designed to build, test, and package software.
- **`ccache`:** A compiler cache that speeds up recompilation by caching previous compilations.
- **Submodules:** Git repositories embedded inside a parent Git repository, allowing the inclusion of external projects.

### Useful Links

- [Ceph Issue Tracker](https://tracker.ceph.com)
- [Ceph Developer Guide - Basic Workflow](https://docs.ceph.com/en/reef/dev/developer_guide/basic-workflow/)
- [Submitting Patches to Ceph](https://github.com/ceph/ceph/blob/main/SubmittingPatches.rst)
- [Git Documentation](https://git-scm.com/doc)
- [CMake Documentation](https://cmake.org/documentation/)
- [Ninja Build System](https://ninja-build.org/)
- [Ceph Documentation](https://docs.ceph.com/en/latest/)

---
