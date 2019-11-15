local Keys = {['E'] = 38, ['Q'] = 44}

ESX = nil

local currentWorkout = {run = false, type = -1, startTime = -1, duration = -1}
local lastWorkTime = -1

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

function startWorkout(type, duration)
    currentWorkout = {
        run = true,
        type = type,
        startTime = GetGameTimer(),
        duration = duration
    }
end

function stopWorkout()
    currentWorkout = {run = false, type = -1, startTime = -1, duration = -1}
    ClearPedTasksImmediately(GetPlayerPed(-1))
end

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

                -- show action text
                if distance < 1.0 then
                    SetTextComponentFormat("STRING")
                    if currentWorkout.run == false then
                        AddTextComponentString(
                            string.format("Press ~INPUT_CONTEXT~ to ~g~%s",
                                          v.label))
                    else
                        AddTextComponentString(
                            "Press ~INPUT_CONTEXT_SECONDARY~ to stop the exercise")
                    end
                    DisplayHelpTextFromStringLabel(0, 0, 1, -1)

                    -- start workout
                    if currentWorkout.run == false and
                        IsControlJustPressed(0, Keys['E']) then
                        if lastWorkTime ~= -1 then
                            ESX.ShowNotification("You are resting...")
                        else
                            startWorkout(v.workout, v.duration)
                            TaskStartScenarioInPlace(GetPlayerPed(-1),
                                                     Config.WorkoutScenarios[v.workout],
                                                     0, true)
                        end
                    end

                    if currentWorkout.run == true and
                        IsControlJustPressed(0, Keys['Q']) then
                        stopWorkout()
                        lastWorkTime = -1
                    end
                end

            end
        end
    end
end)

-- Track workout / resting progress
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if currentWorkout.run then
            local diff = GetGameTimer() - currentWorkout.startTime
            if diff >= currentWorkout.duration then
                stopWorkout()
                lastWorkTime = GetGameTimer()

                ESX.ShowNotification(string.format(
                                         "You need to rest ~r~%d seconds ~w~before doing another exercise.",
                                         Config.RestTime))

            end
        end

        if lastWorkTime ~= -1 then
            local diff = GetGameTimer() - lastWorkTime
            if diff >= Config.RestTime * 1000 then lastWorkTime = -1 end
        end
    end
end)
