ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

local AppatActif = false
local AnimActif = false
local nameAppat
RegisterNetEvent("fCore:Fishing:putAppat")
AddEventHandler("fCore:Fishing:putAppat", function(name)
    ESX.ShowNotification("Vous venez de mettre un appat sur la canne à pêche Vous êtes désormais entrain de pêcher")
    AppatActif = true
    nameAppat = name
end)


function CancelAnim()
    CreateThread(function()
        AnimActif = true
        while AnimActif do 
            RageUI.Text({message = "Appuyer sur ~r~X~s~ pour arrêter les animations"})   
            if IsControlJustPressed(1, 73) then 
                DeleteAnim()
            end
            Wait(0)
        end
    end)
end


RegisterNetEvent("fCore:Fishing:startFishing")
AddEventHandler("fCore:Fishing:startFishing", function()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local waterHeight = 0.0
    local isWater, waterZ = GetWaterHeight(playerCoords.x, playerCoords.y, playerCoords.z, waterHeight)
    local playerZ = playerCoords.z
    if isWater then 
        if not IsPedSwimming(PlayerPedId()) then
            AnimationPeche()
            ESX.ShowNotification("Vous devez mettre un appât pour commencer à pêcher")
            local startTime = GetGameTimer() -- Temps de départ
            local elapsedTime = 0 -- Temps écoulé
            while elapsedTime < 5000 do
                Citizen.Wait(100)
                elapsedTime = GetGameTimer() - startTime 
                if AppatActif then
                    startFishing()
                    return
                end
            end
            ESX.ShowNotification("Vous n'avez pas mis d'appât")
            DeleteAnim()
            TriggerServerEvent("fCore:Fishing:StatsFishing")
        else
            TriggerServerEvent("fCore:Fishing:StatsFishing")
            ESX.ShowNotification("Tu ne peux pas pecher en nageant")
        end
    else
        TriggerServerEvent("fCore:Fishing:StatsFishing")
        ESX.ShowNotification("Il n'y a pas d'eau dans les alentours")
    end
end)

local ToucheSelect = {["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163}
function startFishing()
    CancelAnim()
    local percentBreakFishingRod = math.random(1,10)
    local PlayerPos = GetEntityCoords(PlayerPedId())
    local dist = #(PlayerPos - CoordsCayoToFishing)
    local isInsideZone = dist <= 1500
    local matchingItems = {}
    for _, v in ipairs(FishPossible) do
        if isInsideZone or not v.cayo then 
            if v.appat == nameAppat then
                table.insert(matchingItems, v)
            end
        end
    end

    local randomIndex = math.random(1, #matchingItems)
    local randomItem = matchingItems[randomIndex]
    local StartTime
    local fishingInProgress = false
    local poissonFerer = false
    local fishingRodBreak = false
    CreateThread(function()
        Wait(5000)
        local keys = {}
        for key in pairs(ToucheSelect) do
            table.insert(keys, key)
        end
        local randomIndex = math.random(1, #keys)
        local randomKey = keys[randomIndex]
        local randomValue = ToucheSelect[randomKey]
        local randomTime = math.random(1000, 3000)
        Wait(randomTime)
        if AnimActif then 
            StartTime = GetGameTimer()
            local timeLimit = 10000
            fishingInProgress = true
            ESX.ShowNotification(("Un poisson est sur votre hameçon ! Ferrer le poisson en appuyant sur ~b~%s~s~"):format(randomKey))
            while fishingInProgress and (GetGameTimer() - StartTime) < timeLimit do
                if IsControlJustPressed(1, randomValue) then
                    if percentBreakFishingRod == 1 then 
                        fishingRodBreak = true
                        DeleteAnim()
                        TriggerServerEvent("fCore:Fishing:BreakFishingRod")
                    else
                        AppatActif = false
                        TriggerServerEvent("fCore:Fishing:StatsAppat")
                        TriggerServerEvent("fCore:Fishing:GiveFish", randomItem.name)
                        ESX.ShowNotification("Vous venez de pêcher un poisson Vous avez 10 secondes pour remettre un appât pour continuer à pecher")
                        fishingInProgress = false
                        Wait(10000)
                    end
                end
                Wait(0)
            end
        
            if not fishingRodBreak then 
                if fishingInProgress then
                    poissonFerer = true
                    AppatActif = false
                    TriggerServerEvent("fCore:Fishing:StatsAppat")
                    ESX.ShowNotification("Vous n'avez pas ferer le poisson  Vous avez 10 secondes pour remettre un appât pour continuer à pecher")
                    Wait(10000)
                    if not AppatActif then
                        ESX.ShowNotification("Vous n'avez pas remis d'appât")
                        DeleteAnim()
                    end
                end

                if AppatActif then
                    startFishing()
                else
                    DeleteAnim()
                    TriggerServerEvent("fCore:Fishing:StatsFishing")
                    if not poissonFerer then 
                        ESX.ShowNotification("Vous n'avez pas remis d'appât")
                    end
                end
            end
        end

    end)
end

function DeleteAnim()
    ESX.ShowNotification("Vous avez arrêter la pêche", "Action", "rouge")
    AnimActif = false
    AppatActif = false
    TriggerServerEvent("fCore:Fishing:StatsAppat")
    TriggerServerEvent("fCore:Fishing:StatsFishing")
    fishingInProgress = false
    ClearPedTasks(PlayerPedId())
    DetachEntity(propPeche, true, true)
    DeleteEntity(propPeche)
end

function AnimationPeche()
    local animationDict = "amb@world_human_stand_fishing@idle_a"
    local animationName = "idle_a"
    local propModel = GetHashKey("prop_fishing_rod_01")
    local propBone = 60309
    local propOffset = vector3(0.0, 0.0, 0.0)
    local propRotation = vector3(0.0, 0.0, 0.0)
    RequestAnimDict(animationDict)
    while not HasAnimDictLoaded(animationDict) do
        Wait(0)
    end
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(PlayerPedId())
    propPeche = CreateObject(propModel, coords.x, coords.y, coords.z, true, true, true)
    AttachEntityToEntity(propPeche, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), propBone), propOffset, propRotation, true, true, false, true, 1, true)
    TaskPlayAnim(PlayerPedId(), animationDict, animationName, 8.0, -8.0, -1, 1, 0, false, false, false)
end

