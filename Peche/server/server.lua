ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


local inFishing = false
local AppatActif = false
RegisterNetEvent("fCore:Fishing:StatsFishing")
AddEventHandler("fCore:Fishing:StatsFishing", function()
    inFishing = false
end)

RegisterNetEvent("fCore:Fishing:StatsAppat")
AddEventHandler("fCore:Fishing:StatsAppat", function()
    AppatActif = false
end)

ESX.RegisterUsableItem("fishingrod", function(source)
    local _src = source 
    if not inFishing then 
        local xPlayer = ESX.GetPlayerFromId(_src)
        if not xPlayer then return end
        local fishingrodCount = xPlayer.getInventoryItem("fishingrod").count
        if fishingrodCount > 0 then 
            TriggerClientEvent("fCore:Fishing:startFishing", _src)
            inFishing = true
        end
    else
        TriggerClientEvent("esx:showNotification",_src, "Vous êtes déjà entrain de pecher")
    end
end)

function utiliserAppat(source, appatType)
    local _src = source
    if not AppatActif then 
        if inFishing then
            local xPlayer = ESX.GetPlayerFromId(_src)
            if not xPlayer then return end
            local appatCount = xPlayer.getInventoryItem(appatType).count
            if appatCount > 0 then
                xPlayer.removeInventoryItem(appatType, 1)
                TriggerClientEvent("fCore:Fishing:putAppat", _src, appatType)
                AppatActif = true
            end
        else
            TriggerClientEvent("esx:showNotification",_src, "Vous devez avoir sorti une canne à pêche")
        end
    else
        TriggerClientEvent("esx:showNotification",_src, "Vous avez déjà mis un appat")
    end
end


ESX.RegisterUsableItem("petit_appat", function(source)
    utiliserAppat(source, "petit_appat")
end)

ESX.RegisterUsableItem("moyen_appat", function(source)
    utiliserAppat(source, "moyen_appat")
end)

ESX.RegisterUsableItem("grand_appat", function(source)
    utiliserAppat(source, "grand_appat")
end)

RegisterNetEvent("fCore:Fishing:GiveFish")
AddEventHandler("fCore:Fishing:GiveFish", function(nameItem)
    local _src = source 
    local xPlayer = ESX.GetPlayerFromId(_src)
    local getWeight = xPlayer.getWeight()
    if getWeight < 80 then 
        xPlayer.addInventoryItem(nameItem, 1)
    else
        TriggerClientEvent("esx:showNotification",_src, "Vous n'avez pas assez de place sur vous") 
    end
end)

RegisterNetEvent("fCore:Fishing:BreakFishingRod")
AddEventHandler("fCore:Fishing:BreakFishingRod", function()
    local _src = source 
    local xPlayer = ESX.GetPlayerFromId(_src)
    xPlayer.removeInventoryItem("fishingrod", 1)
    TriggerClientEvent("esx:showNotification",_src, "Le poisson était trop lourd ! Vous venez de casser votre canne à pêche !")
end)