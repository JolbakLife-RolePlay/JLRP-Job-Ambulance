local firstSpawn, canPayFine = true, false
isDead, isSearched, medic, isThreadRunning, isOnDuty = false, false, 0, false, false

RegisterNetEvent(Config.FrameworkEventsName..':playerLoaded')
AddEventHandler(Config.FrameworkEventsName..':playerLoaded', function(xPlayer)
	Core.PlayerLoaded = true
    Core.PlayerData = xPlayer
end)

RegisterNetEvent(Config.FrameworkEventsName..':onPlayerLogout')
AddEventHandler(Config.FrameworkEventsName..':onPlayerLogout', function()
	Core.PlayerLoaded = false
	firstSpawn = true
end)

AddEventHandler(Config.FrameworkEventsName..':onPlayerSpawn', function()
	isDead = false

	if firstSpawn then
		firstSpawn = false

		while not Core.PlayerLoaded do
            Wait(1000)
        end

        Core.TriggerServerCallback('JLRP-Job-Ambulance:getDeathStatus', function(shouldDie)
            if shouldDie then
                Wait(1000)
                SetEntityHealth(PlayerPedId(), 0)
            end
        end)
	end
end)

function OnPlayerDeath()
	isDead = true
	Core.UI.Menu.CloseAll()
	TriggerServerEvent('JLRP-Job-Ambulance:setDeathStatus', true)

	StartDeathTimer()
	StartDistressSignal() 

	AnimpostfxPlay('DeathFailOut', 0, false)
    DeathThread()
end

AddEventHandler(Config.FrameworkEventsName..':onPlayerDeath', function(data)
	OnPlayerDeath()
end)

function CanPayFine()
	if Config.EarlyRespawnFine then
		local _canPayFine = 'waiting'
		Core.TriggerServerCallback('JLRP-Job-Ambulance:checkBalance', function(canPay)
			_canPayFine = canPay
		end)
		while type(_canPayFine) == 'string' do Wait(0) end
		canPayFine = _canPayFine
		return _canPayFine
	end
	return false
end

function StartDeathTimer()

	if Config.EarlyRespawnFine then
		CanPayFine()
	end

	local earlySpawnTimer = Core.Math.Round((Config.EarlyRespawnTimer * 1000 * 60) / 1000)
	local bleedoutTimer = Core.Math.Round((Config.BleedoutTimer * 1000 * 60) / 1000)

	CreateThread(function()
		-- early respawn timer
		while earlySpawnTimer > 0 and isDead do
			Wait(1000)

			if earlySpawnTimer > 0 then
				earlySpawnTimer = earlySpawnTimer - 1
			end
		end

		-- bleedout timer
		while bleedoutTimer > 0 and isDead do
			Wait(1000)

			if bleedoutTimer > 0 then
				bleedoutTimer = bleedoutTimer - 1
			end
		end
	end)

	CreateThread(function()
		local text, timeHeld

		-- early respawn timer
		while earlySpawnTimer > 0 and isDead do
			Wait(0)
			text = _U('respawn_available_in', secondsToClock(earlySpawnTimer))

			DrawGenericTextThisFrame()
			BeginTextCommandDisplayText('STRING')
			AddTextComponentSubstringPlayerName(text)
			EndTextCommandDisplayText(0.5, 0.8)
		end

		-- bleedout timer
		while bleedoutTimer > 0 and isDead do
			Wait(0)
			text = _U('respawn_bleedout_in', secondsToClock(bleedoutTimer))

			if not Config.EarlyRespawnFine then
				text = text .. _U('respawn_bleedout_prompt')

				if IsControlPressed(0, 38) and timeHeld > 60 then
					RemoveItemsAfterRPDeath()
					break
				end
			elseif Config.EarlyRespawnFine and canPayFine then
				text = text .. _U('respawn_bleedout_fine', Core.Math.GroupDigits(Config.EarlyRespawnFineAmount))

				if IsControlPressed(0, 38) and timeHeld > 60 then
					TriggerServerEvent('JLRP-Job-Ambulance:payFine')
					RemoveItemsAfterRPDeath()
					break
				end
			end

			if IsControlPressed(0, 38) then
				timeHeld = timeHeld + 1
			else
				timeHeld = 0
			end

			DrawGenericTextThisFrame()

			BeginTextCommandDisplayText('STRING')
			AddTextComponentSubstringPlayerName(text)
			EndTextCommandDisplayText(0.5, 0.8)
		end

		if bleedoutTimer < 1 and isDead then
			RemoveItemsAfterRPDeath()
		end
	end)
end

function StartDistressSignal()
	Citizen.CreateThreadNow(function()
		local timer = Config.BleedoutTimer * 1000 * 60 -- seconds

		while timer > 0 and isDead do
			Wait(0)
			timer = timer - 30

			SetTextFont(4)
			SetTextScale(0.45, 0.45)
			SetTextColour(185, 185, 185, 255)
			SetTextDropshadow(0, 0, 0, 0, 255)
			SetTextDropShadow()
			SetTextOutline()
			BeginTextCommandDisplayText('STRING')
			AddTextComponentSubstringPlayerName(_U('send_distress'))
			EndTextCommandDisplayText(0.175, 0.805)

			if IsControlJustReleased(0, 47) then
				SendDistressSignal()
				break
			end
		end
	end)
end

function SendDistressSignal()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)

	Core.ShowNotification(_U('distress_sent'))
	TriggerServerEvent('JLRP-Job-Ambulance:onPlayerDistress')
end

function DrawGenericTextThisFrame()
	SetTextFont(4)
	SetTextScale(0.0, 0.5)
	SetTextColour(255, 255, 255, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(true)
end

function secondsToClock(seconds)
	local seconds, hours, mins, secs = tonumber(seconds), 0, 0, 0

	if seconds <= 0 then
		return 0, 0
	else
		local hours = string.format('%02.f', math.floor(seconds / 3600))
		local mins = string.format('%02.f', math.floor(seconds / 60 - (hours * 60)))
		local secs = string.format('%02.f', math.floor(seconds - hours * 3600 - mins * 60))

		return mins, secs
	end
end

function RemoveItemsAfterRPDeath()
	TriggerServerEvent('JLRP-Job-Ambulance:setDeathStatus', false)

	CreateThread(function()
		Core.TriggerServerCallback('JLRP-Job-Ambulance:removeItemsAfterRPDeath', function()
			local RespawnCoords = GetClosestRespawnPoint()

			DoScreenFadeOut(800)
			RespawnPed(PlayerPedId(), vec(RespawnCoords.x, RespawnCoords.y, RespawnCoords.z), RespawnCoords.h)
			while not IsScreenFadedOut() do
			    Wait(0)
			end
			AnimpostfxStop('DeathFailOut')
			DoScreenFadeIn(800)
		end)
	end)
end

function GetClosestRespawnPoint()
	local PlyCoords = GetEntityCoords(PlayerPedId())
	local allHospitals, closestCoords = {}, nil

	for k, v in pairs(Config.Zones) do
		for l, r in pairs(v.RespawnPoints) do
			local distance = #(vec(r.x, r.y, r.z) - PlyCoords)
			table.insert(allHospitals, {k = k, distance = distance})
			break
		end
	end

	table.sort(allHospitals, function(a, b)
		return a.distance < b.distance
	end)

	local key = allHospitals[1]

	for k, v in pairs(Config.Zones[key].RespawnPoints) do
		table.insert(allHospitals, v)
	end

	key = math.random(#allHospitals)

	closestCoords = {
		x = allHospitals[key].x,
		y = allHospitals[key].y,
		z = allHospitals[key].z,
		h = allHospitals[key].h
	}

	return closestCoords
end

function DeathThread()
    if isThreadRunning then return end
    isThreadRunning = true
    Citizen.CreateThreadNow(function()
        while isDead do
            DisableAllControlActions(0)
			EnableControlAction(0, 47, true)
			EnableControlAction(0, 245, true)
			EnableControlAction(0, 38, true)

			if isSearched then
				local playerPed = PlayerPedId()
				local ped = GetPlayerPed(GetPlayerFromServerId(medic))
				isSearched = false
	
				AttachEntityToEntity(playerPed, ped, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
				Wait(1000)
				DetachEntity(playerPed, true, false)
				ClearPedTasksImmediately(playerPed)
			end
            Wait(0)
        end
        isThreadRunning = false
    end)
end

RegisterNetEvent('JLRP-Job-Ambulance:setDeadPlayers')
AddEventHandler('JLRP-Job-Ambulance:setDeadPlayers', function(_deadPlayers)
	deadPlayers = _deadPlayers

	if isOnDuty then
		for playerId,v in pairs(deadPlayerBlips) do
			RemoveBlip(v)
			deadPlayerBlips[playerId] = nil
		end

		for playerId,status in pairs(deadPlayers) do
			if status == 'distress' then
				local player = GetPlayerFromServerId(playerId)
				local playerPed = GetPlayerPed(player)
				local blip = AddBlipForEntity(playerPed)

				SetBlipSprite(blip, 303)
				SetBlipColour(blip, 1)
				SetBlipFlashes(blip, true)
				SetBlipCategory(blip, 7)

				BeginTextCommandSetBlipName('STRING')
				AddTextComponentSubstringPlayerName(_U('blip_dead'))
				EndTextCommandSetBlipName(blip)

				deadPlayerBlips[playerId] = blip
			end
		end
	end
end)