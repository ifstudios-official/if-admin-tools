Config = {}

Config.CommandName = 'coords'
Config.Commands = {
    Coords = Config.CommandName,
    VehInfo = 'vehinfo',
    FixVeh = 'fixveh',
    DeleteVehicle = 'dv',
    ClearArea = 'cleararea',
    PlayerId = 'playerid'
}

Config.RequireAce = true
Config.AcePermission = 'admintools.coords'
Config.AllowEveryone = false
Config.Permissions = {
    Coords = Config.AcePermission,
    VehInfo = 'admintools.vehinfo',
    FixVeh = 'admintools.fixveh',
    DeleteVehicle = 'admintools.dv',
    ClearArea = 'admintools.cleararea',
    PlayerId = 'admintools.playerid'
}

Config.DecimalPlaces = 3
Config.OutputFormat = 'both'
-- Supported values: 'chat', 'console', 'both'
Config.VehicleSearchRadius = 8.0
Config.PlayerSearchRadius = 5.0
Config.ClearAreaRadius = 30.0
Config.ClearAreaMinRadius = 1.0
Config.ClearAreaMaxRadius = 250.0
Config.ClearAreaAffectsPeds = false

Config.Messages = {
    Prefix = '^3Admin Tools^7',
    NoPermission = 'You do not have permission to use this command.',
    OnlyPlayers = 'This command can only be used by an in-game player.',
    CopyHint = 'Tip: copy the vector line directly from chat or your F8 console.',
    NoVehicle = 'No vehicle found nearby.',
    NotInVehicle = 'You are not inside a vehicle.',
    VehicleFixed = 'Vehicle repaired successfully.',
    VehicleDeleted = 'Vehicle deleted successfully.',
    NoPlayerNearby = 'No player found nearby.',
    AreaCleared = 'Area cleared successfully.',
    InvalidRadius = 'Invalid radius value.',
    ClearAreaUsage = 'Usage: /cleararea [radius]'
}
