local points, isInAnyZone, isThreadActive = {}, false, false
do
    while RESOURCENAME ~= 'JLRP-Job-Ambulance' do print('Change the resource name to \'JLRP-Job-Ambulance\'; Otherwise it won\'t start!') Wait(5000) end
    while Core == nil do Wait(100) end
    for _, v in pairs(Config.Zones) do

        if v.Blip.Enable and v.Blip.Enable == true then
            local blip = AddBlipForCoord(vec(v.Blip.Position.x, v.Blip.Position.y, v.Blip.Position.z))

            SetBlipSprite(blip, v.Blip.Type or 326)
            SetBlipDisplay(blip, 2)
            SetBlipScale(blip, v.Blip.Size and (v.Blip.Size + 0.0) or 1.0)
            SetBlipAsShortRange(blip, true)

            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(v.HospitalName)
            EndTextCommandSetBlipName(blip)
        end


		for k, action in pairs(v.Markers) do
			action.MarkerDrawDistance = action.MarkerDrawDistance and (action.MarkerDrawDistance + 0.0) or 20.0
			for _, n in pairs(action.MarkerPositions) do
				
				local zone = CircleZone:Create(vec(n.x, n.y, n.z), action.MarkerDrawDistance, {
					name = RESOURCENAME..":"..v.HospitalName..":CircleZone:"..tostring(n),
					useZ = true,
					debugPoly = false
				})
				
				points[zone] = {point = zone:getCenter(), zone = action, isInZone = false, type = k, name = v.HospitalName}

				zone:onPointInOut(PolyZone.getPlayerPosition, function(isPointInside)
					points[zone].isInZone = isPointInside
					isInAnyZone = IsInAnyZone()
					if isPointInside then
						RunThread()
					end
				end, 2000)

			end
		end     
        
        if type(v.AuthorizedJobNames) == 'string' then
			local _temp = v.Type
			v.AuthorizedJobNames = {}
			v.AuthorizedJobNames[1] = _temp
		end
    end
end

function IsInAnyZone()
    for _, v in pairs(points) do
        if v.isInZone == true then
            return true
        end
    end
    return false
end

function RunThread()
    if not isThreadActive then
		if AuthorizedAmbulanceJobNames[Core.PlayerData.job.name] and isInAnyZone and isOnDuty then
			isThreadActive = true
			CreateThread(function()
				local isTextUIShown, textUIIsBeingShownInK = false
				local PlayerPed
				local PlayerCoords
				local distance
				while isInAnyZone and AuthorizedAmbulanceJobNames[Core.PlayerData.job.name] and isOnDuty do
					PlayerPed = PlayerPedId()
					PlayerCoords = GetEntityCoords(PlayerPed)
					if not Core.PlayerData.dead then
						for k, v in pairs(points) do
							distance = #(v.point - PlayerCoords)
							if v.isInZone == true and (distance <= v.zone.MarkerDrawDistance) then
								if v.type == 'BossAction' then
									if IsBoss() then
										DrawMarker(v.zone.MarkerType or 1, v.point.x, v.point.y, v.point.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.zone.MarkerSize.x or 1.5, v.zone.MarkerSize.y or 1.5, v.zone.MarkerSize.z or 1.5, v.zone.MarkerRGB.r or 255, v.zone.MarkerRGB.g or 255, v.zone.MarkerRGB.b or 255, 50, false, true, 2, nil, nil, false)
										if v.zone.EnableSecondaryMarker and v.zone.EnableSecondaryMarker == true and v.zone.MarkerType ~= 1 then
											DrawMarker(1, v.point.x, v.point.y, v.point.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.zone.MarkerSize.x + 1.0, v.zone.MarkerSize.y + 1.0, 0.5, v.zone.MarkerRGB.r or 255, v.zone.MarkerRGB.g or 255, v.zone.MarkerRGB.b or 255, 50, false, true, 2, nil, nil, false)
										end
									end
								else
									DrawMarker(v.zone.MarkerType or 1, v.point.x, v.point.y, v.point.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.zone.MarkerSize.x or 1.5, v.zone.MarkerSize.y or 1.5, v.zone.MarkerSize.z or 1.5, v.zone.MarkerRGB.r or 255, v.zone.MarkerRGB.g or 255, v.zone.MarkerRGB.b or 255, 50, false, true, 2, nil, nil, false)
									if v.zone.EnableSecondaryMarker and v.zone.EnableSecondaryMarker == true and v.zone.MarkerType ~= 1 then
										DrawMarker(1, v.point.x, v.point.y, v.point.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.zone.MarkerSize.x + 1.0, v.zone.MarkerSize.y + 1.0, 0.5, v.zone.MarkerRGB.r or 255, v.zone.MarkerRGB.g or 255, v.zone.MarkerRGB.b or 255, 50, false, true, 2, nil, nil, false)
									end
								end
								
								if distance <= 1.5 and IsPedOnFoot(PlayerPed) then
									if not isTextUIShown then
										if v.type == 'BossAction' and IsBoss() then
											TextUI('show', 'open_boss_menu', {hospital_name = v.name})
										elseif v.type == 'Pharmacy' then
											TextUI('show', 'open_pharmacy_menu', {hospital_name = v.name})
										elseif v.type == 'CloakRoom' then
											TextUI('show', 'open_cloakroom_menu', {hospital_name = v.name})
										elseif v.type == 'Inventory' then
											TextUI('show', 'open_inventory_menu', {hospital_name = v.name})
										end
										isTextUIShown = true
										textUIIsBeingShownInK = k
									end
									if IsControlJustReleased(0, 38) and not IsPedFatallyInjured(PlayerPed) then
										if v.type == 'BossAction' and IsBoss() then
											OpenAmbulanceBossActionMenu()
										elseif v.type == 'Pharmacy' then
											OpenPharmacyMenu()
										elseif v.type == 'CloakRoom' then
											OpenCloakRoomMenu()
										elseif v.type == 'Inventory' then
											OpenInventoryMenu()
										end   
									end
								else
									if isTextUIShown and textUIIsBeingShownInK and textUIIsBeingShownInK == k then
										TextUI('hide')
										isTextUIShown = false
										textUIIsBeingShownInK = nil
										Core.UI.Menu.CloseAll()
									end
								end
								
							end
						end
					else
						Wait(2000)
					end
					Wait(0)
				end
				isThreadActive = false
				if isTextUIShown then TextUI('hide') end
			end)
		end
    end
end

function IsBoss()
	local authorized = false
	if FRAMEWORKNAME == 'JLRP-Framework' then
		if Core.PlayerData.job and Core.PlayerData.job.is_boss == true then
			authorized = true
		end
	else
		if Core.PlayerData.job and Core.PlayerData.job.grade_name == 'boss' then
			authorized = true
		end
	end
	return authorized
end

if Config.Qtarget == true then
	if GetResourceState('qtarget') == 'missing' then print('Q-Target Needs To Be Installed!') Config.Qtarget = false return end
	while GetResourceState('qtarget') ~= 'started' do Wait(100) end
	local qtarget = exports['qtarget']
	for _, v in pairs(Config.Zones) do
		for _, p in pairs(v.OnOffDutyPositions) do
			local name = RESOURCENAME..":"..tostring(v)..":qtarget:"..tostring(p)
			qtarget:AddBoxZone(name, vec(p.x, p.y, p.z), 0.5, 0.5, {
				name = name,
				heading = p.h,
				debugPoly = false,
				minZ = p.z - 0.2,
				maxZ = p.z + 0.2
				}, {
					options = {
						{
							event = "JLRP-Job-Ambulance:goOnDuty",
							icon = "far fa-clipboard",
							label = "On Duty",
						},
						{
							event = "JLRP-Job-Ambulance:goOffDuty",
							icon = "far fa-clipboard",
							label = "Off Duty",
						},
					},
					job = AuthorizedAmbulanceJobNames,
					distance = 1.5
				}
			)
		end
	end
end

AddEventHandler('JLRP-Job-Ambulance:goOnDuty', function()
  TriggerServerEvent('JLRP-Job-Ambulance:goOnDuty')
end)

AddEventHandler('JLRP-Job-Ambulance:goOffDuty', function()
  TriggerServerEvent('JLRP-Job-Ambulance:goOffDuty')
end)

RegisterNetEvent('JLRP-Job-Ambulance:heal')
AddEventHandler('JLRP-Job-Ambulance:heal', function(healType, quiet)
	local playerPed = PlayerPedId()
	local maxHealth = GetEntityMaxHealth(playerPed)

	if healType == 'small' then
		local health = GetEntityHealth(playerPed)
		local newHealth = math.min(maxHealth, math.floor(health + maxHealth / 8))
		SetEntityHealth(playerPed, newHealth)
	elseif healType == 'big' then
		SetEntityHealth(playerPed, maxHealth)
	end

	if not quiet then
		Core.ShowNotification(_U('healed'))
	end
end)

function OpenPharmacyMenu()
	Core.UI.Menu.CloseAll()

	Core.UI.Menu.Open('default', GetCurrentResourceName(), 'pharmacy', {
		title    = _U('pharmacy_menu_title'),
		align    = Config.MenuAlignment,
		elements = {
			{label = _U('pharmacy_take', _U('medikit')), item = 'medikit', type = 'slider', value = 1, min = 1, max = Config.ItemsLimit['medikit'] or 25},
			{label = _U('pharmacy_take', _U('bandage')), item = 'bandage', type = 'slider', value = 1, min = 1, max = Config.ItemsLimit['bandage'] or 25}
	}}, function(data, menu)
		TriggerServerEvent('JLRP-Job-Ambulance:giveItem', data.current.item, data.current.value)
	end, function(data, menu)
		menu.close()
	end)
end

function OpenCloakRoomMenu()
	Core.UI.Menu.Open('default', GetCurrentResourceName(), 'cloakroom', {
		title    = _U('cloakroom'),
		align    = Config.MenuAlignment,
		elements = {
			{label = _U('ems_clothes_civil'), value = 'citizen_wear'},
			{label = _U('ems_clothes_ems'), value = 'uniform'},
	}}, function(data, menu)
		if data.current.value == 'citizen_wear' then
			Core.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
				TriggerEvent('skinchanger:loadSkin', skin)
			end)
		elseif data.current.value == 'uniform' then
			Core.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
				if skin.sex == 0 then
					TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_male)
				else
					TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_female)
				end

				TriggerEvent('JLRP-Job-Ambulance:setDeadPlayers', deadPlayers)
			end)
		end

		menu.close()
	end, function(data, menu)
		menu.close()
	end)
end

function OpenMobileAmbulanceActionsMenu()
	if isOnDuty and not Core.PlayerData.dead then
		Core.UI.Menu.CloseAll()

		Core.UI.Menu.Open('default', GetCurrentResourceName(), 'mobile_ambulance_actions', {
			title    = _U('ambulance'),
			align    = Config.MenuAlignment,
			elements = {
				{label = _U('ems_menu'), value = 'citizen_interaction'}
		}}, function(data, menu)
			if data.current.value == 'citizen_interaction' then
				Core.UI.Menu.Open('default', GetCurrentResourceName(), 'citizen_interaction', {
					title    = _U('ems_menu_title'),
					align    = Config.MenuAlignment,
					elements = {
						{label = _U('ems_menu_revive'), value = 'revive'},
						{label = _U('ems_menu_small'), value = 'small'},
						{label = _U('ems_menu_big'), value = 'big'},
						{label = _U('ems_menu_putincar'), value = 'put_in_vehicle'},
						{label = _U('ems_menu_search'), value = 'search'}
				}}, function(data, menu)
					if isBusy then return end

					local closestPlayer, closestDistance = Core.Game.GetClosestPlayer()

					if data.current.value == 'search' then
						TriggerServerEvent('JLRP-Job-Ambulance:svsearch')
					elseif closestPlayer == -1 or closestDistance > 1.0 then
						Core.ShowNotification(_U('no_players'))
					else
						if data.current.value == 'revive' then
							revivePlayer(closestPlayer)
						elseif data.current.value == 'small' then
							Core.TriggerServerCallback('JLRP-Job-Ambulance:getItemAmount', function(quantity)
								if quantity > 0 then
									local closestPlayerPed = GetPlayerPed(closestPlayer)
									local health = GetEntityHealth(closestPlayerPed)

									if health > 0 then
										local playerPed = PlayerPedId()

										isBusy = true
										Core.ShowNotification(_U('heal_inprogress'))
										TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
										Wait(10000)
										ClearPedTasks(playerPed)

										TriggerServerEvent('JLRP-Job-Ambulance:removeItem', 'bandage')
										TriggerServerEvent('JLRP-Job-Ambulance:heal', GetPlayerServerId(closestPlayer), 'small')
										Core.ShowNotification(_U('heal_complete', GetPlayerName(closestPlayer)))
										isBusy = false
									else
										Core.ShowNotification(_U('player_not_conscious'))
									end
								else
									Core.ShowNotification(_U('not_enough_bandage'))
								end
							end, 'bandage')

						elseif data.current.value == 'big' then

							Core.TriggerServerCallback('JLRP-Job-Ambulance:getItemAmount', function(quantity)
								if quantity > 0 then
									local closestPlayerPed = GetPlayerPed(closestPlayer)
									local health = GetEntityHealth(closestPlayerPed)

									if health > 0 then
										local playerPed = PlayerPedId()

										isBusy = true
										Core.ShowNotification(_U('heal_inprogress'))
										TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
										Wait(10000)
										ClearPedTasks(playerPed)

										TriggerServerEvent('JLRP-Job-Ambulance:removeItem', 'medikit')
										TriggerServerEvent('JLRP-Job-Ambulance:heal', GetPlayerServerId(closestPlayer), 'big')
										Core.ShowNotification(_U('heal_complete', GetPlayerName(closestPlayer)))
										isBusy = false
									else
										Core.ShowNotification(_U('player_not_conscious'))
									end
								else
									Core.ShowNotification(_U('not_enough_medikit'))
								end
							end, 'medikit')

						elseif data.current.value == 'put_in_vehicle' then
							TriggerServerEvent('JLRP-Job-Ambulance:putInVehicle', GetPlayerServerId(closestPlayer))
						end
					end
				end, function(data, menu)
					menu.close()
				end)
			end

		end, function(data, menu)
			menu.close()
		end)
	end
end

function OpenAmbulanceBossActionMenu()
	if IsBoss() and isOnDuty and not Core.PlayerData.dead then
		Core.UI.Menu.CloseAll()
		TriggerEvent('JLRP-Society:openBossMenu', Core.PlayerData.job.name, nil, {wash = false})
	end
end

function OpenInventoryMenu()
	if isOnDuty and not Core.PlayerData.dead then
		OX_INVENTORY:openInventory('stash', 'society_'..Core.PlayerData.job.name)
	end
end

function revivePlayer(closestPlayer)
	isBusy = true

	Core.TriggerServerCallback('JLRP-Job-Ambulance:getItemAmount', function(quantity)
		if quantity > 0 then
			local closestPlayerPed = GetPlayerPed(closestPlayer)

			if IsPedDeadOrDying(closestPlayerPed, 1) then
				local playerPed = PlayerPedId()
				local lib, anim = 'mini@cpr@char_a@cpr_str', 'cpr_pumpchest'
				Core.ShowNotification(_U('revive_inprogress'))

				for i = 1, 15 do
					Wait(900)

					Core.Streaming.RequestAnimDict(lib, function()
						TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0.0, false, false, false)
						RemoveAnimDict(lib)
					end)
				end

				TriggerServerEvent('JLRP-Job-Ambulance:removeItem', 'medikit')
				TriggerServerEvent('JLRP-Job-Ambulance:revive', GetPlayerServerId(closestPlayer))
			else
				Core.ShowNotification(_U('player_not_unconscious'))
			end
		else
			Core.ShowNotification(_U('not_enough_medikit'))
		end
		isBusy = false
	end, 'medikit')
end

if FRAMEWORKNAME == 'JLRP-Framework' then
	AddEventHandler('onKeyUp', function(key)
		if key == 'f6' then
			if Core.PlayerData.job and AuthorizedAmbulanceJobNames[Core.PlayerData.job.name] then
				OpenMobileAmbulanceActionsMenu()
			end
		end
	end)
else
	RegisterCommand("ambulance", function(src)
		if Core.PlayerData.job and AuthorizedAmbulanceJobNames[Core.PlayerData.job.name] then
			OpenMobileAmbulanceActionsMenu()
		end
	end)
	
	RegisterKeyMapping("ambulance", "Open Ambulance Actions Menu", "keyboard", "F6")
end

exports('bandage', function(data, slot)
    local playerPed = PlayerPedId()
    local maxHealth = GetEntityMaxHealth(playerPed)
    local health = GetEntityHealth(playerPed)

    if health < maxHealth then
        -- Use the bandage
        OX_INVENTORY:useItem(data, function(data)
            -- The item has been used, so trigger the effects
            if data then
				local healthToAdd = 20
				if health + healthToAdd <= maxHealth then
					SetEntityHealth(playerPed, health + healthToAdd)
				else
					SetEntityHealth(playerPed, maxHealth)
				end
                OX_INVENTORY:notify({text = 'You feel better now'})
            end
        end)
    else
        -- Don't use the item
        OX_INVENTORY:notify({type = 'error', text = 'You don\'t need a '.._U('bandage')..' right now'})
    end
end)

exports('medikit', function(data, slot)
    local playerPed = PlayerPedId()
    local maxHealth = GetEntityMaxHealth(playerPed)
    local health = GetEntityHealth(playerPed)
	print(maxHealth, health)

    if health < maxHealth then
        -- Use the medikit
        OX_INVENTORY:useItem(data, function(data)
            -- The item has been used, so trigger the effects
            if data then
				SetEntityHealth(playerPed, maxHealth)
                OX_INVENTORY:notify({text = 'You feel better now'})
            end
        end)
    else
        -- Don't use the item
        OX_INVENTORY:notify({type = 'error', text = 'You don\'t need a '.._U('medikit')..' right now'})
    end
end)