ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Check if membership already exists
function getMembership(identifier)
    local result = MySQL.Sync.fetchAll(
                       'SELECT id FROM gym_memberships WHERE identifier = @identifier',
                       {['@identifier'] = identifier})
    if #result > 0 then return true end
    return false
end

-- Check if membership already exists
ESX.RegisterServerCallback('esx_gym:checkMembership', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local membership = getMembership(xPlayer.getIdentifier())
    cb(membership)
end)

ESX.RegisterServerCallback('esx_gym:buyMembership', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    -- Check if membership already exists
    if getMembership(xPlayer.getIdentifier()) then
        xPlayer.showNotification("You already own a membership")
        cb(false)
        return
    end

    -- Create a new subscription
    MySQL.Async.insert(
        "INSERT INTO gym_memberships (identifier, expire) VALUES (@identifier, FROM_UNIXTIME(@expire))",
        {
            ['@identifier'] = xPlayer.getIdentifier(),
            ['@expire'] = os.time() + (Config.Membership.Expire * 86400)
        }, function()
            xPlayer.showNotification("Thank you for shopping with us")
            cb(true)
        end)
end)
