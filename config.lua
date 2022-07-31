Config = {}
Config.Locale = 'en'

Config.FrameworkEventsName = 'JLRP-Framework' -- if your framework events name are like 'esx:onPlayerSpawn', write 'esx' for Config.FrameworkEventsName

Config.TextUI = 'ox_lib' -- valid values: 'jlrp' or 'ox_lib' or 'esx'
Config.Notification = 'jlrp' -- valid values: 'jlrp' or 'ox_lib' or 'esx'
Config.ProgressBar = 'ox_lib' -- valid values: 'jlrp' or 'ox_lib' or 'esx'
Config.MenuAlignment = 'right'

Config.EarlyRespawnTimer = 0.1  -- time(minute) till respawn is available
Config.BleedoutTimer = 10 -- time(minute) till the player bleeds out
Config.DistressSignalToHospitalUnitsTimer = 1 -- time(minute) till the player can again send distress signal to available hospital units

-- Let the player pay for respawning early, only if he can afford it.
Config.EarlyRespawnFine = true
Config.EarlyRespawnFineAmount = 5000
Config.EarlyRespawnFineMoneyType = 'money' -- valid values : 'money or 'bank' or 'black_money'(not suggested)


Config.ReviveReward = 300

Config.RemoveItemsAfterRPDeath = true
--[[ DON'T UNCOMMENT FOR NOW. WAITING FOR OX_INVENTORY TO BRING THIS FEATURE IN ClearInventory(inv, keep)
Config.FilteredItems = {
    {
        Name = 'id_card', -- name of the item that won't be deleted after Config.RemoveItemsAfterRPDeath is set to true
        Metadata = {}, -- if the item has a certain metadata
        Job = {} -- if included any, after Config.RemoveItemsAfterRPDeath is set to true, only the players that have these job(s) will have the item still with them if have one
    }
}
]]
Config.RemoveCashAfterRPDeath = false

Config.Qtarget = true

Config.ItemsLimit = {
    meditkit = 25,
    bandage = 25
}

Config.Zones = {
    {
        HospitalName = 'City Hospital',
        AuthorizedJobNames = {'ambulance'},    
        Blip = {
            Enable = true,
            Type = 61,
            Colour = 0,
            Size = 1.0,
            Position = {x = 340.67, y = -586.21, z = 30.66}
        },
        Markers = {
            BossAction = {
                Enable = true,
                MarkerPositions = {
                    {x = 334.61, y = -594.34, z = 43.2}
                },
                MarkerSize = {x = 1.5, y = 1.5, z = 1.0},
                MarkerRGB = {r = 255, g = 50, b = 50},
                MarkerDrawDistance = 5.0,
                MarkerType = 22,
                EnableSecondaryMarker = false,
				EnableTextOnMarker = true,
            },
            Pharmacy = {
                Enable = true,
                MarkerPositions = {
                    {x = 359.02, y = -603.26, z = 43.28},
                    {x = 309.58, y = -561.54, z = 43.28}
                },
                MarkerSize = {x = 1.5, y = 1.5, z = 1.0},
                MarkerRGB = {r = 50, g = 50, b = 255},
                MarkerDrawDistance = 10.0,
                MarkerType = 20,
                EnableSecondaryMarker = false,
				EnableTextOnMarker = true,
            },
            CloakRoom = {
                Enable = false,
                MarkerPositions = {                  
                    {x = 298.85, y = -598.41, z = 43.28},
                    {x = 301.75, y = -599.28, z = 43.28}
                },
                MarkerSize = {x = 1.5, y = 1.5, z = 1.0},
                MarkerRGB = {r = 50, g = 50, b = 255},
                MarkerDrawDistance = 5.0,
                MarkerType = 20,
                EnableSecondaryMarker = false,
				EnableTextOnMarker = true,
            },
            Inventory = {
                Enable = true,
                MarkerPositions = {                  
                    {x = 306.83, y = -601.61, z = 43.28},
                },
                MarkerSize = {x = 1.5, y = 1.5, z = 1.0},
                MarkerRGB = {r = 255, g = 0, b = 255},
                MarkerDrawDistance = 6.0,
                MarkerType = 20,
                EnableSecondaryMarker = false,
				EnableTextOnMarker = true,
            },
        },
        OnOffDutyPositions = {
            {x = 307.544, y = -595.23, z = 43.1, h = 76.5},
            {x = 311.917, y = -593.36, z = 43.1, h = 346.633},
            {x = 350.411, y = -587.646, z = 28.7, h = 287.016}
        },
        RespawnPositions = {
            {x = 341.0, y = -1397.3, z = 32.5, h = 48.5}
        }
    }
}

Config.SendToHospitalBedOnRespawn = true -- WIP
Config.Locations = {
    ["checking"] = {
	    [1] = vector3(308.19, -595.35, 43.29),
	    [2] = vector3(-254.54, 6331.78, 32.43), -- paleto
    },
    ["beds"] = {
        [1] = {coords = vector4(353.1, -584.6, 43.11, 152.08), taken = false, model = 1631638868},
        [2] = {coords = vector4(356.79, -585.86, 43.11, 152.08), taken = false, model = 1631638868},
        [3] = {coords = vector4(354.12, -593.12, 43.1, 336.32), taken = false, model = 2117668672},
        [4] = {coords = vector4(350.79, -591.8, 43.1, 336.32), taken = false, model = 2117668672},
        [5] = {coords = vector4(346.99, -590.48, 43.1, 336.32), taken = false, model = 2117668672},
        [6] = {coords = vector4(360.32, -587.19, 43.02, 152.08), taken = false, model = -1091386327},
        [7] = {coords = vector4(349.82, -583.33, 43.02, 152.08), taken = false, model = -1091386327},
        [8] = {coords = vector4(326.98, -576.17, 43.02, 152.08), taken = false, model = -1091386327},
		-- paleto
		[9] = {coords = vector4(-252.43, 6312.25, 32.34, 313.48), taken = false, model = 2117668672},
        [10] = {coords = vector4(-247.04, 6317.95, 32.34, 134.64), taken = false, model = 2117668672},
        [11] = {coords = vector4(-255.98, 6315.67, 32.34, 313.91), taken = false, model = 2117668672},
    },
    ["jailbeds"] = {
        [1] = {coords = vector4(1761.96, 2597.74, 45.66, 270.14), taken = false, model = 2117668672},
        [2] = {coords = vector4(1761.96, 2591.51, 45.66, 269.8), taken = false, model = 2117668672},
        [3] = {coords = vector4(1771.8, 2598.02, 45.66, 89.05), taken = false, model = 2117668672},
        [4] = {coords = vector4(1771.85, 2591.85, 45.66, 91.51), taken = false, model = 2117668672},
    }
}

if IsDuplicityVersion() then
    Config.AutoAdjustDatabaseWithConfigJob = true --if set to true it automaticaly updates the database on resource start if any of Config.Job values change - SUGGESTED TO SET true!
    Config.Job = {
        ['ambulance'] = {
            Label = 'Ambulance',
            Grades = {
                ['0'] = {
                    Name = 'trainee',
                    Label = 'Trainee',
                    Salary = 200,
                    AccessToBossMenu = false -- would only work if the framework is JLRP-Framework
                },
                ['1'] = {
                    Name = 'medic',
                    Label = 'Medic', 
                    Salary = 400,
                    AccessToBossMenu = false -- would only work if the framework is JLRP-Framework
                },
                ['2'] = {
                    Name = 'paramedic',
                    Label = 'Paramedic',
                    Salary = 800,
                    AccessToBossMenu = false -- would only work if the framework is JLRP-Framework
                },
                ['3'] = {
                    Name = 'doctor',
                    Label = 'doctor',
                    Salary = 1000,
                    AccessToBossMenu = false -- would only work if the framework is JLRP-Framework
                },
                ['4'] = {
                    Name = 'surgeon',
                    Label = 'Surgeon',
                    Salary = 1200,
                    AccessToBossMenu = false -- would only work if the framework is JLRP-Framework
                },
                ['5'] = {
                    Name = 'chief',
                    Label = 'Chief',
                    Salary = 1350,
                    AccessToBossMenu = true -- would only work if the framework is JLRP-Framework
                },
                ['6'] = {
                    Name = 'boss', -- make sure the name for the highest rank MUST be 'boss'
                    Label = 'Boss',
                    Salary = 1500,
                    AccessToBossMenu = true -- would only work if the framework is JLRP-Framework
                }
            }
        }
    }
end