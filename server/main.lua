local playersHealing, deadPlayers = {}, {}
OX_INVENTORY = exports['ox_inventory']

Core.RegisterServerCallback('JLRP-Job-Ambulance:getDeathStatus', function(source, cb)
	local xPlayer = Core.GetPlayerFromId(source)
    if FRAMEWORKNAME == 'JLRP-Framework' then
        MySQL.scalar('SELECT is_dead FROM users WHERE citizenid = ?', {xPlayer.citizenid}, function(isDead)
            cb(isDead)
        end)
    else
        MySQL.scalar('SELECT is_dead FROM users WHERE identifier = ?', {xPlayer.identifier}, function(isDead)
            cb(isDead)
        end)
    end
end)

RegisterNetEvent('JLRP-Job-Ambulance:setDeathStatus')
AddEventHandler('JLRP-Job-Ambulance:setDeathStatus', function(isDead)
	local xPlayer = Core.GetPlayerFromId(source)

	if type(isDead) == 'boolean' then
        if FRAMEWORKNAME == 'JLRP-Framework' then
            MySQL.update('UPDATE users SET is_dead = ? WHERE citizenid = ?', {isDead, xPlayer.citizenid})
        else
            MySQL.update('UPDATE users SET is_dead = ? WHERE identifier = ?', {isDead, xPlayer.identifier})
        end
	end
    
end)

if Config.EarlyRespawnFine then
	Core.RegisterServerCallback('JLRP-Job-Ambulance:checkBalance', function(source, cb)
		local xPlayer = Core.GetPlayerFromId(source)
		local bankBalance = xPlayer.getAccount('bank').money

		cb(bankBalance >= Config.EarlyRespawnFineAmount)
	end)

	RegisterNetEvent('JLRP-Job-Ambulance:payFine')
	AddEventHandler('JLRP-Job-Ambulance:payFine', function()
		local xPlayer = Core.GetPlayerFromId(source)
		local fineAmount = Config.EarlyRespawnFineAmount

		xPlayer.showNotification(_U('respawn_bleedout_fine_msg', Core.Math.GroupDigits(fineAmount)))
		xPlayer.removeAccountMoney('bank', fineAmount)
	end)
end

RegisterNetEvent('JLRP-Job-Ambulance:onPlayerDistress')
AddEventHandler('JLRP-Job-Ambulance:onPlayerDistress', function()
	AddTheDeadPlayerToTheList(source, 'distress')
end)

function AddTheDeadPlayerToTheList(source, state)
	deadPlayers[source] = state
	SyncDeadPlayersWithAmbulancePlayers()
end

function SyncDeadPlayersWithAmbulancePlayers(source)
	if source then
		TriggerClientEvent('JLRP-Job-Ambulance:setDeadPlayers', source, deadPlayers)
	else
		TriggerClientEvent('JLRP-Job-Ambulance:setDeadPlayers', -1, deadPlayers)
	end
end

Core.RegisterServerCallback('JLRP-Job-Ambulance:removeItemsAfterRPDeath', function(source, cb)
	local xPlayer = Core.GetPlayerFromId(source)
	local isInventoryClear = false

	if Config.RemoveItemsAfterRPDeath then
		if Config.RemoveCashAfterRPDeath then
			OX_INVENTORY:ClearInventory(xPlayer.source)
		else
			local money = xPlayer.getAccount('money').money
			local blackMoney= xPlayer.getAccount('black_money').money

			OX_INVENTORY:ClearInventory(xPlayer.source)

			xPlayer.setAccountMoney('money', money)
			xPlayer.setAccountMoney('black_money', blackMoney)
		end
	end

	cb()
end)

RegisterNetEvent(Config.FrameworkEventsName..':onPlayerDeath')
AddEventHandler(Config.FrameworkEventsName..':onPlayerDeath', function(data)
	AddTheDeadPlayerToTheList(source, 'dead')
end)

AddEventHandler(Config.FrameworkEventsName..':setJob', function(source, job, lastJob)
	if AuthorizedAmbulanceJobNames[job.name] then
		SyncDeadPlayersWithAmbulancePlayers(source)
	end
end)

RegisterNetEvent(Config.FrameworkEventsName..':onPlayerSpawn')
AddEventHandler(Config.FrameworkEventsName..':onPlayerSpawn', function()
	RemoveDeadPlayerFromTheList(source)
end)

AddEventHandler(Config.FrameworkEventsName..':playerDropped', function(source, reason)
	RemoveDeadPlayerFromTheList(source)
end)

function RemoveDeadPlayerFromTheList(source)
	if deadPlayers[source] then
		deadPlayers[source] = nil
		SyncDeadPlayersWithAmbulancePlayers()
	end
end

RegisterNetEvent('JLRP-Job-Ambulance:heal')
AddEventHandler('JLRP-Job-Ambulance:heal', function(target, type)
	local xPlayer = Core.GetPlayerFromId(source)

	if xPlayer then
		if AuthorizedAmbulanceJobNames[xPlayer.job.name] then
			TriggerClientEvent('JLRP-Job-Ambulance:heal', target, type)
		else
			DropPlayer(xPlayer.source, "Cheater!")
		end
	end
end)