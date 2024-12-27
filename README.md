# tplug - Termux Plugin Manager

`tplug` is a command-line tool designed to manage Termux plugins specifically for use with termux-services, providing an easy way to install, remove, and manage background services in Termux. It simplifies the process of adding, installing, and configuring plugins from both local directories and remote repositories, ensuring seamless integration with Termux’s service management system.

---

## Table of Contents

1. [Requirements](#requirements)
2. [Installation](#installation)
3. [Usage](#usage)
    - [Commands](#commands)
    - [Environment Variables](#environment-variables)
4. [Dependencies](#dependencies)
5. [Troubleshooting](#troubleshooting)
6. [License](#license)

---

## Requirements

Ensure that the following dependencies are installed on your Termux environment:

- `git`

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

3. **`list-plugins`**  
   List all installed plugins.
   ```bash
   tplug list-plugins
   ```

4. **`list-services`**  
   List all installed services.
   ```bash
   tplug list-services
   ``

5. **`list-available`**  
   List all available plugins from the termux-plugins repository.
   ```bash
   tplug list-available
   ```

6. **`logs <service_name>`**  
   View logs for a service.
   ```bash
   tplug logs <service_name>
   ```

7. **`remove <service_name> [--purge]`**  
   Remove a service. The `--purge` option will delete the services's logs.
   ```bash
   tplug remove <service_name>
   tplug remove <service_name> --purge
   ```

8. **`remove-plugin <plugin_name>`**  
   Remove a plugin.
   ```bash
   tplug remove-plugin <plugin_name>
   ```


9. **`--help`**  
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
