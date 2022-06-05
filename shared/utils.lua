FRAMEWORK = nil -- To Store the metadata of exports
FRAMEWORKNAME = nil
Core = nil
RESOURCENAME = GetCurrentResourceName()

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
end

if IsDuplicityVersion() then -- Only register the body of else in server
else
    AddEventHandler(Config.FrameworkEventsName..':setPlayerData', function(key, val, last)
		if GetInvokingResource() == FRAMEWORKNAME then
			if FRAMEWORKNAME == 'JLRP-Framework' and key == 'coords' then Core.PlayerData['position'] = val end
			Core.PlayerData[key] = val
			OnPlayerData(key, val, last)
		end
	end)
end

function OnPlayerData(key, val, last)
    if key == 'accounts' then
        CanPayFine()
    end
end