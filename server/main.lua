local resourceName = GetCurrentResourceName()
local newspaperFileName = "server/zeitung_content.txt"

local function getNewspaperFilePath()
    return ("%s/%s"):format(GetResourcePath(resourceName), newspaperFileName)
end

local function loadNewspaperContent()
    local filePath = getNewspaperFilePath()
    local file = io.open(filePath, "r")
    if file then
        local content = file:read("*a")
        file:close()
        if content == nil or content:match("^%s*$") then
            return Config.placeholder
        end
        return content
    end
    return Config.placeholder
end

local function saveNewspaperContent(content)
    local filePath = getNewspaperFilePath()
    local file = io.open(filePath, "w")
    if file then
        file:write(content)
        file:close()
    end
end

RegisterNetEvent("tg_newspaper:checkAdmin")
AddEventHandler("tg_newspaper:checkAdmin", function()
    local player = source
    local identifiers = GetPlayerIdentifiers(player)
    local isAdmin = false

    for _, id in ipairs(identifiers) do
        for _, adminId in ipairs(Config.adminIdentifiers) do
            if id == adminId then
                isAdmin = true
                break
            end
        end
        if isAdmin then break end
    end

    TriggerClientEvent('tg_newspaper:adminCheckResult', player, isAdmin)
end)

RegisterServerEvent('tg_newspaper:fetchContentForAdmin')
AddEventHandler('tg_newspaper:fetchContentForAdmin', function()
    local src = source
    local content = loadNewspaperContent()
    TriggerClientEvent('tg_newspaper:sendContentForAdmin', src, content)
end)

RegisterServerEvent('tg_newspaper:fetchContentForPlayer')
AddEventHandler('tg_newspaper:fetchContentForPlayer', function()
    local src = source
    local content = loadNewspaperContent()
    TriggerClientEvent('tg_newspaper:sendContentForPlayer', src, content)
end)

RegisterServerEvent('tg_newspaper:updateContent')
AddEventHandler('tg_newspaper:updateContent', function(content)
    saveNewspaperContent(content)

    TriggerClientEvent('tg_newspaper:viewContent', -1, content)

    if Config.Announce.enabled then
        TriggerClientEvent('tg_newspaper:tg_shownotification', -1, Config.Announce.text)
    end
end)
