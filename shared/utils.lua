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
        if AuthorizedAmbulanceJobNames[val.name] and val.name == AuthorizedAmbulanceJobNames[val.name] and val.onDuty == true then
            isOnDuty = true
            RunThread()
        else
            if isOnDuty then
                for playerId, v in pairs(deadPlayerBlips) do
                    RemoveBlip(v)
                    deadPlayerBlips[playerId] = nil
                end
            end
            isOnDuty = false
        end
    end
    
    function TextUI(type, reason, extra)
        if type == 'show' then
            local message = '[E]'
            if reason == 'open_boss_menu' then
                message = _U('open_boss_menu', extra.hospital_name)
            elseif reason == 'open_pharmacy_menu' then
                message = _U('open_pharmacy_menu', extra.hospital_name)
            end
            if Config.TextUI == 'jlrp' or Config.TextUI == 'esx' then
                Core.TextUI(message, type)
            elseif Config.TextUI == 'ox_lib' then
                lib.showTextUI(message, {
                    position = 'left-center', 
                    style = {
                        backgroundColor = '#020040', 
                        color = white, 
                        borderColor = '#d90000', 
                        borderWidth = 2
                    }
                })
            end
        elseif type == 'hide' then
            if Config.TextUI == 'jlrp' or Config.TextUI == 'esx' then
                Core.HideUI()
            elseif Config.TextUI == 'ox_lib' then
                lib.hideTextUI()
            end
        end
    end
    
    function Notification(type, message, extra)
        if Config.Notification == 'jlrp' or Config.Notification == 'esx' then
            Core.ShowNotification(message, type, 5000)
        elseif Config.Notification == 'ox_lib' then
            lib.notify({
                title = extra.hospital_name or '',
                description = message,
                position = 'left-center',
                style = {
                    backgroundColor = '#020040',
                    color = white,
                    borderColor = '#d90000',
                    borderWidth = 2
                },
                icon = type == 'success' and 'IoCheckmarkDoneCircleOutline' or type == 'error' and 'RiErrorWarningLine' or 'FcInfo',
                iconColor = type == 'success' and '#09e811' or type == 'error' and '#d90000' or '#12d0ff'
            })
        end
    end

    function ProgressBar(message, length, extra)
        length = length * 1000
        if Config.ProgressBar == 'jlrp' or Config.ProgressBar == 'esx' then
            Core.Progressbar(message, length, {FreezePlayer = false})
        elseif Config.ProgressBar == 'ox_lib' then
            lib.progressBar({
                duration = length,
                label = message
            })
        end
    end
    
    function DisableKeymanager(state) -- integrate your keymanager(RegisterKeyMapping manager) if you have one inside this function
        if FRAMEWORKNAME == 'JLRP-Framework' then
            FRAMEWORK:disableControl(state)
        end
    end
end