local RESOURCE_PREFIX = Config.Messages.Prefix

local function formatNumber(value)
    return string.format('%.' .. Config.DecimalPlaces .. 'f', value)
end

local function shouldSendToChat()
    return Config.OutputFormat == 'chat' or Config.OutputFormat == 'both'
end

local function shouldSendToConsole()
    return Config.OutputFormat == 'console' or Config.OutputFormat == 'both'
end

local function sendChatLine(message)
    TriggerEvent('chat:addMessage', {
        color = { 255, 255, 255 },
        multiline = false,
        args = { RESOURCE_PREFIX, message }
    })
end

local function sendResult(chatLines, consoleLines)
    if shouldSendToChat() then
        for _, line in ipairs(chatLines or {}) do
            sendChatLine(line)
        end
    end

    if shouldSendToConsole() then
        for _, line in ipairs(consoleLines or {}) do
            print(('[Admin Tools] %s'):format(line))
        end
    end
end

local function notify(message)
    sendResult({ ('^1%s^7'):format(message) }, { message })
end

local function formatCoordsPayload(coords, heading)
    local x = formatNumber(coords.x)
    local y = formatNumber(coords.y)
    local z = formatNumber(coords.z)
    local h = formatNumber(heading)

    return {
        vector3 = ('vector3(%s, %s, %s)'):format(x, y, z),
        vector4 = ('vector4(%s, %s, %s, %s)'):format(x, y, z, h),
        heading = h
    }
end

local function getLabelFromVehicle(vehicle)
    local model = GetEntityModel(vehicle)
    local displayName = GetDisplayNameFromVehicleModel(model)
    local label = GetLabelText(displayName)

    if label == 'NULL' or label == 'CARNOTFOUND' or label == '' then
        return displayName, model
    end

    return label, model
end

local function getClosestVehicle(radius)
    local ped = PlayerPedId()
    local playerCoords = GetEntityCoords(ped)
    local closestVehicle = nil
    local closestDistance = radius or Config.VehicleSearchRadius

    for _, vehicle in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(vehicle) then
            local distance = #(playerCoords - GetEntityCoords(vehicle))
            if distance <= closestDistance then
                closestDistance = distance
                closestVehicle = vehicle
            end
        end
    end

    return closestVehicle, closestDistance
end

local function getTargetVehicle()
    local ped = PlayerPedId()
    local currentVehicle = GetVehiclePedIsIn(ped, false)

    if currentVehicle and currentVehicle ~= 0 then
        return currentVehicle, 'current'
    end

    local nearbyVehicle = getClosestVehicle(Config.VehicleSearchRadius)
    if nearbyVehicle then
        return nearbyVehicle, 'nearby'
    end

    return nil, nil
end

local function requestControl(entity, timeoutMs)
    if not DoesEntityExist(entity) then
        return false
    end

    if not NetworkGetEntityIsNetworked(entity) then
        return true
    end

    local timeoutAt = GetGameTimer() + (timeoutMs or 750)

    while not NetworkHasControlOfEntity(entity) and GetGameTimer() < timeoutAt do
        NetworkRequestControlOfEntity(entity)
        Wait(0)
    end

    return NetworkHasControlOfEntity(entity)
end

local function deleteEntity(entity)
    if not DoesEntityExist(entity) then
        return false
    end

    requestControl(entity, 1000)
    SetEntityAsMissionEntity(entity, true, true)

    if IsEntityAVehicle(entity) then
        DeleteVehicle(entity)
    else
        DeleteEntity(entity)
    end

    return not DoesEntityExist(entity)
end

local function fixVehicle(vehicle)
    if not DoesEntityExist(vehicle) then
        return false
    end

    requestControl(vehicle, 1000)
    SetVehicleFixed(vehicle)
    SetVehicleDeformationFixed(vehicle)
    SetVehicleBodyHealth(vehicle, 1000.0)
    SetVehicleEngineHealth(vehicle, 1000.0)
    SetVehiclePetrolTankHealth(vehicle, 1000.0)
    SetVehicleDirtLevel(vehicle, 0.0)
    SetVehicleUndriveable(vehicle, false)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetVehicleOnGroundProperly(vehicle)

    return true
end

local function getClosestPlayer(radius)
    local ped = PlayerPedId()
    local playerCoords = GetEntityCoords(ped)
    local closestPlayer = nil
    local closestDistance = radius or Config.PlayerSearchRadius

    for _, player in ipairs(GetActivePlayers()) do
        local targetPed = GetPlayerPed(player)
        if targetPed ~= ped and DoesEntityExist(targetPed) then
            local distance = #(playerCoords - GetEntityCoords(targetPed))
            if distance <= closestDistance then
                closestDistance = distance
                closestPlayer = player
            end
        end
    end

    return closestPlayer, closestDistance
end

local function getAimedPlayer()
    local success, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())

    if success and entity and entity ~= 0 and DoesEntityExist(entity) and IsEntityAPed(entity) and IsPedAPlayer(entity) then
        local playerIndex = NetworkGetPlayerIndexFromPed(entity)
        if playerIndex and playerIndex ~= -1 then
            return playerIndex
        end
    end

    return nil
end

local function formatPlayerLabel(playerId, ped)
    local serverId = GetPlayerServerId(playerId)
    local name = GetPlayerName(playerId) or 'Unknown'
    local coords = GetEntityCoords(ped)

    return {
        serverId = serverId,
        name = name,
        coords = coords,
        heading = formatNumber(GetEntityHeading(ped))
    }
end

RegisterNetEvent('admintools:client:sendCoords', function()
    local ped = PlayerPedId()

    if not ped or ped == 0 then
        notify('Unable to read your player ped right now.')
        return
    end

    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local payload = formatCoordsPayload(coords, heading)

    sendResult({
        '^2Coordinates captured successfully.^7',
        ('^5vector3:^7 %s'):format(payload.vector3),
        ('^5vector4:^7 %s'):format(payload.vector4),
        ('^5heading:^7 %s'):format(payload.heading),
        Config.Messages.CopyHint
    }, {
        'Coordinates captured successfully.',
        payload.vector3,
        payload.vector4,
        ('heading: %s'):format(payload.heading)
    })
end)

RegisterNetEvent('admintools:client:sendVehInfo', function()
    local vehicle = getTargetVehicle()

    if not vehicle then
        notify(Config.Messages.NoVehicle)
        return
    end

    local label, model = getLabelFromVehicle(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    local speed = formatNumber(GetEntitySpeed(vehicle) * 3.6)
    local heading = formatNumber(GetEntityHeading(vehicle))
    local engine = formatNumber(GetVehicleEngineHealth(vehicle))
    local body = formatNumber(GetVehicleBodyHealth(vehicle))
    local tank = formatNumber(GetVehiclePetrolTankHealth(vehicle))
    local dirt = formatNumber(GetVehicleDirtLevel(vehicle))
    local netId = NetworkGetNetworkIdFromEntity(vehicle)

    sendResult({
        '^2Vehicle information captured successfully.^7',
        ('^5Model:^7 %s ^8(%s)^7'):format(label, tostring(model)),
        ('^5Plate:^7 %s'):format(plate),
        ('^5Speed:^7 %s km/h'):format(speed),
        ('^5Heading:^7 %s'):format(heading),
        ('^5Engine:^7 %s ^8| ^5Body:^7 %s ^8| ^5Tank:^7 %s'):format(engine, body, tank),
        ('^5Dirt:^7 %s ^8| ^5Net ID:^7 %s'):format(dirt, tostring(netId))
    }, {
        'Vehicle information captured successfully.',
        ('Model: %s (%s)'):format(label, tostring(model)),
        ('Plate: %s'):format(plate),
        ('Speed: %s km/h'):format(speed),
        ('Heading: %s'):format(heading),
        ('Engine: %s | Body: %s | Tank: %s'):format(engine, body, tank),
        ('Dirt: %s | Net ID: %s'):format(dirt, tostring(netId))
    })
end)

RegisterNetEvent('admintools:client:fixVeh', function()
    local vehicle = getTargetVehicle()

    if not vehicle then
        notify(Config.Messages.NoVehicle)
        return
    end

    if fixVehicle(vehicle) then
        sendResult({ ('^2%s^7'):format(Config.Messages.VehicleFixed) }, { Config.Messages.VehicleFixed })
    else
        notify('Unable to repair the vehicle right now.')
    end
end)

RegisterNetEvent('admintools:client:deleteVeh', function()
    local vehicle = getTargetVehicle()

    if not vehicle then
        notify(Config.Messages.NoVehicle)
        return
    end

    if deleteEntity(vehicle) then
        sendResult({ ('^2%s^7'):format(Config.Messages.VehicleDeleted) }, { Config.Messages.VehicleDeleted })
    else
        notify('Unable to delete the vehicle right now.')
    end
end)

RegisterNetEvent('admintools:client:clearArea', function(radius)
    local playerPed = PlayerPedId()

    if not playerPed or playerPed == 0 then
        notify('Unable to read your player ped right now.')
        return
    end

    radius = tonumber(radius) or Config.ClearAreaRadius
    if radius <= 0 then
        notify(Config.Messages.InvalidRadius)
        return
    end

    local playerCoords = GetEntityCoords(playerPed)
    local currentVehicle = GetVehiclePedIsIn(playerPed, false)
    local vehiclesRemoved = 0
    local objectsRemoved = 0
    local pedsRemoved = 0

    for _, vehicle in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(vehicle) and vehicle ~= currentVehicle then
            local distance = #(playerCoords - GetEntityCoords(vehicle))
            if distance <= radius and deleteEntity(vehicle) then
                vehiclesRemoved = vehiclesRemoved + 1
            end
        end
    end

    for _, object in ipairs(GetGamePool('CObject')) do
        if DoesEntityExist(object) then
            local distance = #(playerCoords - GetEntityCoords(object))
            if distance <= radius and deleteEntity(object) then
                objectsRemoved = objectsRemoved + 1
            end
        end
    end

    if Config.ClearAreaAffectsPeds then
        for _, ped in ipairs(GetGamePool('CPed')) do
            if ped ~= playerPed and not IsPedAPlayer(ped) and DoesEntityExist(ped) then
                local distance = #(playerCoords - GetEntityCoords(ped))
                if distance <= radius and deleteEntity(ped) then
                    pedsRemoved = pedsRemoved + 1
                end
            end
        end
    end

    local summary = ('Radius: %s | Vehicles: %s | Objects: %s | Peds: %s'):format(
        formatNumber(radius),
        vehiclesRemoved,
        objectsRemoved,
        pedsRemoved
    )

    sendResult({
        ('^2%s^7'):format(Config.Messages.AreaCleared),
        ('^5Summary:^7 %s'):format(summary)
    }, {
        Config.Messages.AreaCleared,
        summary
    })
end)

RegisterNetEvent('admintools:client:sendPlayerId', function()
    local playerId = getAimedPlayer()
    local sourceLabel = 'aimed'

    if not playerId then
        playerId = getClosestPlayer(Config.PlayerSearchRadius)
        sourceLabel = 'nearby'
    end

    if not playerId then
        notify(Config.Messages.NoPlayerNearby)
        return
    end

    local ped = GetPlayerPed(playerId)
    local info = formatPlayerLabel(playerId, ped)
    local distance = formatNumber(#(GetEntityCoords(PlayerPedId()) - info.coords))

    sendResult({
        '^2Player information captured successfully.^7',
        ('^5Server ID:^7 %s'):format(info.serverId),
        ('^5Name:^7 %s'):format(info.name),
        ('^5Distance:^7 %s m'):format(distance),
        ('^5Heading:^7 %s'):format(info.heading),
        ('^5Target:^7 %s'):format(sourceLabel)
    }, {
        'Player information captured successfully.',
        ('Server ID: %s'):format(info.serverId),
        ('Name: %s'):format(info.name),
        ('Distance: %s m'):format(distance),
        ('Heading: %s'):format(info.heading),
        ('Target: %s'):format(sourceLabel)
    })
end)

RegisterNetEvent('admintools:client:notify', function(message)
    notify(message)
end)
