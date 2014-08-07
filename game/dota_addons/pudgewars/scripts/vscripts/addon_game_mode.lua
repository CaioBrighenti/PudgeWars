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
--		Precache things we know we'll use.  Possible file types include (but not limited to):
	    PrecacheResource( "model", "*.vmdl", context )
	    PrecacheResource( "soundfile", "*.vsndevts", context )
	    PrecacheResource( "particle", "*.vpcf", context )
	    PrecacheResource( "particle_folder", "particles/folder", context )
	    PrecacheUnitByNameSync("npc_dota_hero_pudge", context)
end

--[[
if PudgeWarsMode == nil then
	PudgeWarsMode = class({})
	print("created PW")
end --]]

-- Create the game mode when we activate
function Activate()
	GameRules.PW = PudgeWarsMode()
	GameRules.PW:InitGameMode()
end

