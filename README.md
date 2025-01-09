# tplug - Termux Plugin Manager

`tplug` is a command-line tool designed to simplify and organize the management of **termux-services** and **custom scripts**, simplifying the process of adding, installing (from remote repositories), removing, and managing these services, as well as running and removing custom scripts in Termux. The tool ensures seamless integration with Termux’s service management system and provides additional functionality for executing local scripts.

The tool allows you to:

- Install plugins from the repository from [Termux Plugin Repository](https://github.com/dev-diaries41/termux-plugins.git). You can override with ENV, see [Environment Variables](#environment-variables)
- Create new **termux-services** by adding **plugin-services** from a local directory or installing from a repository.
- List and remove **plugins** and **termux-services**.
- View logs for **termux-services**.
- Run **plugin-scripts** from a local directory.
- Customize **plugin** GitHub repositories through an environment variable.

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
   cp termux-plugin-cli/tplug.sh ~/../usr/bin/tplug && chmod 755 ~/../usr/bin/tplug
   ```

---

## Usage

The general syntax for `tplug` is:

```bash
tplug <command> [options]
```

### Commands

1. **`add <plugin_name>`**  
   Create a new termux-service by adding a plugin-service from a local directory.
   ```bash
   tplug add <plugin_name>
   ```

2. **`run <script_name> [args]`**  
   Run plugin-scripts from a local directory. For security, scripts must be made executable instead of being sourced.  
   Example:
   ```bash
   tplug run <script_name> [args]
   ```
   Here, `<script_name>` refers to the name of the directory in the scripts directory that has the corresponding `run` file (e.g., `~/.plugins/scripts/myscript/run`).

3. **`install [<name> | -a] [-s | -r]`**  
   Install plugin-services or plugin-scripts from the repository.
   - `<name>`: Install a specific plugin-service or plugin-script.
   - `-a`: Install all plugins (requires `-s` or `-r`).
   - `-s`: Install plugin-services.
   - `-r`: Install plugin-scripts.

   Examples:
   ```bash
   tplug install my-plugin
   tplug install -a -s
   ```

4. **`logs [-c] <service_name>`**  
   View logs for a termux-service. Use the `-c` flag to clear logs.
   ```bash
   tplug logs <service_name>
   tplug logs -c <service_name>
   ```

5. **`list [-S | -s | -r | -a]`**  
   List items (plugin-services, plugin-scripts, termux-services, or available plugin-services/scripts in the repository).
   - `-S`: List installed plugin-services.
   - `-s`: List installed termux-services.
   - `-r`: List installed plugin-scripts.
   - `-a`: List available plugin-services or plugin-scripts in the repository.

   Use `-a -S` for plugin-services or `-a -r` for plugin-scripts.

   Examples:
   ```bash
   tplug list -S
   tplug list -a -r
   ```

6. **`remove <item_name> [-s | -S | -r] [-p]`**  
   Remove a termux-service, plugin-service, or plugin-script.
   - `<item_name>`: Name of the service, plugin-service, or plugin-script to remove.
   - `-s`: Remove a termux-service.
   - `-S`: Remove a plugin-service.
   - `-r`: Remove a plugin-script.
   - `-p`: Purge logs when removing the service (only applicable to termux-services).

   Examples:
   ```bash
   tplug remove my-service -s
   tplug remove my-plugin -S
   tplug remove my-script -r
   ```

7. **`--help`**  
   Show the help message.
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

- **Missing `plugin.txt` file**:  
  If the plugin doesn't contain a `plugin.txt` file with dependencies, the tool will skip dependency installation.

- **Permission errors**:  
  Ensure that you have appropriate permissions for installing plugins and accessing the required directories.