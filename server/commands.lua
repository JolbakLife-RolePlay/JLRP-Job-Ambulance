Core.RegisterCommand('revive', 'admin', function(xPlayer, args, showError)
	args.playerId.triggerEvent('JLRP-Job-Ambulance:revive')
end, true, {help = _U('revive_help'), validate = true, arguments = {
	{name = 'playerId', help = 'The player id', type = 'player'}
}})

Core.RegisterCommand('reviveall', "superadmin", function(xPlayer, args, showError)
    local xPlayers = Core.GetExtendedPlayers()
    for _, xPlayer in pairs(xPlayers) do
        if xPlayer.getMetadata('dead') == true then
            xPlayer.triggerEvent('JLRP-Job-Ambulance:revive')
        else
            xPlayer.triggerEvent('JLRP-Job-Ambulance:heal', 'big')
        end    
    end
end, true, {help = _U('revive_all_help')})