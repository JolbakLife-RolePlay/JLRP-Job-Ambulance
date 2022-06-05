FRAMEWORK = nil -- To Store the metadata of exports
FRAMEWORKNAME = nil
Core = nil
RESOURCENAME = GetCurrentResourceName()
AuthorizedAmbulanceJobNames = {}
do
    if GetResourceState("JLRP-Framework") ~= "missing" then
        FRAMEWORKNAME = "JLRP-Framework"
        FRAMEWORK = exports[FRAMEWORKNAME]
        Core = FRAMEWORK:GetFrameworkObjects()
    elseif GetResourceState("es_extended") ~= "missing" then
        FRAMEWORKNAME = "es_extended"
        FRAMEWORK = exports[FRAMEWORKNAME]
        Core = FRAMEWORK:getSharedObject()
    end

    for k, v in pairs(Config.Zones) do
        for i = 1, #v.AuthorizedJobNames, 1 do
            AuthorizedAmbulanceJobNames[v.AuthorizedJobNames[i]] = v.AuthorizedJobNames[i]
        end
    end
end

if IsDuplicityVersion() then -- Only register the body of else in server
else
    isOnDuty = false
    
    AddEventHandler(Config.FrameworkEventsName..':setPlayerData', function(key, val, last)
		if GetInvokingResource() == FRAMEWORKNAME then
			if FRAMEWORKNAME == 'JLRP-Framework' and key == 'coords' then Core.PlayerData['position'] = val end
			Core.PlayerData[key] = val
			OnPlayerData(key, val, last)
		end
	end)

    function OnPlayerData(key, val, last)
        if key == 'accounts' then
            CanPayFine()
        elseif key == 'job' then
            JobModified(val, last)
        end
    end
    
    function JobModified(val, last)
        if AuthorizedAmbulanceJobNames[val.name] and val.name == AuthorizedAmbulanceJobNames[val.name] then
            isOnDuty = true
        else
            if isOnDuty then
                for playerId,v in pairs(deadPlayerBlips) do
                    RemoveBlip(v)
                    deadPlayerBlips[playerId] = nil
                end
            end
            isOnDuty = false
        end
    end
end