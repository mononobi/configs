# Disabling Start Menu Web Search & Bing in Windows 11

Prevent the Windows 11 Start Menu and search bar from querying Bing or opening web results
via Group Policy.

---

## Step 1: Open Group Policy Editor

1. Press `Win + R`, type `gpedit.msc`, and press `Enter` to launch the **Local Group
   Policy Editor**.

---

## Step 2: Disable Web Search Policies

Navigate to:

```text
Computer Configuration > Administrative Templates > Windows Components > Search
```

Double-click the following policies, set their status to **Enabled**, and click **OK**:

- **Do not allow web search**
- **Don't search the web or display web results in Search**

---

## Step 3: Disable Background Edge Pre-Launch

Navigate to:

```text
Computer Configuration > Administrative Templates > Windows Components > Microsoft Edge
```

Double-click the following policies, set their status to **Disabled**, and click **OK**:

- **Allow Microsoft Edge to pre-launch at Windows startup, when the system is idle, and
  each time Microsoft Edge is closed**
- **Allow Microsoft Edge to start and load the Start and New Tab page at Windows startup
  and each time Microsoft Edge is closed**

---

## Step 4: Apply Changes

Restart your computer if the Start Menu search behavior does not update immediately.
