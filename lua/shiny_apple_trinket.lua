-- TODO 5: Add question marks above Isaac's Head!
-- TODO 6: Add description mod integration

local tllStatUtils = require("lua.tllStatUtils")

local ShinyApple = {
    ID = Isaac.GetTrinketIdByName("Shiny Apple"),
    stacks = 0,
    maxStacks = 10,
    stackRate = 2,
    decayRate = 1,
    waitframes = 0,
    -- Bonuses
    mult = 1.0,
    tearDelayBonus = 0.15, -- max -1.5
    damageBonus = 0.1,     -- max 1.0
    speedBonus = 0.05,     -- max 0.5
}

function ShinyApple:onUpdate(player)
    -- Normal Trinket Variant
    if player:HasTrinket(ShinyApple.ID) then
        -- Check for multiples (+Golden Variant, +Mom's Box)
        ShinyApple.mult = player:GetTrinketMultiplier(ShinyApple.ID)

        -- Check if the player is doing nothing
        if player.Velocity:Length() <= 0.1 and player.FireDelay <= 0 then
            -- Count time spent doing nothing
            ShinyApple.waitframes = math.min(ShinyApple.waitframes + 1, ShinyApple.maxStacks * 30)
            if ShinyApple.waitframes % 30 == 0 and ShinyApple.stacks < ShinyApple.maxStacks then
                -- Add stacks every second
                ShinyApple.stacks = math.min(ShinyApple.stacks + ShinyApple.stackRate, ShinyApple.maxStacks)
            end
        else
            -- Decrease time while doing anything
            ShinyApple.waitframes = math.max(ShinyApple.waitframes - 1, 0)
            if ShinyApple.waitframes % 30 == 0 and ShinyApple.stacks > 0 then
                -- Decrease a stack every second
                ShinyApple.stacks = math.max(ShinyApple.stacks - ShinyApple.decayRate, 0)
            end
        end

        -- Add Caches
        player:AddCacheFlags(CacheFlag.CACHE_SPEED)
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        player:EvaluateItems()

        -- Update TEARS:
        player.MaxFireDelay = math.max(
            player.MaxFireDelay -
            (ShinyApple.stacks * ShinyApple.tearDelayBonus) * tllStatUtils:totalTearsMult(player) * ShinyApple.mult, 0.25)

        -- Update DAMAGE:
        player.Damage = player.Damage +
            tllStatUtils:totalDmgMult(player) * ShinyApple.stacks * ShinyApple.damageBonus * ShinyApple.mult

        -- Update SPEED:
        player.MoveSpeed = math.min(player.MoveSpeed + ShinyApple.stacks * ShinyApple.speedBonus * ShinyApple.mult, 2.0)
    else
        ShinyApple.stacks = 0
        ShinyApple.waitframes = 0
    end
end

return ShinyApple
