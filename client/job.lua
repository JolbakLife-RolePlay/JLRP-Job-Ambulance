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
								DrawMarker(v.zone.MarkerType or 1, v.point.x, v.point.y, v.point.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.zone.MarkerSize.x or 1.5, v.zone.MarkerSize.y or 1.5, v.zone.MarkerSize.z or 1.5, v.zone.MarkerRGB.r or 255, v.zone.MarkerRGB.g or 255, v.zone.MarkerRGB.b or 255, 50, false, true, 2, nil, nil, false)
								if v.zone.EnableSecondaryMarker and v.zone.EnableSecondaryMarker == true and v.zone.MarkerType ~= 1 then
									DrawMarker(1, v.point.x, v.point.y, v.point.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.zone.MarkerSize.x + 1.0, v.zone.MarkerSize.y + 1.0, 0.5, v.zone.MarkerRGB.r or 255, v.zone.MarkerRGB.g or 255, v.zone.MarkerRGB.b or 255, 50, false, true, 2, nil, nil, false)
								end
								if distance <= 1.5 and IsPedOnFoot(PlayerPed) then
									if not isTextUIShown then
										if v.type == 'BossAction' then
											TextUI('show', 'open_boss_menu', {hospital_name = v.name})
										end
										isTextUIShown = true
										textUIIsBeingShownInK = k
									end
									if IsControlJustReleased(0, 38) and not IsPedFatallyInjured(PlayerPed) then
										if v.type == 'BossAction' then

										end     
									end
								else
									if isTextUIShown and textUIIsBeingShownInK and textUIIsBeingShownInK == k then
										TextUI('hide')
										isTextUIShown = false
										textUIIsBeingShownInK = nil
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

do
	exports['qtarget']:AddBoxZone("AmbulanceDuty1", vector3(350.411, -587.646, 28.7), 0.4, 0.5, { --Lower Floor
		name = "AmbulanceDuty1",
		heading = 287.016,
		debugPoly = false,
		minZ = 28.5,
		maxZ = 28.90
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
	
	exports['qtarget']:AddBoxZone("AmbulanceDuty2", vector3(307.544, -595.23, 43.1), 0.4, 0.5, { --Main Floor
		name = "AmbulanceDuty2",
		heading = 76.5,
		debugPoly = false,
		minZ = 42.9,
		maxZ = 43.3
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
	
	exports['qtarget']:AddBoxZone("AmbulanceDuty3", vector3(311.917, -593.36, 43.1), 0.4, 0.5, { --Main Floor
		name = "AmbulanceDuty3",
		heading = 346.633,
		debugPoly = false,
		minZ = 42.9,
		maxZ = 43.3
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

RegisterNetEvent('JLRP-Job-Ambulance:goOnDuty')
AddEventHandler('JLRP-Job-Ambulance:goOnDuty', function()
  TriggerServerEvent('JLRP-Job-Ambulance:goOnDuty')
end)

RegisterNetEvent('JLRP-Job-Ambulance:goOffDuty')
AddEventHandler('JLRP-Job-Ambulance:goOffDuty', function()
  TriggerServerEvent('JLRP-Job-Ambulance:goOffDuty')
end)