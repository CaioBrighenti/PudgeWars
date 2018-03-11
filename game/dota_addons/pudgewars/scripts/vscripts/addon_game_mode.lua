-- Generated from template
require('lib/notifications')
require('lib/timers')
require('pudgewars')
require('hook')
--require('sf')
require('util')
--require('physics')
require('abilities')
require('pudge')
require('functions')
require('runes')
----Stats: By Jimmydorry/SinZ/Ash47
--require('lib.statcollection')
----Load helper: By Ash47
--require('lib.loadhelper')

function Precache(context)
	print("starting precache")

	LinkLuaModifier("modifier_command_restricted", "modifiers/modifier_command_restricted.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_fire_rune", "modifiers/modifier_fire_rune.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_shield_rune", "modifiers/modifier_shield_rune.lua", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_slow_rune", "modifiers/modifier_slow_rune.lua", LUA_MODIFIER_MOTION_NONE)

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
 
	print("ASYNCPRECACHE DONE!!")
end

-- Create the game mode when we activate
function Activate()
	GameRules.PW = PudgeWarsMode()
	GameRules.PW:InitGameMode()
end
