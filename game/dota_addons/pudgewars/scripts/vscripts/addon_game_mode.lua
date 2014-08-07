-- Generated from template
require('pudgewars')
require('hook')
require('sf')
require('util')
--require('physics')
require('abilities')
require('pudge')
require('functions')
require('runes')

function Precache( context )
    print("hello")
    --Precache things we know we'll use.  Possible file types include (but not limited to):
    PrecacheUnitByNameSync("npc_dota_hero_pudge", context)
    PrecacheModel("models/heroes/pudge/weapon.vmdl", context ) -- Manually precache a single model
end

-- Create the game mode when we activate
function Activate()
    GameRules.PW = PudgeWarsMode()
    GameRules.PW:InitGameMode()
end

