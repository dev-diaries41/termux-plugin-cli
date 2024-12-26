# tplug - Termux Plugin Manager

`tplug` is a command-line tool designed to manage plugins for Termux, providing easy installation, removal, and management of Termux plugins. It helps streamline the process of adding, installing, and managing plugins from both local directories and remote repositories.

---

## Table of Contents

1. [Requirements](#requirements)
2. [Features](#features)
3. [Installation](#installation)
4. [Usage](#usage)
    - [Commands](#commands)
    - [Environment Variables](#environment-variables)
5. [Dependencies](#dependencies)
6. [Troubleshooting](#troubleshooting)
7. [License](#license)

---

## Requirements

Ensure that the following dependencies are installed on your Termux environment:

- `git`

---

## Features

- **Add plugins from local directories**  
- **Install plugins from a GitHub repository**  
- **List installed plugins**  
- **Remove plugins**  
- **Remove plugin logs (optional)**  
- **Manage dependencies listed in `plugin.yml` files**

---

## Installation

You can download and use `tplug` by following these steps:

1. Clone this repository or download the script to your Termux environment.
2. Set the executable permission for the script:
   ```bash
   chmod +x tplug
   ```
3. Move it to a directory included in your `PATH` (e.g., `/usr/bin/`).

---

## Usage

The general syntax for `tplug` is:

```bash
tplug <command> [options]
```

### Commands

1. **`add <service_name>`**  
   Add a plugin from the local directory.
   ```bash
   tplug add <service_name>
   ```

2. **`install [--all | <name>]`**  
   Install plugins from the repository. Use `--all` to install all plugins or specify a plugin name.
   ```bash
   tplug install --all
   tplug install <plugin_name>
   ```

3. **`list-installed`**  
   List all installed plugins.
   ```bash
   tplug list-installed
   ```

4. **`remove <service_name> [--purge]`**  
   Remove a plugin. The `--purge` option will delete the plugin's logs and other associated files.
   ```bash
   tplug remove <service_name>
   tplug remove <service_name> --purge
   ```

5. **`--help`**  
   Show the help message and usage details.
   ```bash
   tplug --help
   ```

### Environment Variables

- **`TERMUX_PLUGINS_REPO_URL`**:  
  You can override the default plugin repository URL by setting this environment variable to the desired URL.
  
  Example:
  ```bash
  export TERMUX_PLUGINS_REPO_URL="https://github.com/your/custom-repo.git"
  ```

---


## Dependencies

When installing plugins from local directories, the tool will automatically read the `plugin.yml` file and install any listed dependencies.

---

## Troubleshooting

- **Missing `plugin.yml` file**:  
  If the plugin doesn't contain a `plugin.yml` file with dependencies, the tool will skip dependency installation.
  
- **Permission errors**:  
  Ensure that you have appropriate permissions for installing plugins and accessing the required directories.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
