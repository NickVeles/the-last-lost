--- The Last Lost Stat Utility Script
local tllStatUtils = {
    colActive = false,       -- Check for Crown of Light effect
    playerHitInRoom = false, -- Check for player getting hit in the room.
}

--- Character Damage Multiplier
local CharDmgMul = {
    [0] = 1.0,   -- PLAYER_ISAAC
    [1] = 1.0,   -- PLAYER_MAGDALENE
    [2] = 1.2,   -- PLAYER_CAIN
    [3] = 1.35,  -- PLAYER_JUDAS
    [4] = 1.05,  -- PLAYER_BLUEBABY
    [5] = 1.0,   -- PLAYER_EVE
    [6] = 1.0,   -- PLAYER_SAMSON
    [7] = 1.5,   -- PLAYER_AZAZEL
    [8] = 1.0,   -- PLAYER_LAZARUS
    [9] = 1.0,   -- PLAYER_EDEN
    [10] = 1.0,  -- PLAYER_THELOST
    [11] = 1.4,  -- PLAYER_LAZARUS2
    [12] = 2.0,  -- PLAYER_BLACKJUDAS
    [13] = 1.0,  -- PLAYER_LILITH
    [14] = 1.2,  -- PLAYER_KEEPER
    [15] = 1.0,  -- PLAYER_APOLLYON
    [16] = 1.5,  -- PLAYER_THEFORGOTTEN
    [17] = 1.0,  -- PLAYER_THESOUL
    [18] = 1.0,  -- PLAYER_BETHANY
    [19] = 1.0,  -- PLAYER_JACOB
    [20] = 1.0,  -- PLAYER_ESAU
    [21] = 1.0,  -- PLAYER_ISAAC_B
    [22] = 0.75, -- PLAYER_MAGDALENE_B
    [23] = 1.2,  -- PLAYER_CAIN_B
    [24] = 1.0,  -- PLAYER_JUDAS_B
    [25] = 1.0,  -- PLAYER_BLUEBABY_B
    [26] = 1.2,  -- PLAYER_EVE_B
    [27] = 1.0,  -- PLAYER_SAMSON_B
    [28] = 1.5,  -- PLAYER_AZAZEL_B
    [29] = 1.0,  -- PLAYER_LAZARUS_B
    [30] = 1.0,  -- PLAYER_EDEN_B
    [31] = 1.3,  -- PLAYER_THELOST_B
    [32] = 1.0,  -- PLAYER_LILITH_B
    [33] = 1.0,  -- PLAYER_KEEPER_B
    [34] = 1.0,  -- PLAYER_APOLLYON_B
    [35] = 1.5,  -- PLAYER_THEFORGOTTEN_B
    [36] = 1.0,  -- PLAYER_BETHANY_B
    [37] = 1.0,  -- PLAYER_JACOB_B
    [38] = 1.5,  -- PLAYER_LAZARUS2_B
    [39] = 1.0,  -- PLAYER_JACOB2_B
    [40] = 1.5,  -- PLAYER_THESOUL_B
}

--- Item Damage Multiplier
local ItemDmgMul = {
    -- [4] = 1.5,   -- Cricket's Head -- !Shareable with [12]
    -- [12] = 1.5,  -- Magic Mushroom -- !Shareable with [4]
    [169] = 2.0, -- Polyphemus
    [182] = 2.3, -- Sacred Heart -- !Shareable with Will2Power
    [245] = 0.8, -- 20/20
    [310] = 2.0, -- Eve's Mascara
    -- [330] = 0.2, -- Soy Milk -- !Gets overriden by [561]
    -- [415] = 2.0, -- Crown of Light -- !ADD TO EXCEPTIONS!
    -- [561] = 0.3, -- Almond Milk -- !Overrides [330]
    [573] = 1.0, -- Immaculate Heart
}

--- Item Tears Multiplier (Fire Delay, Higher = Slower)
local ItemTearsMul = {
    [2] = 2.0,    -- The Inner Eye
    [52] = 2.5,   -- Dr. Fetus
    [118] = 3.0,  -- Brimstone
    [149] = 3.0,  -- Ipecac
    [153] = 2.1,  -- Mutant Spider
    [169] = 2.1,  -- Polyphemus
    [229] = 4.3,  -- Monstro's Lung
    [310] = 1.5,  -- Eve's Mascara
    -- [330] = 0.18, -- Soy Milk -- ! Overriden by [561]
    [531] = 2.0,  -- Haemolacria
    -- [561] = 0.25, -- Almond Milk -- !Overrides [330]
}

--- Callback function that reacts to player getting hit
function tllStatUtils:onHit()
    -- Check for Crown of Light effect
    tllStatUtils.colActive = false
end

--- Callback function that reacts to player reaching a new room
function tllStatUtils:onNewRoom()
    local player = Isaac.GetPlayer(0)
    -- Check for Crown of Light effect.
    if player:HasCollectible(415) and player:GetHearts() >= player:GetMaxHearts() then
        tllStatUtils.colActive = true
    end
end

--- Implements a custom flat damage up (ignoring the tears cap)
--- @param current number The current tears delay of the player.
--- @param tearsUp number Value of the tears up.
--- @return number MaxFireDelay Player's tears up after calculation.
function tllStatUtils:flatTearsUp(current, tearsUp)
    return math.max(30 / ((30 / current) + tearsUp), 0.25)
end

--- Implements a custom damage multiplier indicator.
--- @param player EntityPlayer Player to draw the current multipliers from.
--- @return number mult Total calculated damage multiplier.
function tllStatUtils:totalDmgMult(player)
    -- Player's base damage multiplier
    local mult = CharDmgMul[player:GetPlayerType()] or 1.0

    -- Soy Milk vs Almond Milk
    local hasSoy = player:HasCollectible(330)
    local hasAlmond = player:HasCollectible(561)

    -- Player has both Cricket's Head and Magic Mushroom
    local hasCricketAndMush = player:HasCollectible(4) and player:HasCollectible(12)

    -- Calculate damage multiplier
    for itemID, itemMult in pairs(ItemDmgMul) do
        if player:HasCollectible(itemID) then
            mult = mult * itemMult
        end
    end

    -- Check for Soy/Almond Milk
    if hasAlmond then
        mult = mult * 0.3
    elseif hasSoy then
        mult = mult * 0.2
    end

    -- Negate Magic Mush's damage up if Cricket is present
    if hasCricketAndMush then
        mult = mult * 1.5
    end

    -- Check for the Crown of Light effect
    if tllStatUtils.colActive then
        mult = mult * 2.0
    end

    return mult
end

--- Implements a custom regular damage indicator drawn from the standard formula.
--- @param player EntityPlayer Player to draw the current stats from.
--- @param dmgUp number value of the damage up.
--- @return number damage Effective damage dealt by the player.
function tllStatUtils:effectiveDmg(player, dmgUp)
    return player.Damage + tllStatUtils:totalDmgMult(player) * math.sqrt(dmgUp * 1.2 + 1)
end

--- Implements a custom tears (fire delay) multiplier indicator.
--- @param player EntityPlayer Player to draw the current multipliers from.
--- @return number mult Total calculated tears multiplier.
function tllStatUtils:totalTearsMult(player)
    local mult = 1.0

    -- Soy Milk vs Almond Milk
    local hasSoy = player:HasCollectible(330)
    local hasAlmond = player:HasCollectible(561)

    -- Calculate tears multiplier
    for itemID, mul in pairs(ItemTearsMul) do
        if player:HasCollectible(itemID) then
            mult = mult * mul
        end
    end

    -- Check for Soy/Almond Milk
    if hasAlmond then
        mult = mult * 0.25
    elseif hasSoy then
        mult = mult * 0.18
    end

    return mult
end

return tllStatUtils
