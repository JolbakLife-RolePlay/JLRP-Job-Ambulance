local playersHealing, deadPlayers = {}, {}

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
	SyncDeadPlayersWithAmbulancePlayers(source)
end)

function SyncDeadPlayersWithAmbulancePlayers(source)
	if deadPlayers[source] then
		deadPlayers[source] = 'distress'
		TriggerClientEvent('JLRP-Job-Ambulance:setDeadPlayers', -1, deadPlayers)
	end
end

