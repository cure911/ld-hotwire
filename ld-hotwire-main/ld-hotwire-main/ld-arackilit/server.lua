PantCore               = nil

TriggerEvent('PantCore:GetObject', function(obj) PantCore = obj end)

PantCore.Functions.CreateCallback('ld-arackilit:araclarim', function(source, cb)
	local xPlayer = PantCore.Functions.GetPlayer(source)
	local Plakalar = {}
	exports.ghmattimysql:execute('SELECT * FROM owned_vehicles WHERE owner = @owner', {
		['@owner']  = xPlayer.PlayerData.citizenid,
	}, function(data)
		for _,v in pairs(data) do
			table.insert(Plakalar, {
				plate = v.plate
			})
		end
		cb(Plakalar)
	end)
end)

RegisterServerEvent('ld-arackilit:lock-car-server')
AddEventHandler('ld-arackilit:lock-car-server', function(durum, plate)
    TriggerClientEvent("ld-arackilit:lock-car", -1, durum, plate)
end)