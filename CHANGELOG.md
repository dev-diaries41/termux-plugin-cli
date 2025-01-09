# Changelog

## Date: 2025-01-09

### Added:
- **add <plugin_name>**: New description added, clarifying that this command creates a termux-service by adding a plugin-service from a local directory.
- **run <script_name> [args]**: New command added for running plugin-scripts from a local directory.
- **install [<name> | -a] [-s | -r]**: New expanded options:
  - **-a** option to install all plugins with the option of `-s` or `-r` for service/script selection.
  - **-s** option for installing plugin-services.
  - **-r** option for installing plugin-scripts.
- **logs [-c] <service_name>**: Added the **[-c]** flag for clearing logs.
- **list [-S | -s | -r | -a]**: Expanded **list** command options:
  - **-S**: List installed plugin-services.
  - **-s**: List installed termux-services.
  - **-r**: List installed plugin-scripts.
  - **-a**: List available plugin-services or plugin-scripts from the repository.
  - Clarification added on the use of `-a -S` for plugin-services and `-a -r` for plugin-scripts.
- **remove <item_name> [-s | -S | -r] [-p]**: Expanded remove command:
  - **-s**: Remove termux-service.
  - **-S**: Remove plugin-service.
  - **-r**: Remove plugin-script.
  - **-p**: Added **-p** flag to purge logs when removing a termux-service.
- **'i' or 'install'**: Alias for the install command clarified for installing plugins.

### Modified:
- **add <plugin_name>**: The description now indicates that it is specifically for creating a termux-service by adding a plugin-service from a local directory, which was previously more general.
- **install**: Command now supports multiple options and allows installing either all plugins or specific types (services or scripts).
- **logs**: The previous usage had no clear option for clearing logs (**-c**), now clarified.
- **list**: The previous **list-available**, **list-services**, and **list-plugins** commands have been consolidated into a more versatile **list** command with additional options for filtering results.

### Removed:
- **list-available**: Replaced by **list -a**.
- **list-services**: Replaced by **list -s**.
- **list-plugins**: Replaced by **list -r**.
- **remove-plugin**: Replaced by **remove <item_name>** with the added functionality for selecting service types (**-s | -S | -r**).
- **--purge**: Replaced by **-p** in the **remove** command.
