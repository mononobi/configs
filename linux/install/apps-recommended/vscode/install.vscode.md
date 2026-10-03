# Visual Studio Code (VSCode)

## Installation

### APT Installation (Recommended)

1. Go to the [Visual Studio Code Download page](https://code.visualstudio.com/Download) and
   download the latest `.deb` version.
2. Execute the following command in the directory where the file was downloaded. This process
   will also add the repository and signing key so that VSCode will be updated automatically
   through standard OS updates:

```bash
sudo apt install ./DOWNLOADED_FILE.deb
```

### Snap Installation (Not Recommended)

> **WARNING**: Installing via Snap is not recommended as some extensions may not work
> correctly.

To install using Snap, run:

```bash
sudo snap install code --classic --channel=latest/stable
```

Before installing, it is always a good practice to check for the latest available channel:

```bash
snap info code
```

## Recommended Extensions

- **Darcula Theme** (`rokoroku.vscode-theme-darcula`)
- **ENV** (`IronGeek.vscode-env`)
- **GitLab Workflow** (`GitLab.gitlab-workflow`)
- **GitLens - Git supercharged** (`eamodio.gitlens`)
- **IntelliCode** (`VisualStudioExptTeam.vscodeintellicode`)
- **npm Intellisense** (`christian-kohler.npm-intellisense`)
- **Path Intellisense** (`christian-kohler.path-intellisense`)
- **Terminal** (`formulahendry.terminal`)
- **vscode-pdf** (`tomoki1207.pdf`)

## Troubleshooting

### GitLab Workflow Login Issue

If the 'GitLab Workflow' extension is not logging into GitLab after removing a personal access
token from Ubuntu passwords or after reinstalling the OS, you can fix it by clearing its cached
entry.

1. Open the VSCode general storage SQLite database file located at:
   `~/.config/Code/User/globalStorage/state.vscdb`

2. In the database, execute the following SQL query and save the changes:

```sql
delete from ItemTable
where key = 'GitLab.gitlab-workflow'
```

3. You can now log in with your personal access token again via the GitLab Workflow extension.
