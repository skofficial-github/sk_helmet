local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("sk_helmet:syncHelmet", function(propId, drawable, texture)
    local src = source
    TriggerClientEvent("sk_helmet:setHelmet", -1, src, propId, drawable, texture)
end)

RegisterNetEvent("sk_helmet:saveHelmet", function(helmetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.SetMetaData("helmetId", helmetId)
    end
end)

AddEventHandler("QBCore:Server:PlayerLoaded", function(Player)
    local helmetId = Player.PlayerData.metadata["helmetId"] or 0
    TriggerClientEvent("sk_helmet:loadHelmet", Player.PlayerData.source, helmetId)
end)