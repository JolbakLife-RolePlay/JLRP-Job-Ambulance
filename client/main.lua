local firstSpawn, canPayFine, shouldDistressShown = true, false, true
timer, isDead, isSearched, medic, isThreadRunning, isOnDuty = nil, false, false, 0, false, false

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
	if FRAMEWORKNAME ~= 'JLRP-Framework' then
		TriggerServerEvent('JLRP-Job-Ambulance:setDeathStatus', true)
	end
	
	StartDeathTimer()

	AnimpostfxPlay('DeathFailOut', 0, true)
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

local function NewTimer()
	local self = {}

	if FRAMEWORKNAME == 'JLRP-Framework' then
		self.earlySpawnTimer = (Core.PlayerData.metadata.earlyspawntimer and Core.PlayerData.metadata.earlyspawntimer > 0) and Core.PlayerData.metadata.earlyspawntimer or (Core.PlayerData.metadata.earlyspawntimer and Core.PlayerData.metadata.earlyspawntimer == 0 and Core.PlayerData.metadata.bleedouttimer and Core.PlayerData.metadata.bleedouttimer > 0) and 0 or Core.Math.Round(Config.EarlyRespawnTimer * 60)
		self.bleedoutTimer = (Core.PlayerData.metadata.bleedouttimer and Core.PlayerData.metadata.bleedouttimer > 0) and Core.PlayerData.metadata.bleedouttimer or Core.Math.Round(Config.BleedoutTimer * 60)
	else
		self.earlySpawnTimer = Core.Math.Round(Config.EarlyRespawnTimer * 60)
		self.bleedoutTimer = Core.Math.Round(Config.BleedoutTimer * 60)
	end

	return self
end

function StartDeathTimer()
	
	timer = NewTimer()
	
	LocalPlayer.state:set('earlySpawnTimer', timer.earlySpawnTimer, true)
	LocalPlayer.state:set('bleedoutTimer', timer.bleedoutTimer, true)

	if Config.EarlyRespawnFine then
		CanPayFine()
	end

	CreateThread(function()
		-- early respawn timer
		local loop = 0
		while timer.earlySpawnTimer > 0 and isDead do
			Wait(1000)
			loop = loop + 1
			if timer.earlySpawnTimer > 0 then
				timer.earlySpawnTimer = timer.earlySpawnTimer - 1
			end
			if loop >= 10 then
				loop = 0
				LocalPlayer.state:set('earlySpawnTimer', timer.earlySpawnTimer, true)
			end
		end
		timer.earlySpawnTimer = 0
		LocalPlayer.state:set('earlySpawnTimer', timer.earlySpawnTimer, true)

		loop = 0
		-- bleedout timer
		while timer.bleedoutTimer > 0 and isDead do
			Wait(1000)
			loop = loop + 1
			if timer.bleedoutTimer > 0 then
				timer.bleedoutTimer = timer.bleedoutTimer - 1
			end
			if loop >= 10 then
				loop = 0
				LocalPlayer.state:set('bleedoutTimer', timer.bleedoutTimer, true)
			end
		end
		timer.bleedoutTimer = 0
		LocalPlayer.state:set('bleedoutTimer', timer.bleedoutTimer, true)

		if FRAMEWORKNAME == 'JLRP-Framework' then saveRemainingDeathTimer() end
	end)
end

function StartDistressSignal(timeout)
	shouldDistressShown = true
end

function SendDistressSignal()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)

	Core.ShowNotification(_U('distress_sent'))
	TriggerServerEvent('JLRP-Job-Ambulance:onPlayerDistress')

	Core.SetTimeout(Config.DistressSignalToHospitalUnitsTimer * 60 * 1000, function()
		if isDead then StartDistressSignal(timeout) end
	end)
end

function DrawGenericTextThisFrame(big, lower)
	SetTextFont(4)
	SetTextScale(0.0, big and 0.6 or 0.5)
	SetTextColour(lower and 255 - 70 or 255, lower and 255 - 70 or 255, lower and 255 - 70 or 255, 255)
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

function GetClosestRespawnPoint()
	local PlyCoords = GetEntityCoords(PlayerPedId())
	local allHospitals, closestCoords = {}, nil

	for k, v in pairs(Config.Zones) do
		for l, r in pairs(v.RespawnPoints) do
			local distance = #(vec(r.x, r.y, r.z) - PlyCoords)
			table.insert(allHospitals, {k = k, distance = distance})
		end
	end

	table.sort(allHospitals, function(a, b)
		return a.distance < b.distance
	end)

	local key = allHospitals[1].k
	allHospitals = {}

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

function RemoveItemsAfterRPDeath()
	if FRAMEWORKNAME ~= 'JLRP-Framework' then
		TriggerServerEvent('JLRP-Job-Ambulance:setDeathStatus', false)
	end

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
end

function RespawnPed(ped, coords, heading)
	SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
	SetPlayerInvincible(ped, false)
	ClearPedBloodDamage(ped)

	TriggerServerEvent(Config.FrameworkEventsName..':onPlayerSpawn')
	TriggerEvent(Config.FrameworkEventsName..':onPlayerSpawn')
end

function DeathThread()
    if isThreadRunning then return end
    isThreadRunning = true
	shouldDistressShown = true
    CreateThread(function()
		local text, timeHeld

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

			-- early respawn timer
			if timer.earlySpawnTimer > 0 then
				text = _U('respawn_available_in', secondsToClock(timer.earlySpawnTimer))

				DrawGenericTextThisFrame(true)
				BeginTextCommandDisplayText('STRING')
				AddTextComponentSubstringPlayerName(text)
				EndTextCommandDisplayText(0.5, 0.8)
			elseif timer.bleedoutTimer > 0 then
				text = _U('respawn_bleedout_in', secondsToClock(timer.bleedoutTimer))

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

				DrawGenericTextThisFrame(true)
				BeginTextCommandDisplayText('STRING')
				AddTextComponentSubstringPlayerName(text)
				EndTextCommandDisplayText(0.5, 0.8)
			elseif timer.bleedoutTimer < 1 then
				RemoveItemsAfterRPDeath()
				break
			end

			if shouldDistressShown then
				DrawGenericTextThisFrame(false, true)
				BeginTextCommandDisplayText('STRING')
				AddTextComponentSubstringPlayerName(_U('send_distress'))
				EndTextCommandDisplayText(0.5, 0.9)

				if IsControlJustReleased(0, 47) then
					SendDistressSignal()
					shouldDistressShown = false
				end
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

RegisterNetEvent('JLRP-Job-Ambulance:revive')
AddEventHandler('JLRP-Job-Ambulance:revive', function()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	if FRAMEWORKNAME ~= 'JLRP-Framework' then
		TriggerServerEvent('JLRP-Job-Ambulance:setDeathStatus', false)
	end

	DoScreenFadeOut(800)

	while not IsScreenFadedOut() do
		Wait(50)
	end

	local formattedCoords = {
		x = Core.Math.Round(coords.x, 1),
		y = Core.Math.Round(coords.y, 1),
		z = Core.Math.Round(coords.z, 1)
	}

	RespawnPed(playerPed, formattedCoords, 0.0)

	AnimpostfxStop('DeathFailOut')
	DoScreenFadeIn(800)
end)

if FRAMEWORKNAME == 'JLRP-Framework' then
	AddEventHandler('onResourceStop', function(resource)
		if resource == RESOURCENAME then
			saveRemainingDeathTimer()
		end
	end)
	
	AddEventHandler('onClientResourceStop', function(resource)
		if resource == RESOURCENAME then
			saveRemainingDeathTimer()
		end
	end)
	
	function saveRemainingDeathTimer()
		if timer == nil then
			timer = {}
			timer.earlySpawnTimer = 0
			timer.bleedoutTimer = 0
		end
		--print(timer.earlySpawnTimer, timer.bleedoutTimer)
		TriggerServerEvent('JLRP-Job-Ambulance:saveDeathTimer', timer)
	end
end

RegisterCommand("timer", function()
    saveRemainingDeathTimer()
end, false --[[this command is not restricted, everyone can use this.]])

