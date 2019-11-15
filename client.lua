ESX = nil

-- Get ESX and PlayerData
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData() == nil do Citizen.Wait(100) end

    ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(player) ESX.PlayerData = player end)

-- Create blip
Citizen.CreateThread(function()
    local blip = AddBlipForCoord(Config.Blip.Pos.x, Config.Blip.Pos.y,
                                 Config.Blip.Pos.z)

    SetBlipSprite(blip, Config.Blip.Sprite)
    SetBlipDisplay(blip, Config.Blip.Display)
    SetBlipScale(blip, Config.Blip.Scale)
    SetBlipColour(blip, Config.Blip.Colour)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.Blip.Title)
    EndTextCommandSetBlipName(blip)
end)

-- Show workouts
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local coords = GetEntityCoords(GetPlayerPed(-1))
        for k, v in pairs(Config.Workouts) do
            local distance = GetDistanceBetweenCoords(coords, v.x, v.y, v.z,
                                                      true)
            -- show marker
            if distance < Config.DrawDistance then
                DrawMarker(Config.MarkerType, v.x, v.y, v.z, 0, 0, 0, 0, 0, 0,
                           Config.MarkerSize.x, Config.MarkerSize.y,
                           Config.MarkerSize.z, Config.MarkerColour.r,
                           Config.MarkerColour.g, Config.MarkerColour.b, 255, 0,
                           0, 0, 1)
            end

            -- show action text
            if distance < 1.0 then
                SetTextComponentFormat("STRING")
                AddTextComponentString(string.format(
                                           "Press ~INPUT_CONTEXT~ to ~g~%s",
                                           v.label))
                DisplayHelpTextFromStringLabel(0, 0, 1, -1)
            end
        end
    end
end)

