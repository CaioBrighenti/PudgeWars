if Battlepass == nil then Battlepass = class({}) end

Battlepass_Player_XP = {}
Battlepass_Player_XP[0] = 0

-- xp needed increased by 500 xp every 25 levels
for i = 1, 1000 do
	Battlepass_Player_XP[i] = Battlepass_Player_XP[i-1] + (500 * (math.floor(i / 25) + 1))
end

DONATOR_COLOR = {}
DONATOR_COLOR[0] = {33, 39, 47} -- Not a donator
DONATOR_COLOR[1] = {135, 20, 20} -- IMBA Lead-Developer
DONATOR_COLOR[2] = {100, 20, 20} -- IMBA Developer
DONATOR_COLOR[3] = {0, 102, 255} -- Administrator
DONATOR_COLOR[4] = {220, 40, 40} -- Ember Donator
DONATOR_COLOR[5] = {218, 165, 32} -- Golden Donator
DONATOR_COLOR[6] = {0, 204, 0} -- Green Donator (basic)
DONATOR_COLOR[8] = {47, 91, 151} -- Salamander Donator (blue)
DONATOR_COLOR[7] = {153, 51, 153} -- Icefrog Donator (purple)
DONATOR_COLOR[9] = {185, 75, 10} -- Gaben Donator
DONATOR_COLOR[10] = {255, 255, 255}

require("components/battlepass/battlepass")
require("components/battlepass/donator")
require("components/battlepass/experience")

ListenToGameEvent('game_rules_state_change', function(keys)
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		Battlepass:Init()
	end
end, nil)

ListenToGameEvent('npc_spawned', function(keys)
	local npc = EntIndexToHScript(keys.entindex)

	if npc:IsRealHero() then
		Battlepass:AddItemEffects(npc)

		local donator_level = api:GetDonatorStatus(npc:GetPlayerID())
--		print("Donator Player ID / status:", npc:GetPlayerID(), donator_level)

		if api:IsDonator(npc:GetPlayerID()) ~= false then
			if donator_level and donator_level > 0 then
				npc:SetCustomHealthLabel("#donator_label_" .. donator_level, DONATOR_COLOR[donator_level][1], DONATOR_COLOR[donator_level][2], DONATOR_COLOR[donator_level][3])
			end

			if donator_level ~= 6 and donator_level ~= 10 then
				Timers:CreateTimer(2.0, function()
					Battlepass:DonatorCompanion(npc:GetPlayerID(), nil)
				end)
			end
		end
	end
end, nil)
