# tplug - Termux Plugin Manager

`tplug` is a command-line tool designed to simplify and organise the management **termux-services** and **custom scripts**, simplifying the process of adding, installing (from remote repositories), removing, and managing these services, as well as running and removing custom scripts in Termux. The tool ensures seamless integration with Termux’s service management system and provides additional functionality for executing local scripts.

The tool allows you to:

- Create new **termux-services** by adding **plugin-services** from a local directory or installing from repo
- List and remove **plugins** and **termux-services**.
- View logs for **termux-services**.
- Run **plugin-scripts** from a local directory.
- Customize **plugin** github repositories through an environment variable.

---

### **What are Plugins?**

- **Plugin-Services**:  
  **Plugin-services** are custom Termux services that can be managed using `tplug`. They integrate with Termux's service management system, allowing you to start, stop, and manage custom background processes (i.e., services) within Termux.

- **Plugin-Scripts**:  
  **Plugin-scripts** are user-defined, executable scripts that can be run directly from the local directory.

---

### **Important Notes on Plugin-Services and Plugin-Scripts**

- All **plugin-services** must follow a specific format described in the [Termux Plugin Repository](https://github.com/dev-diaries41/termux-plugins.git).
- All **plugin-services** are stored in the `$HOME/.plugins/services` directory. To add your own **plugin-services**, use this directory for compatibility with `tplug`.
- The directory used for **plugin-scripts** is `$HOME/.plugins/scripts`. Each directory in `$HOME/.plugins/scripts` must have a `run` file that is executable to function properly.

---

## Table of Contents

1. [Requirements](#requirements)
2. [Installation](#installation)
3. [Usage](#usage)
    - [Commands](#commands)
    - [Environment Variables](#environment-variables)
4. [Dependencies](#dependencies)
5. [Troubleshooting](#troubleshooting)

---

## Requirements

Ensure that the following dependencies are installed on your Termux environment:

- `git`

---

## Installation

You can download and use `tplug` by following these steps:

1. Clone this repository or download the script to your Termux environment.

2. Move it to a directory included in your `PATH` (e.g., `/usr/bin/`) and make it executable.
   ```bash
   cp termux-plugin-cli/tplug.sh ~/../usr/bin/tplug && chmod 755  ~/../usr/bin/tplug
   ```
---

## Usage

The general syntax for `tplug` is:

```bash
tplug <command> [options]
```

### Commands

1. **`add <plugin_name>`**  
   Add a plugin from the local directory.
   ```bash
   tplug add <plugin_name>
   ```

2. **`install [--all | <name>]`**  
   Install plugins from the repository. Use `--all` to install all plugins or specify a plugin name.
   ```bash
   tplug install --all
   tplug install <plugin_name>
   ```

3. **`logs [-c] <service_name>`**  
   View logs for a service. Use the `-c` flag to clear the logs.
   ```bash
   tplug logs <service_name>
   tplug logs -c <service_name>
   ```

4. **`list [-p | -s | -a]`**  
   List installed items (plugins, services) or available plugins from the repository.
   - `-p`: List installed plugins.
   - `-s`: List installed services.
   - `-a`: List available plugins in the repository.
   ```bash
   tplug list -p
   tplug list -s
   tplug list -a
   ```

5. **`remove <item_name> [-s | -p] [-P]`**  
   Remove a service or plugin. Use `-s` to remove a service, `-p` to remove a plugin, and `-P` to purge logs when removing a service.
   ```bash
   tplug remove <item_name> -s
   tplug remove <item_name> -p
   tplug remove <item_name> -s -P
   ```

6. **`--help`**  
   Show the help message and usage details.
   ```bash
   tplug --help
   ```

7. **`run <script_name> [args]`**  
   Run scripts from a local directory. For security rather than sourcing, the scripts must be made executable. 
   ```bash
   tplug run <script_name> [args]
   ```
   "myscript" refers to the name of the directory in the scripts directory that has the correspinding run file e.g ~/.scripts/myscript/run

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