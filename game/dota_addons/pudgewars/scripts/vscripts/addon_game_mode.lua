-- Generated from template
require('components/api/init')
require('components/battlepass/init')

require('lib/adv_log') -- be careful! this library can hide lua errors in rare cases
require('lib/notifications')
require('lib/player')
require('lib/player_resource')
require('lib/rgb_to_hex')
require('lib/timers')
require('lib/wearables_warmful_ancient')

require('internal/util')

require('pudgewars')
require('constants')
require('events')
require('filters')
require('hook')
--require('sf')
require('util')
--require('physics')
require('abilities')
require('pudge')
require('functions')
require('runes')

require('trigger_rune')

----Stats: By Jimmydorry/SinZ/Ash47
--require('lib.statcollection')
----Load helper: By Ash47
--require('lib.loadhelper')

function Precache(context)
	print("starting precache")

	LinkLuaModifier("modifier_ability_points", "components/modifiers/modifier_ability_points.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_command_restricted", "components/modifiers/modifier_command_restricted.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_fire_rune", "components/modifiers/modifier_fire_rune.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_shield_rune", "components/modifiers/modifier_shield_rune.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_campfire", "components/modifiers/modifier_campfire.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_slow_rune", "components/modifiers/modifier_slow_rune.lua", LUA_MODIFIER_MOTION_NONE)

	PrecacheUnitByNameSync("npc_dota_hero_pudge", context)

	PrecacheUnitByNameAsync("npc_dota_hero_life_stealer", context)
	PrecacheUnitByNameAsync("npc_dota_hero_spirit_breaker", context)
	PrecacheUnitByNameAsync("npc_dota_hero_axe", context)
	PrecacheUnitByNameAsync("npc_dota_hero_antimage", context)
	PrecacheUnitByNameAsync("npc_dota_hero_dark_seer", context)
	PrecacheUnitByNameAsync("npc_dota_hero_phoenix", context)
	PrecacheUnitByNameAsync("npc_dota_hero_ember_spirit", context)
	PrecacheUnitByNameAsync("npc_dota_hero_tinker", context)
	PrecacheUnitByNameAsync("npc_dota_hero_bloodseeker", context)
	PrecacheUnitByNameAsync("npc_dota_hero_tiny", context)
	PrecacheUnitByNameAsync("npc_dota_hero_shredder", context)
	PrecacheUnitByNameAsync("npc_dota_hero_earthshaker", context)
	PrecacheUnitByNameAsync("npc_dota_hero_zuus", context)
	PrecacheUnitByNameAsync("npc_dota_hero_razor", context)
	PrecacheUnitByNameAsync("npc_dota_hero_sven", context)
	PrecacheUnitByNameAsync("npc_dota_hero_witch_doctor", context)
	PrecacheUnitByNameAsync("npc_dota_hero_kunkka", context)
	PrecacheUnitByNameAsync("npc_dota_hero_disruptor", context)
	PrecacheUnitByNameAsync("npc_dota_hero_alchemist", context)
	PrecacheUnitByNameAsync("npc_dota_hero_batrider", context)  
	PrecacheUnitByNameAsync("npc_precache_everything", context)
 
	-- Battlepass
	PrecacheResource("model_folder", "models/items/pudge/arcana", context)
	PrecacheResource("particle_folder", "particles/econ/items/pudge/pudge_arcana", context)

	print("ASYNCPRECACHE DONE!!")
end

-- Create the game mode when we activate
function Activate()
	GameRules.PW = PudgeWarsMode()
	GameRules.PW:InitGameMode()
end
