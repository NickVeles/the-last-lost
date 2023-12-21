local mod = RegisterMod("The Last Lost", 1)
local ShinyApple = require("lua.shiny_apple_trinket")
local tllStatUtils = require("lua.tllStatUtils")

-- Shiny Apple Trinket
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, ShinyApple.onUpdate)

-- TODO:
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, tllStatUtils.onNewRoom)
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, tllStatUtils.onHit)