# **Project Documentation For Ceph**

## Table of Contents

1. [Introduction](#introduction)
2. [Latest Updates](#latest-updates)
   - [Latest Issues (10-22-24)](#latest-issues-10-22-24)
3. [Fixed Issues](#fixed-issues)
   - [Fixed Issues (10-12-24)](#fixed-issues-10-12-24)
4. [Pending Tasks](#pending-tasks)
5. [Setup Instructions](#setup-instructions)
   - [1. Install `ccache`](#1-install-ccache-if-needed)
   - [2. Configure CMake with `ccache`](#2-configure-cmake-with-ccache-to-optimize-build-time)
   - [3. Run Ninja Build Incrementally and Efficiently](#3-run-ninja-build-incrementally-and-efficiently)
   - [4. Set Up the Test Cluster](#4-set-up-the-test-cluster)
   - [5. Verify the Setup](#5-verify-the-setup)
6. [Collaboration Guidelines](#collaboration-guidelines)
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

Welcome to the project documentation. This guide provides comprehensive information on the latest issues, fixes, setup instructions, collaboration guidelines, and troubleshooting steps to help you navigate and contribute effectively to the project.

---

## Latest Updates

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
       |       ^~~~~
  /home/yejordan/ceph/src/mon/MgrMonitor.cc:1145:10: error: expected constructor, destructor, or type conversion before ‘(’ token
  1145 | getline(ss, rs);
       |          ^~~~
  /home/yejordan/ceph/src/mon/MgrMonitor.cc:1146:3: error: ‘mon’ does not name a type
  1146 | mon.reply_command(op, r, rs, rdata, get_last_committed());
       |       ^~~
  /home/yejordan/ceph/src/mon/MgrMonitor.cc:1147:3: error: expected unqualified-id before ‘return’
  1147 | return true;
       |       ^~~~~~
  /home/yejordan/ceph/src/mon/MgrMonitor.cc:1148:1: error: expected declaration before ‘}’ token
  1148 | }
       |       ^~~~
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

### **Incremental Builds**

- **Task Description:**
  Test the functionality of incremental builds, as current attempts do not seem to be effective.

- **Next Steps:**
  - Investigate the configuration and dependencies to ensure that incremental build settings are correctly applied.
  - Explore alternative build tools or configurations that better support incremental builds.
  - Document findings and implement necessary changes to enable efficient incremental builds.

---

## Setup Instructions

Follow the steps below to set up the development environment effectively.

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
sudo ninja vstart-base cephfs cython_cephfs cython_rbd
```

**Notes:**

- `ninja` is a small build system with a focus on speed.
- The specified targets (`vstart-base`, `cephfs`, `cython_cephfs`, `cython_rbd`) are built incrementally based on changes.

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

Effective collaboration is crucial for the success of the project. Follow the guidelines below to manage code changes and maintain a clean project history.

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

Carefully read the [SubmittingPatches.rst](https://github.com/ceph/ceph/blob/main/SubmittingPatches.rst) document for detailed guidelines on:

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
- **Ninja:** A build system focused on speed, designed to run builds as efficiently as possible.
- **CMake:** An open-source, cross-platform family of tools designed to build, test, and package software.
- **`ccache`:** A compiler cache that speeds up recompilation by caching previous compilations.
- **Submodules:** Git repositories embedded inside a parent Git repository, allowing the inclusion of external projects.

### Useful Links

- [Git Documentation](https://git-scm.com/doc)
- [CMake Documentation](https://cmake.org/documentation/)
- [Ninja Build System](https://ninja-build.org/)
- [Ceph Documentation](https://docs.ceph.com/en/latest/)
- [Ceph SubmittingPatches Guide](https://github.com/ceph/ceph/blob/main/SubmittingPatches.rst)

---