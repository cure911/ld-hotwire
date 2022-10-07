local searchedVehs = {}
local hotwiredVehs = {}
local isActive = false
local animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"
local anim = "machinic_loop_mechandplayer"
local flags = 49
local trackedVehicles = {}
local hassearched = {}
local duzkontaklandi = {}
local maymuncuklandi = {}
local Plakalar = {}
local kilitac = false
local duzKontakSes = false
local playerLogin = false

PantCore = nil
Citizen.CreateThread(function() 
    while PantCore == nil do
        TriggerEvent("PantCore:GetObject", function(obj) PantCore = obj end)    
        Citizen.Wait(200)
        playerLogin = true
    end
end)

RegisterNetEvent('ld-base:araclarim')
AddEventHandler('ld-base:araclarim', function(plaka)
	for i=1, #plaka do
        local newPlate = evaTrim(plaka[i].plate)
        if trackedVehicles[newPlate] == nil then TrackVehicle(newPlate) end
        if trackedVehicles[newPlate].canTurnOver == false then
            trackedVehicles[newPlate].canTurnOver = true 
            TriggerEvent("ld-arackilit:plakaekle", newPlate)
            TriggerServerEvent('adiss:add-carkeys:server', evaTrim(newPlate))

            TriggerEvent("ld-arackilit:plakaekle-xhotwire", newPlate)
        end
    end	
    playerLogin = true
end)

local playerPed = PlayerPedId()
local inVeh = IsPedInAnyVehicle(playerPed)
local playerCoords = GetEntityCoords(playerPed)
local playerVehicle = 0
local vehiclePlate = ""
local vehicleClass = 0

Citizen.CreateThread(function()
    while true do
        if playerLogin then
            playerPed = PlayerPedId()
            inVeh = IsPedInAnyVehicle(playerPed)
            playerCoords = GetEntityCoords(playerPed)
            if inVeh then
                playerVehicle = GetVehiclePedIsIn(playerPed)
                vehiclePlate = evaTrim(GetVehicleNumberPlateText(playerVehicle))
                vehicleClass = GetVehicleClass(playerVehicle)
                inDriveSeat = GetPedInVehicleSeat(playerVehicle, -1) == playerPed

                if inDriveSeat then
                    if trackedVehicles[vehiclePlate] then
                        if not trackedVehicles[vehiclePlate].canTurnOver or trackedVehicles[vehiclePlate].state == 0 then
                            SetVehicleEngineOn(playerVehicle, false, false, true)
                        elseif trackedVehicles[vehiclePlate].state == 1 then
                            SetVehicleEngineOn(playerVehicle, true, false, false)
                            trackedVehicles[vehiclePlate].state = -1
                        end
                    else
                        SetVehicleEngineOn(playerVehicle, false, false, false)
                    end
                end

            else
                playerVehicle, vehiclePlate, inDriveSeat = 0, "", false
            end
        end
        Citizen.Wait(250)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        if DoesEntityExist(GetVehiclePedIsTryingToEnter(playerPed)) then
            local veh = GetVehiclePedIsTryingToEnter(playerPed)
            local driverPed = GetPedInVehicleSeat(veh, -1)
            
            SetVehicleNeedsToBeHotwired(veh) -- disable native hotwire
            if GetEntityModel(veh) == 1747439474 then
                if #(playerCoords - GetEntryPositionOfDoor(veh, 2)) < 1 or #(playerCoords - GetEntryPositionOfDoor(veh, 3)) < 1 then
                    ClearPedTasks(playerPed)
                    Citizen.Wait(100)
                end
            end

            if GetVehicleDoorLockStatus(veh) == 7 then
                SetVehicleDoorsLocked(veh, 2)
            end
            
            if driverPed and DoesEntityExist(driverPed) then
                SetPedCanBeDraggedOut(driverPed, false)
            end

            if GetVehicleDoorLockStatus(veh) == 4 then
                ClearPedTasks(playerPed)
                Citizen.Wait(100)
			end

            if GetIsVehicleEngineRunning(veh) then
                Citizen.Wait(100)
                if GetPedInVehicleSeat(veh, -1) == playerPed and GetVehicleClass(veh) ~= 15 and GetVehicleClass(veh) ~= 16 and GetVehicleClass(veh) ~= 19 then
                    TriggerEvent("x-hotwire:give-keys", veh)
                    Citizen.Wait(5000)
                end
            end
        end
    end
end)



RegisterNetEvent('x-hotwire:evaf3inahtar')
AddEventHandler('x-hotwire:evaf3inahtar', function()
    if IsPedInAnyVehicle(playerPed, false) then
        vehicle = GetVehiclePedIsIn(playerPed, false)
    else
        vehicle, mesafe = PantCore.Functions.GetClosestVehicle(playerCoords)
    end 

    local plate = evaTrim(GetVehicleNumberPlateText(vehicle))
    if Plakalar[plate] then
        local closestPlayer, closestDistance = PantCore.Functions.GetClosestPlayer()
        if closestDistance < 4.0 and closestDistance ~= -1 then
            TriggerServerEvent("ARPF:GiveKeys", GetPlayerServerId(closestPlayer), vehicle, plate)
            PantCore.Functions.Notify('Successfuly give to key')  
        else
            PantCore.Functions.Notify('There\'s No One Near You To Give The Key To.')
        end
    else
        PantCore.Functions.Notify('You Don\'t Have The Key To The Car.!')
    end           
end)

-- RegisterCommand("sa", function()
--     local ped = PlayerPedId()
--     if IsPedInAnyVehicle(ped, false) then
--         vehicle = GetVehiclePedIsIn(ped, false)
--     else
--         vehicle, mesafe = PantCore.Functions.GetClosestVehicle(coords)
--     end 
--     local plate = GetVehicleNumberPlateText(vehicle)
--     TriggerServerEvent("ARPF:GiveKeys", 1, vehicle, plate)
-- end)

RegisterCommand("anahtarver", function ()
    TriggerEvent("x-hotwire:evaf3inahtar")
end)

RegisterNetEvent('x-hotwire:give-keys')
AddEventHandler('x-hotwire:give-keys', function(veh, plate)
    if plate == nil then plate = GetVehicleNumberPlateText(veh) end
    local newPlate = evaTrim(plate)
    if trackedVehicles[newPlate] == nil then TrackVehicle(newPlate) end
    if trackedVehicles[newPlate].canTurnOver == false then
        trackedVehicles[newPlate].canTurnOver = true 
        SetVehicleHasBeenOwnedByPlayer(veh, true)
        SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(veh), true)
        TriggerEvent("ld-arackilit:plakaekle", newPlate)
        TriggerEvent("ld-arackilit:plakaekle-xhotwire", newPlate)
        TriggerServerEvent('adiss:add-carkeys:server', evaTrim(newPlate))
    end
end)

RegisterNetEvent('PantCore:Client:OnPlayerLoaded')
AddEventHandler('PantCore:Client:OnPlayerLoaded', function()
    PantCore.Functions.TriggerCallback('adiss:getplayerkeys', function(plates)
        for k,plate in pairs(plates) do
            if trackedVehicles[plate] == nil then TrackVehicle(plate) end
            if trackedVehicles[plate].canTurnOver == false then
                trackedVehicles[plate].canTurnOver = true 
            end
            print('plate is ' .. plate)
            TriggerEvent("ld-arackilit:plakaekle", plate)
            TriggerEvent("ld-arackilit:plakaekle-xhotwire", plate)  
        end
    end)
end)

RegisterCommand('addkey', function(source,args)
    TriggerServerEvent('adiss:add-carkeys:server', evaTrim(args[1]))
end)

RegisterCommand('getkey', function(args)
    PantCore.Functions.TriggerCallback('adiss:getplayerkeys', function(plates)
        for k,plate in pairs(plates) do
            print('plate is ' .. plate)
            TriggerEvent("ld-arackilit:plakaekle", evaTrim(plate))
            TriggerEvent("ld-arackilit:plakaekle-xhotwire", evaTrim(plate))  
        end
    end)
end)
RegisterNetEvent('ld-arackilit:plakaekle-xhotwire')
AddEventHandler('ld-arackilit:plakaekle-xhotwire', function(yeniplaka)
    local newPlate = evaTrim(yeniplaka)
    print(Plakalar[newPlate])
    if Plakalar[newPlate] == nil then 
        print('new plate is nil') 
         Plakalar[newPlate] = true 
    else
        print('plate is not nil')
    end
end)

RegisterNetEvent('disc-hotwire:forceTurnOver')
AddEventHandler('disc-hotwire:forceTurnOver', function(vehicle)
    local plate = evaTrim(GetVehicleNumberPlateText(vehicle))
    TrackVehicle(plate)
    trackedVehicles[plate].canTurnOver = true
end)

RegisterNetEvent("disc-hotwire:disardanMaymuncuk")
AddEventHandler("disc-hotwire:disardanMaymuncuk", function()
    if isActive then return end
    local vehicle, mesafe = PantCore.Functions.GetClosestVehicle(playerCoords)
    if mesafe < 3 then
        if GetVehiclePedIsIn(playerPed, false) == 0 and DoesEntityExist(vehicle) and  GetVehicleDoorLockStatus(vehicle) == 2 then
            local level = exports["ld-levelsistemi"]:level()
            if level < Config.level then
                PantCore.Functions.Notify('You\'re inexperienced to do this!')
                return 
            end
            isActive = true

            time = 10000
            duzKontakSes = true
            kilitac = true
            TriggerEvent("animation:lockpickinvtestoutside")
            TriggerEvent("x-hotwire:duzKontakSes")
            SetVehicleDoorsShut(vehicle, true)
            SetVehicleAlarm(vehicle, true)
            SetVehicleAlarmTimeLeft(vehicle, 45 * 1000)
                
            local finished = exports["ld-skillbar"]:taskBar(60000,math.random(5,8))
            if not finished then
                isActive = false
                duzKontakSes = false
                kilitac = false
            else
                local finished2 = exports["ld-skillbar"]:taskBar(4000,math.random(5,8))
                if not finished2 then
                    isActive = false
                    duzKontakSes = false
                    kilitac = false
                else
                    SetVehicleDoorsLocked(vehicle, 1)
                    SetVehicleDoorsLockedForAllPlayers(vehicle, false)
                    local Plate = evaTrim(GetVehicleNumberPlateText(vehicle))
                    TriggerServerEvent("ld-arackilit:lock-car-server", 1, plate)
                    isActive = false
                    duzKontakSes = false
                    kilitac = false 
                    PantCore.Functions.Notify('The Door Opened Successfully')
                    if math.random(1,4) == 1 then
                        exports["ld-levelsistemi"]:expVer("dis-kapi-arac-maymuncuklma")
                        TriggerEvent("Ld-PolisBildirim:BildirimGonder", "Vehicle Stealing Attempt", false)
                        if math.random(1,5) == 1 then
                            TriggerServerEvent('disc-hotwire:maymuncuksil')
                        end
                    end
                end
            end
         
        end
    end
end)

RegisterNetEvent('disc-hotwire:maymuncuk')
AddEventHandler('disc-hotwire:maymuncuk', function()
    if isActive then return end
    if IsPedInAnyVehicle(playerPed) then 
        if GetIsVehicleEngineRunning(playerVehicle) or trackedVehicles[vehiclePlate].canTurnOver then return end
        if vehicleClass ~= 14 then
            SetVehicleAlarm(playerVehicle, false)
            SetVehicleAlarm(playerVehicle, true)
            SetVehicleAlarmTimeLeft(playerVehicle, 60 * 1000)
        end
        isActive = true
        local finished = exports["ld-skillbar"]:taskBar(25000,math.random(5,8))
        if not finished then
            if math.random(1,3) == 1 then TriggerServerEvent('disc-hotwire:maymuncuksil') end
            isActive = false
            duzKontakSes = false
        else
            duzKontakSes = true
            TriggerEvent("x-hotwire:duzKontakSes")
            TriggerEvent("ld-stres:stres-arttir", 80)
            local finished2 = exports["ld-skillbar"]:taskBar(4000,math.random(5,12))
            if not finished2 then
                if math.random(1,3) == 1 then TriggerServerEvent('disc-hotwire:maymuncuksil') end
                isActive = false
                duzKontakSes = false
            else
                TriggerEvent("ld-stres:stres-arttir", 80)
                local finished3 = exports["ld-skillbar"]:taskBar(math.random(950,1250), math.random(10,14))
                if not finished3 then
                    isActive = false
                    duzKontakSes = false
                else
                    trackedVehicles[vehiclePlate].canTurnOver = true
                    maymuncuklandi[vehiclePlate] = true 
                    local vehicleProps = PantCore.Functions.GetVehicleProperties(playerVehicle)
                    TriggerEvent("ld-arackilit:plakaekle", vehicleProps.plate)
                    TriggerEvent("ld-arackilit:plakaekle-xhotwire", vehicleProps.plate)
                    TriggerServerEvent('adiss:add-carkeys:server', evaTrim(vehicleProps.plate))

                    TriggerEvent("ld-stres:stres-arttir", 80)
                    exports["ld-levelsistemi"]:expVer("arac-maymuncuklama")
                    SetVehicleEngineOn(playerVehicle, true, false, false)
                    duzKontakSes = false
                    isActive = false
                end
            end
        end
    end
end)

-- Araç içi düzkontak
RegisterNetEvent('disc-hotwire:hotwire')
AddEventHandler('disc-hotwire:hotwire', function()
    if inVeh then 
        if GetIsVehicleEngineRunning(playerVehicle) or IsVehicleEngineStarting(playerVehicle) or trackedVehicles[vehiclePlate].canTurnOver or isActive then return end

        isActive = true
        if vehicleClass ~= 14 then
            SetVehicleAlarm(playerVehicle, false)
            SetVehicleAlarm(playerVehicle, true)
            SetVehicleAlarmTimeLeft(playerVehicle, 60 * 1000)
        end
        local finished = exports["ld-skillbar"]:taskBar(30000,math.random(8,10))
        if not finished then
            isActive = false
            duzKontakSes = false
        else
            duzKontakSes = true
            TriggerEvent("x-hotwire:duzKontakSes")
            TriggerEvent("ld-stres:stres-arttir", 80)
            local finished2 = exports["ld-skillbar"]:taskBar(2000,math.random(8,12))
            if not finished2 then
                isActive = false
                duzKontakSes = false
            else
                TriggerEvent("ld-stres:stres-arttir", 80)
                local finished3 = exports["ld-skillbar"]:taskBar(1000,math.random(8,11))
                if not finished3 then
                    isActive = false
                    duzKontakSes = false
                else
                    local finished4 = exports["ld-skillbar"]:taskBar(4200,math.random(10,18))
                    if not finished4 then
                        isActive = false
                        duzKontakSes = false
                    else
                        local finished5 = exports["ld-skillbar"]:taskBar(1400,math.random(10,16))
                        if not finished5 then
                            isActive = false
                            duzKontakSes = false
                        else
                            exports["ld-levelsistemi"]:expVer("düz-kontak")
                            ClearPedSecondaryTask(playerPed)
                            Citizen.Wait(2000)
                            trackedVehicles[vehiclePlate].canTurnOver = true
                            local vehicleProps = PantCore.Functions.GetVehicleProperties(playerVehicle)
                            TriggerEvent("ld-arackilit:plakaekle", vehicleProps.plate)
                            TriggerEvent("ld-arackilit:plakaekle-xhotwire", vehicleProps.plate)
                            TriggerServerEvent('adiss:add-carkeys:server', evaTrim(vehicleProps.plate))

                            TriggerEvent("ld-stres:stres-arttir", 80)
                            SetVehicleEngineOn(playerVehicle, true, false, false)
                            RemoveAnimDict(animDict)
                            isActive = false
                            duzKontakSes = false
                        end
                    end
                end
            end
        end
        isActive = false
    end
end)

function searchvehicle()
    if trackedVehicles[vehiclePlate] then
        if trackedVehicles[vehiclePlate].canTurnOver == false then
            local luck = math.random(20,69)
            if not inVeh then PantCore.Functions.Notify('You\'re Not In The Vehicle?')  return  end
            if luck >= 66 then --66
                PantCore.Functions.Notify('You found the key and you\'re using it!')
                Citizen.Wait(3000)
                local vehicleProps = PantCore.Functions.GetVehicleProperties(playerVehicle)
                TriggerEvent("ld-arackilit:plakaekle", vehicleProps.plate)
                TriggerEvent("ld-arackilit:plakaekle-xhotwire", vehicleProps.plate)
                TriggerServerEvent('adiss:add-carkeys:server', evaTrim(vehicleProps.plate))

                trackedVehicles[vehiclePlate].canTurnOver = true
            elseif luck >= 40 and luck <= 65 then  
                TriggerServerEvent("disc-hotwire:aracitem")
            elseif luck >= 15 and luck <= 39 then  
                PantCore.Functions.Notify('You found some money in the car, and you\'re taking it..')
                Citizen.Wait(3000)
                --PantCore.Functions.Notify(cashreward .."$ Buldun")
                TriggerServerEvent("disc-hotwire:givereward")
            else
                PantCore.Functions.Notify('You found nothing!')  
            end
        end
    end
end

Citizen.CreateThread(function()
    while true do
        local time = 1000
        if inVeh then
            if inDriveSeat then
                if playerLogin and trackedVehicles[vehiclePlate] and not trackedVehicles[vehiclePlate].canTurnOver then
                    time = 1
                    arackontrol(playerPed, playerCoords, playerVehicle, vehiclePlate)
                else
                    TrackVehicle(vehiclePlate)
                    Citizen.Wait(1000)
                end
            end
        end
        Citizen.Wait(time)
    end
end)
-- havada arac kontrol
function arackontrol(playerPed, coords, vehicle, plate)
    if vehicleClass ~= 15 and vehicleClass ~= 16 and vehicleClass ~= 19 and vehicleClass ~= 13 and vehicleClass ~= 10 and vehicleClass ~= 11 and vehicleClass ~= 17 then
        SetVehicleEngineOn(vehicle, false, false, false)
        local kaput = GetEntityBoneIndexByName(vehicle, 'engine')
        local vehiclePos = GetWorldPositionOfEntityBone(vehicle, kaput)
        DisableControlAction(0, 59) -- leaning left/right
        DisableControlAction(0, 60) -- leaning up/down
        if hassearched[plate] == false or hassearched[plate] == nil then 
            PantCore.Functions.DrawText3D(vehiclePos.x, vehiclePos.y, vehiclePos.z+0.20, "[H] Hotwire [Z] Search car [M] Lockpick")
        elseif hassearched[plate] == true then 
            PantCore.Functions.DrawText3D(vehiclePos.x, vehiclePos.y, vehiclePos.z+0.20, "[H] Hotwire [M] Lockpick")
        end

        if IsControlJustPressed(0, 304) and not duzkontaklandi[plate] == true then
            TriggerEvent("disc-hotwire:hotwire")
            if math.random(1,100) < 35 then 
                TriggerEvent("Ld-PolisBildirim:BildirimGonder", "Stealing Car", false) 
            end
        elseif IsControlJustPressed(0, 244) and not maymuncuklandi[plate] == true then
            PantCore.Functions.TriggerCallback('ld-base-item-kontrol', function(qtty)
                print(qtty)
                if qtty > 0 then
                    TriggerEvent('disc-hotwire:maymuncuk')
                else
                    PantCore.Functions.Notify('You need lockpick!')
                end
            end, "lockpick2")
            --Citizen.Wait(2500)
        elseif IsControlJustPressed(0, 304) and not duzkontaklandi[plate] == false then
            PantCore.Functions.Notify('All The Wires Are In Each Other, You Can\'t Figure It Out.!')
        end
        if IsDisabledControlJustPressed(0, 20) and not hassearched[plate] == true then
            if isActive then return end
            isActive = true

            if math.random(1,100) < 15 then 
                TriggerEvent("Ld-PolisBildirim:BildirimGonder", "Stealing Car", false) 
            end
            TriggerEvent("ld-stres:stres-arttir", 80)

            PantCore.Functions.Progressbar("search", "Vehicle searching..", 25000, false, true, { -- p1: menu name, p2: yazı, p3: ölü iken kullan, p4:iptal edilebilir
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function() -- Done
                hassearched[plate] = true 
                isActive = false
                searchvehicle()
                exports["ld-levelsistemi"]:expVer("arac-araniyor")
            end, function() -- Cancel
                isActive = false
                PantCore.Functions.Notify('You Canceled The Search For The Car!')
            end)
            
        end
    end
end

RegisterNetEvent('animation:lockpickinvtestoutside')
AddEventHandler('animation:lockpickinvtestoutside', function()
    RequestAnimDict("veh@break_in@0h@p_m_one@")
    while not HasAnimDictLoaded("veh@break_in@0h@p_m_one@") do
        Citizen.Wait(0)
    end
    while kilitac do
      TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'lockpick', 0.4)
      TaskPlayAnim(playerPed, "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0, 1.0, 1.0, 16, 0.0, 0, 0, 0)
      Citizen.Wait(2000)
      ClearPedTasks(playerPed)
    end
    ClearPedTasks(playerPed)
end)

RegisterNetEvent('x-hotwire:duzKontakSes')
AddEventHandler('x-hotwire:duzKontakSes', function()
    while duzKontakSes do
      TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'duzkontak', 0.4)
      Citizen.Wait(3000)
    end
end)

function TrackVehicle(plate)
    if trackedVehicles[plate] == nil then
        trackedVehicles[plate] = {}
        trackedVehicles[plate].canTurnOver = false
    end
end

function VehicleInFront()
    local entityWorld = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 2.0, 0.0)
    local rayHandle = CastRayPointToPoint(playerCoords.x, playerCoords.y, playerCoords.z, entityWorld.x, entityWorld.y, entityWorld.z, 30, playerPed, 0)
    local _, _, _, _, result = GetRaycastResult(rayHandle)
    return result
end

-- Motor Aç Kapat
Citizen.CreateThread(function()
    while true do
        local time = 1000
        if inVeh and inDriveSeat then
            time = 1
            if IsControlJustReleased(1, 244) then
                motarAcKapat()
            end            
        end
        Citizen.Wait(time) 
    end
end)

RegisterNetEvent("x-hotwire:motorAcKapat")
AddEventHandler("x-hotwire:motorAcKapat" ,function()
    motarAcKapat()
end)

function motarAcKapat()
    if trackedVehicles[vehiclePlate] == nil then
        TrackVehicle(vehiclePlate)
    end

    if GetIsVehicleEngineRunning(playerVehicle) == 1 then
        trackedVehicles[vehiclePlate].state = 0
    elseif trackedVehicles[vehiclePlate].canTurnOver then
        trackedVehicles[vehiclePlate].state = 1
    elseif trackedVehicles[vehiclePlate] ~= nil then
        if Plakalar[vehiclePlate] then
            trackedVehicles[vehiclePlate].canTurnOver = true
            trackedVehicles[vehiclePlate].state = 1
        end
    end
end

evaTrim = function(value)
	if value then
		return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
	else
		return nil
	end
end