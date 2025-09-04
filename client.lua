local QBCore = exports['qb-core']:GetCoreObject()

local helmetOn = false
local currentHelmet = 0
local savedHat = {drawable = -1, texture = -1, didSave = false}
local maxHelmet = 128
local isPreviewing = false

RegisterCommand("helmet", function()
    local ped = PlayerPedId()
    if helmetOn then
        helmetOn = false
        if savedHat.drawable ~= -1 then
            SetPedPropIndex(ped, 0, savedHat.drawable, savedHat.texture, true)
            TriggerServerEvent("sk_helmet:syncHelmet", 0, savedHat.drawable, savedHat.texture)
        else
            ClearPedProp(ped, 0)
            TriggerServerEvent("sk_helmet:syncHelmet", 0, -1, -1)
        end
        QBCore.Functions.Notify("Helmet off", "primary")
    else
        if currentHelmet == 0 then
            QBCore.Functions.Notify("You need to choose a helmet model first with /changehelmet.", "error")
            return
        end

        local drawable = GetPedPropIndex(ped, 0)
        local texture = GetPedPropTextureIndex(ped, 0)
        if drawable ~= -1 then
            savedHat.drawable = drawable
            savedHat.texture = texture
        else
            savedHat.drawable = -1
            savedHat.texture = -1
        end

        helmetOn = true
        SetPedPropIndex(ped, 0, currentHelmet, 0, true)
        TriggerServerEvent("sk_helmet:syncHelmet", 0, currentHelmet, 0)
        QBCore.Functions.Notify("Helmet on", "success")
    end
end)

RegisterCommand("changehelmet", function()
    local ped = PlayerPedId()

    if not savedHat.didSave then
        local drawable = GetPedPropIndex(ped, 0)
        local texture = GetPedPropTextureIndex(ped, 0)
        if drawable ~= -1 then
            savedHat.drawable = drawable
            savedHat.texture = texture
        else
            savedHat.drawable = -1
            savedHat.texture = -1
        end
        savedHat.didSave = true
    end

    SetNuiFocus(true, true)
    isPreviewing = true
    SendNUIMessage({ action = "openMenu", helmet = currentHelmet })
end)

RegisterNUICallback("previewHelmet", function(data, cb)
    local ped = PlayerPedId()
    local previewId = tonumber(data.id)
    SetPedPropIndex(ped, 0, previewId, 0, true)
    cb("ok")
end)

RegisterNUICallback("saveHelmet", function(data, cb)
    currentHelmet = tonumber(data.id)
    TriggerServerEvent("sk_helmet:saveHelmet", currentHelmet)

    local ped = PlayerPedId()
    if savedHat.drawable ~= -1 then
        SetPedPropIndex(ped, 0, savedHat.drawable, savedHat.texture, true)
        TriggerServerEvent("sk_helmet:syncHelmet", 0, savedHat.drawable, savedHat.texture)
    else
        ClearPedProp(ped, 0)
        TriggerServerEvent("sk_helmet:syncHelmet", 0, -1, -1)
    end

    QBCore.Functions.Notify("Helmet selected", "success")
    isPreviewing = false
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("closeMenu", function(_, cb)
    local ped = PlayerPedId()
    if helmetOn then
        SetPedPropIndex(ped, 0, currentHelmet, 0, true)
        TriggerServerEvent("sk_helmet:syncHelmet", 0, currentHelmet, 0)
    else
        if savedHat.drawable ~= -1 then
            SetPedPropIndex(ped, 0, savedHat.drawable, savedHat.texture, true)
            TriggerServerEvent("sk_helmet:syncHelmet", 0, savedHat.drawable, savedHat.texture)
        else
            ClearPedProp(ped, 0)
            TriggerServerEvent("sk_helmet:syncHelmet", 0, -1, -1)
        end
    end
    isPreviewing = false
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNetEvent("sk_helmet:setHelmet", function(src, propId, drawable, texture)
    local player = GetPlayerFromServerId(src)
    if player ~= -1 then
        local ped = GetPlayerPed(player)
        if drawable == -1 then
            ClearPedProp(ped, propId)
        else
            SetPedPropIndex(ped, propId, drawable, texture or 0, true)
        end
    end
end)

RegisterNetEvent("sk_helmet:loadHelmet", function(helmetId)
    currentHelmet = helmetId or 0
end)
