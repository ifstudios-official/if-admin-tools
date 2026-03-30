# Admin Tools

`Admin Tools` is a standalone FiveM resource by `IF Studios`, focused on simple, reliable staff utilities. It does not depend on ESX, QBCore, or any other framework.

## IF Studios

`IF Studios` creates lightweight FiveM tools with a clean structure, practical features, and a focus on maintainability.

## Features

- Standalone Lua resource
- ACE-based permission control
- Clean chat output and optional console output
- Lightweight admin commands for day-to-day server support

## Commands

| Command | Description |
| --- | --- |
| `/coords` | Shows your current position as `vector3`, `vector4`, and heading. |
| `/vehinfo` | Shows information about the current or nearest vehicle. |
| `/fixveh` | Repairs the current or nearest vehicle. |
| `/dv` | Deletes the current or nearest vehicle. |
| `/cleararea [radius]` | Clears nearby vehicles and objects inside a radius. |
| `/playerid` | Shows the server ID and name of the player you are aiming at or closest to you. |

## Installation

1. Place the `admintools` folder inside your server `resources` directory.
2. Add the resource to your `server.cfg`:

```cfg
ensure admintools
```

3. Give access to the permissions you want to use:

```cfg
add_ace group.admin admintools.coords allow
add_ace group.admin admintools.vehinfo allow
add_ace group.admin admintools.fixveh allow
add_ace group.admin admintools.dv allow
add_ace group.admin admintools.cleararea allow
add_ace group.admin admintools.playerid allow
```

4. Assign your admins to the correct group if needed:

```cfg
add_principal identifier.license:YOUR_LICENSE_HERE group.admin
```

## Configuration

Edit `config.lua` to adjust commands, permissions, and behavior.

```lua
Config.CommandName = 'coords'
Config.Commands.Coords = Config.CommandName
Config.Commands.VehInfo = 'vehinfo'
Config.Commands.FixVeh = 'fixveh'
Config.Commands.DeleteVehicle = 'dv'
Config.Commands.ClearArea = 'cleararea'
Config.Commands.PlayerId = 'playerid'

Config.RequireAce = true
Config.AcePermission = 'admintools.coords'
Config.AllowEveryone = false

Config.Permissions.Coords = Config.AcePermission
Config.Permissions.VehInfo = 'admintools.vehinfo'
Config.Permissions.FixVeh = 'admintools.fixveh'
Config.Permissions.DeleteVehicle = 'admintools.dv'
Config.Permissions.ClearArea = 'admintools.cleararea'
Config.Permissions.PlayerId = 'admintools.playerid'

Config.DecimalPlaces = 3
Config.OutputFormat = 'both'
Config.VehicleSearchRadius = 8.0
Config.PlayerSearchRadius = 5.0
Config.ClearAreaRadius = 30.0
Config.ClearAreaMinRadius = 1.0
Config.ClearAreaMaxRadius = 250.0
Config.ClearAreaAffectsPeds = false
```

`Config.OutputFormat` accepts:

- `chat`
- `console`
- `both`

## File Structure

- `fxmanifest.lua`
- `config.lua`
- `client/coords.lua`
- `server/coords.lua`

## Notes

- `/cleararea` accepts an optional radius, and falls back to `Config.ClearAreaRadius`.
- `/vehinfo`, `/fixveh`, and `/dv` use the nearest vehicle if you are not inside one.
- `/playerid` first checks the player you are aiming at, then falls back to the closest player nearby.

## License

Free to use and modify for your own server. Created and maintained by `IF Studios`.
