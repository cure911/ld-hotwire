PantCore = nil
local vehicles = {}
TriggerEvent('PantCore:GetObject', function(obj)
    PantCore = obj
end)

RegisterServerEvent('disc-hotwire:maymuncuksil')
AddEventHandler('disc-hotwire:maymuncuksil', function()
	local xPlayer = PantCore.Functions.GetPlayer(source)
	xPlayer.Functions.RemoveItem('lockpick', 1)
end)

RegisterServerEvent('disc-hotwire:givereward')
AddEventHandler('disc-hotwire:givereward', function()
    local xPlayer = PantCore.Functions.GetPlayer(source)
    xPlayer.Functions.AddMoney('cash', math.random(25, 150))
end)

RegisterServerEvent('disc-hotwire:aracitem')
AddEventHandler('disc-hotwire:aracitem', function(cashreward)
    local xPlayer = PantCore.Functions.GetPlayer(source)

    local ihtimal = math.random(1,1)
    if ihtimal == 1 then  
        if xPlayer.Functions.AddItem("water", 1) then
        else
            TriggerClientEvent('PantCore:Notify', xPlayer.PlayerData.source, 'To be heavy', error, 5000)   
        end
    end
end)


RegisterServerEvent('adiss:add-carkeys:server')
AddEventHandler('adiss:add-carkeys:server', function(plate)
    local xPlayer = PantCore.Functions.GetPlayer(source)
    local charid = xPlayer.PlayerData.citizenid
    print('added plate from server')
    if vehicles[plate] == nil then
        vehicles[plate] = {}
        table.insert(vehicles[plate], {id=charid })
    else
        table.insert(vehicles[plate], {id=charid })
    end
end)


PantCore.Functions.CreateUseableItem('lockpick2', function(source)
    TriggerClientEvent('disc-hotwire:disardanMaymuncuk', source)
    TriggerClientEvent('houseRobberies:attempt', source)
end)

PantCore.Functions.CreateCallback('adiss:getplayerkeys', function(source, cb)
    local xPlayer = PantCore.Functions.GetPlayer(source)
    local charid = xPlayer.PlayerData.citizenid
    local plates = {}

    for plate,v in pairs(vehicles) do
        for _,vehicle in pairs(v) do
            if vehicle.id == charid then
                print('plate ' .. plate)
                table.insert(plates, plate)
            end
        end
    end
    cb(plates)
end)


RegisterNetEvent('ARPF:GiveKeys')
AddEventHandler('ARPF:GiveKeys', function(closestplayer, vehicle, plate)
    local src = closestplayer
    local xPlayer = PantCore.Functions.GetPlayer(src)
    if xPlayer then
        TriggerClientEvent("x-hotwire:give-keys", xPlayer.PlayerData.source, vehicle, plate)
        TriggerClientEvent('PantCore:Notify', xPlayer.PlayerData.source, ' You got the key of the car with license plate'..plate, success, 5000)   
    end
end)

PantCore.Functions.CreateUseableItem('lockpick2', function(source)
    TriggerClientEvent('disc-hotwire:disardanMaymuncuk', source)
    TriggerClientEvent('houseRobberies:attempt', source)
end)