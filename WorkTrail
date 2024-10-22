
---

## **10-22-24**

### **Latest Issues**

- **Build Failure:**
  - Encountered a build failure with the following error:
    ```
    strncpy(m_thread_name, Thread::get_thread_name().data(), 16);
    warning: ‘char* strncpy(char*, const char*, size_t)’ specified bound 16 equals destination size [-Wstringop-truncation]
    In constructor ‘ceph::logging::Entry::Entry(short int, short int)’, inlined from ‘ceph::logging::MutableEntry::MutableEntry(short int, short int)’ at /home/yejordan/ceph/src/log/Entry.h:64:52, inlined from ‘void Monitor::probe_timeout(int)’ at /home/yejordan/ceph/src/mon/Monitor.cc:1884:3: /home/yejordan/ceph/src/log/Entry.h:35:12:
    ```
    - **Summary:** The `strncpy()` function is raising a warning due to the specified bound being exactly equal to the destination size (16), which can lead to truncation.
    - **Result:** The build was stopped due to this issue: `ninja: build stopped: subcommand failed.`



## **10-12-24**

### **Fixed Issues**

- **Command Execution:**
  - Resolved issues with commands not working on my end.
  - The remote server provided by Ceph was malfunctioning.
  - Utilized `sudo` to execute the necessary commands successfully.

- **File Permissions:**
  - Encountered multiple file permission issues when running commands.
  - **Note:** `chmod` and `chown` commands were ineffective in resolving these issues.

### **Pending Tasks**

- **Incremental Builds:**
  - To be tested as it currently does not seem to work.

### **Setup Instructions**

#### **1. Install `ccache` (If Needed)**

```bash
sudo apt update
sudo apt install ccache
```

#### **2. Configure CMake with `ccache` to Optimize Build Time**

```bash
sudo ./do_cmake.sh \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_C_COMPILER_LAUNCHER=ccache \
  -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
```

#### **3. Run Ninja Build Incrementally and Efficiently**

*Ensure you are in the build directory first:*

```bash
cd build
sudo ninja vstart-base cephfs cython_cephfs cython_rbd
```

#### **4. Set Up the Test Cluster as Usual**

```bash
sudo RGW=0 MDS=0 ../src/vstart.sh --debug --new -x --localhost --bluestore --without-dashboard
```

#### **5. Verify the Setup**

```bash
sudo ./bin/ceph -s
```

### **Collaboration Guidelines**

#### **After Rewriting History (Rebasing)**

*Perform the following **only** after rewriting history (rebasing):*

```bash
git fetch <Jun's fork>
git reset --hard <Jun's fork>/<project branch name>
```

#### **Otherwise**

*To incorporate your project mates' changes without overwriting your commits:*

```bash
git fetch <Jun's fork>
git pull <Jun's fork> <branch name> --rebase
```



---

## **General Troubleshooting**

### **How to Fix All at Once: resetting all changes and syncing your local environment with the remote branch and submodules**
> **Warning:** <span style="color:red">This process will remove all your changes (committed, uncommitted, staged, unstaged, etc.). Make sure to back up any important work before proceeding.</span>

1. **Reset the Repository and Submodules:**

   ```bash
   git reset --hard HEAD
   git submodule foreach --recursive git reset --hard
   ```


2. **Clean Untracked Files:**
   To clean any untracked files or directories (be cautious, as this will delete them):

   ```bash
   git clean -fdx
   git submodule foreach --recursive git clean -fdx
   ```

3. **Update Submodules:**
   Ensure all submodules are correctly updated:

   ```bash
   git submodule update --init --recursive
   ```

4. **Fetch and Pull the Latest:**
   Finally, ensure all remote changes are in sync with your local repository:

   ```bash
   git fetch <Jun's fork>
   git pull <Jun's fork> <branch name> --rebase
   ```

---
