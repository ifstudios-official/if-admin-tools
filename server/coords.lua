local function notifyPlayer(source, message)
    TriggerClientEvent('admintools:client:notify', source, message)
end

local function canUseCommand(source, permission)
    if Config.AllowEveryone then
        return true
    end

    if not Config.RequireAce then
        return true
    end

    return IsPlayerAceAllowed(source, permission)
end

local function registerProtectedCommand(commandName, permission, clientEvent, parser)
    RegisterCommand(commandName, function(source, args)
        if source <= 0 then
            print(('[Admin Tools] /%s can only be used by an in-game player.'):format(commandName))
            return
        end

        if not canUseCommand(source, permission) then
            notifyPlayer(source, ('^1%s^7'):format(Config.Messages.NoPermission))
            return
        end

        local eventArgs = parser and parser(args) or args
        TriggerClientEvent(clientEvent, source, table.unpack(eventArgs or {}))
    end, false)
end

registerProtectedCommand(
    Config.Commands.Coords,
    Config.Permissions.Coords,
    'admintools:client:sendCoords'
)

registerProtectedCommand(
    Config.Commands.VehInfo,
    Config.Permissions.VehInfo,
    'admintools:client:sendVehInfo'
)

registerProtectedCommand(
    Config.Commands.FixVeh,
    Config.Permissions.FixVeh,
    'admintools:client:fixVeh'
)

registerProtectedCommand(
    Config.Commands.DeleteVehicle,
    Config.Permissions.DeleteVehicle,
    'admintools:client:deleteVeh'
)

registerProtectedCommand(
    Config.Commands.PlayerId,
    Config.Permissions.PlayerId,
    'admintools:client:sendPlayerId'
)

registerProtectedCommand(
    Config.Commands.ClearArea,
    Config.Permissions.ClearArea,
    'admintools:client:clearArea',
    function(args)
        local radius = tonumber(args and args[1]) or Config.ClearAreaRadius
        radius = math.max(Config.ClearAreaMinRadius, math.min(radius, Config.ClearAreaMaxRadius))
        return { radius }
    end
)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    print(('[Admin Tools] Resource ready. AllowEveryone: %s | RequireAce: %s'):format(
        tostring(Config.AllowEveryone),
        tostring(Config.RequireAce)
    ))
end)
