local isopenNewspaperLocked = false

RegisterCommand("zeitung", function()
    TriggerServerEvent('tg_newspaper:checkAdmin')
end, false)

RegisterNetEvent('tg_newspaper:adminCheckResult')
AddEventHandler('tg_newspaper:adminCheckResult', function(isAdmin)
    if not isAdmin then
        return
    end

    SetNuiFocus(true, true)

    TriggerServerEvent('tg_newspaper:fetchContentForAdmin')
end)

RegisterNetEvent('tg_newspaper:sendContentForAdmin')
AddEventHandler('tg_newspaper:sendContentForAdmin', function(content)
    SendNUIMessage({
        action = "viewNewspaper",
        content = content
    })

    SendNUIMessage({
        action = "openEditor",
        content = content
    })
end)

local function openNewspaper()
    if isopenNewspaperLocked then
        return
    end

    isopenNewspaperLocked = true

    TriggerServerEvent('tg_newspaper:fetchContentForPlayer')
end

RegisterNetEvent('tg_newspaper:sendContentForPlayer')
AddEventHandler('tg_newspaper:sendContentForPlayer', function(content)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "viewNewspaper",
        content = content
    })
end)

RegisterNUICallback("publish", function(data, cb)
    TriggerServerEvent('tg_newspaper:updateContent', data.content)
    cb("Content published successfully!")
end)

RegisterNUICallback("close", function(_, cb)
    SetNuiFocus(false, false)
    isopenNewspaperLocked = false
    cb("closed")
end)

local function Draw3DText(x, y, z)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    AddTextComponentString(Config.Text3D)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

local function IsPlayerNearProp(propPos)
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)
    local distance = Vdist(playerPos.x, playerPos.y, playerPos.z, propPos.x, propPos.y, propPos.z)
    return distance <= 3.5
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        for _, prop in ipairs(Config.props) do
            local playerPed = PlayerPedId()
            local playerPos = GetEntityCoords(playerPed)
            local propEntity = GetClosestObjectOfType(playerPos.x, playerPos.y, playerPos.z, 2.0, GetHashKey(prop.name), false, false, false)

            if propEntity ~= 0 then
                local propPos = GetEntityCoords(propEntity)

                if propPos then
                    Draw3DText(propPos.x + Config.CoordAdjustments_3DText.x, propPos.y + Config.CoordAdjustments_3DText.y, propPos.z + Config.CoordAdjustments_3DText.z)

                    if IsPlayerNearProp(propPos) then
                        if IsControlJustPressed(0, 38) then -- 38 = E-Taste
                            openNewspaper()
                        end
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('tg_newspaper:tg_shownotification')
AddEventHandler('tg_newspaper:tg_shownotification', function(message)
    tg_shownotification(message)
end)

function tg_shownotification(message)
    local textureDict = "TG_Textures"
    RequestStreamedTextureDict(textureDict, true)

    while not HasStreamedTextureDictLoaded(textureDict) do
        Wait(0)
    end

    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostMessagetext(textureDict, "TG_Logo", false, 0, "TG Newspaper Script", "")

    SetStreamedTextureDictAsNoLongerNeeded(textureDict)
end
