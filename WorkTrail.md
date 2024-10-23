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

- **Recommended Action:**
  - Review recent changes related to unordered map optimizations.
  - Consider reverting the optimization to identify if it resolves the build issue.

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
./do_cmake.sh \
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
ninja vstart-base cephfs cython_cephfs cython_rbd
```

**Notes:**

- `ninja` is a small build system with a focus on speed.
- The specified targets (`vstart-base`, `cephfs`, `cython_cephfs`, `cython_rbd`) are built incrementally based on changes.

### 4. Set Up the Test Cluster

Initialize and start the test cluster with the following command:

```bash
../src/vstart.sh --debug --new -x --localhost --bluestore --without-dashboard
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
./bin/ceph -s
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