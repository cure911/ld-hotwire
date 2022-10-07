local karakterYuklendi = false
local Plakalar = {}

PantCore = nil
Citizen.CreateThread(function() 
	while PantCore == nil do
		TriggerEvent("PantCore:GetObject", function(obj) PantCore = obj end)    
		Citizen.Wait(200)
	end
end)

RegisterNetEvent('ld-base:araclarim')
AddEventHandler('ld-base:araclarim', function(plaka)
	for i=1, #plaka do
		Plakalar[plaka[i].plate] = true
	end	
	karakterYuklendi = true
end)

Citizen.CreateThread(function()
  	while true do
		Citizen.Wait(0)
		if IsControlJustPressed(1, 182) then
			local playerped = PlayerPedId()
			local kordinat = GetEntityCoords(playerped)
			local arac, mesafe = PantCore.Functions.GetClosestVehicle(kordinat)

			if mesafe <= 10.0 then
				local Plate = PantCore.Shared.Trim(GetVehicleNumberPlateText(arac))
				if Plakalar[Plate] then
					LockVehicle(arac, Plate)
				end
			end
			
		end
  	end
end)

function LockVehicle(veh, plate)
	if IsPedInAnyVehicle(PlayerPedId()) then
        veh = GetVehiclePedIsIn(PlayerPedId())
	end
	
	local vehLockStatus = GetVehicleDoorLockStatus(veh)

	PantCore.Shared.RequestAnimDict('anim@mp_player_intmenu@key_fob@', function()
		TaskPlayAnim(PlayerPedId(), 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3.0, 3.0, -1, 49, 0, false, false, false)
	end)

	if vehLockStatus == 1 then
		Citizen.Wait(750)
		ClearPedTasks(PlayerPedId())
		TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'lock', 0.1)
		TriggerServerEvent("ld-arackilit:lock-car-server", 2, plate)
		SetVehicleDoorsLocked(veh, 2)
		if(GetVehicleDoorLockStatus(veh) == 2)then
			PantCore.Functions.Notify("Vehicle locked", "error")
		else
			PantCore.Functions.Notify("There is a problem with the lock system, try again!")
		end
	else
		Citizen.Wait(750)
		ClearPedTasks(PlayerPedId())
		TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'lock', 0.1)
		TriggerServerEvent("ld-arackilit:lock-car-server", 1, plate)
		SetVehicleDoorsLocked(veh, 1)
		if(GetVehicleDoorLockStatus(veh) == 1)then
			PantCore.Functions.Notify("Vehicle Unlocked", "success")
		else
			PantCore.Functions.Notify("There is a problem with the lock system, try again!")
		end
	end

	if not IsPedInAnyVehicle(PlayerPedId()) then
		SetVehicleInteriorlight(veh, true)
		SetVehicleIndicatorLights(veh, 0, true)
		SetVehicleIndicatorLights(veh, 1, true)
		Citizen.Wait(450)
		SetVehicleIndicatorLights(veh, 0, false)
		SetVehicleIndicatorLights(veh, 1, false)
		Citizen.Wait(450)
		SetVehicleInteriorlight(veh, true)
		SetVehicleIndicatorLights(veh, 0, true)
		SetVehicleIndicatorLights(veh, 1, true)
		Citizen.Wait(450)
		SetVehicleInteriorlight(veh, false)
		SetVehicleIndicatorLights(veh, 0, false)
		SetVehicleIndicatorLights(veh, 1, false)
	end

end

RegisterNetEvent('ld-arackilit:lock-car')
AddEventHandler('ld-arackilit:lock-car', function(durum, plaka)
	if karakterYuklendi then
		local gameVehicles = PantCore.Functions.GetVehicles()
		for i = 1, #gameVehicles do
			local arac = gameVehicles[i]
			if DoesEntityExist(arac) then
				if PantCore.Shared.Trim(GetVehicleNumberPlateText(arac)) == plaka then
					SetVehicleDoorsLocked(arac, durum)
					break
				end
			end
		end	
	end
end)

RegisterNetEvent('ld-arackilit:plakaekle')
AddEventHandler('ld-arackilit:plakaekle', function(yeniplaka)
	local plaka = PantCore.Shared.Trim(yeniplaka)
	if Plakalar[plaka] == nil then
		Plakalar[plaka] = true
	end
end)