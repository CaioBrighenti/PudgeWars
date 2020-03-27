function CDOTA_BaseNPC:GetFittingColor()
	-- Specially colored item modifiers have priority, in this order
	if self:FindModifierByName("modifier_item_imba_rapier_cursed") then
		return Vector(1,1,1)
	elseif self:FindModifierByName("modifier_item_imba_skadi") then
		return Vector(50,255,255)
	-- Heroes' color is based on attributes
	elseif self:IsHero() then
		
		local hero_color = self:GetHeroColorPrimary()
		if hero_color then
			return hero_color
		end
		
		local r = self:GetStrength()
		local g = self:GetAgility()
		local b = self:GetIntellect()
		local highest = math.max(r, math.max(g,b))
		r = math.max(255 - (highest - r) * 20, 0)
		g = math.max(255 - (highest - g) * 20, 0)
		b = math.max(255 - (highest - b) * 20, 0)
		return Vector(r,g,b)
	
	-- Other units use the default golden glow
	else
		return Vector(253, 144, 63)
	end
end

-- TODO: Merge primary and secondary color in a dimensional table to reduce those to 1 function
function CDOTA_BaseNPC_Hero:GetHeroColorPrimary()
	local heroname = self:GetName()
	local hero_theme =
	{
		["npc_dota_hero_abaddon"] = Vector(164,234,240),
		["npc_dota_hero_abyssal_underlord"] = Vector(170,255,0),
		["npc_dota_hero_alchemist"] = Vector(192,127,35),
		["npc_dota_hero_ancient_apparition"] = Vector(160,249,255),
		["npc_dota_hero_antimage"] = Vector(129,162,255),
		["npc_dota_hero_arc_warden"] = Vector(96,171,198),
		["npc_dota_hero_axe"] = Vector(171,0,0),
		["npc_dota_hero_bane"] = Vector(134,38,151),
		["npc_dota_hero_batrider"] = Vector(253,102,36),
		["npc_dota_hero_beastmaster"] = Vector(255,244,194),
		["npc_dota_hero_bloodseeker"] = Vector(167,10,10),
		["npc_dota_hero_bounty_hunter"] = Vector(255,164,66),
		["npc_dota_hero_brewmaster"] = Vector(181,166,139),
		["npc_dota_hero_bristleback"] = Vector(255,234,206),
		["npc_dota_hero_broodmother"] = Vector(60,255,0),
		["npc_dota_hero_centaur"] = Vector(255,221,180),
		["npc_dota_hero_chaos_knight"] = Vector(255,0,0),
		["npc_dota_hero_chen"] = Vector(190,223,242),
		["npc_dota_hero_clinkz"] = Vector(191,147,17),
		["npc_dota_hero_crystal_maiden"] = Vector(155,214,245),
		["npc_dota_hero_dark_seer"] = Vector(136,145,231),
		["npc_dota_hero_dazzle"] = Vector(235,156,255),
		["npc_dota_hero_death_prophet"] = Vector(173,247,208),
		["npc_dota_hero_disruptor"] = Vector(208,241,255),
		["npc_dota_hero_doom_bringer"] = Vector(239,239,203),
		["npc_dota_hero_dragon_knight"] = Vector(255,90,0),
		["npc_dota_hero_drow_ranger"] = Vector(144,175,195),
		["npc_dota_hero_earth_spirit"] = Vector(204,255,0),
		["npc_dota_hero_earthshaker"] = Vector(255,120,0),
		["npc_dota_hero_elder_titan"] = Vector(148,251,255),
		["npc_dota_hero_ember_spirit"] = Vector(155,113,0),
		["npc_dota_hero_enchantress"] = Vector(255,166,50),
		["npc_dota_hero_enigma"] = Vector(52,73,144),
		["npc_dota_hero_faceless_void"] = Vector(170,85,255),
		["npc_dota_hero_furion"] = Vector(12,255,0),
		["npc_dota_hero_gyrocopter"] = Vector(255,108,0),
		["npc_dota_hero_huskar"] = Vector(254,216,176),
		["npc_dota_hero_invoker"] = Vector(22,53,79),
		["npc_dota_hero_jakiro"] = Vector(160,182,200),
		["npc_dota_hero_juggernaut"] = Vector(255,233,0),
		["npc_dota_hero_keeper_of_the_light"] = Vector(253,255,231),
		["npc_dota_hero_kunkka"] = Vector(64,87,98),
		["npc_dota_hero_legion_commander"] = Vector(255,248,220),
		["npc_dota_hero_leshrac"] = Vector(158,39,219),
		["npc_dota_hero_lich"] = Vector(82,204,226),
		["npc_dota_hero_life_stealer"] = Vector(255,102,0),
		["npc_dota_hero_lina"] = Vector(255,0,0),
		["npc_dota_hero_lion"] = Vector(255,126,0),
		["npc_dota_hero_lone_druid"] = Vector(255,249,161),
		["npc_dota_hero_luna"] = Vector(103,179,238),
		["npc_dota_hero_lycan"] = Vector(212,66,21),
		["npc_dota_hero_magnataur"] = Vector(97,255,246),
		["npc_dota_hero_medusa"] = Vector(174,237,64),
		["npc_dota_hero_meepo"] = Vector(122,70,23),
		["npc_dota_hero_mirana"] = Vector(127,223,254),
		["npc_dota_hero_monkey_king"] = Vector(255,224,100),
		["npc_dota_hero_morphling"] = Vector(88,201,194),
		["npc_dota_hero_naga_siren"] = Vector(0,173,167),
		["npc_dota_hero_necrolyte"] = Vector(225,233,98),
		["npc_dota_hero_nevermore"] = Vector(64,0,0),
		["npc_dota_hero_night_stalker"] = Vector(21,13,50),
		["npc_dota_hero_nyx_assassin"] = Vector(66,41,255),
		["npc_dota_hero_obsidian_destroyer"] = Vector(132,239,223),
		["npc_dota_hero_ogre_magi"] = Vector(255,215,27),
		["npc_dota_hero_omniknight"] = Vector(255,210,179),
		["npc_dota_hero_oracle"] = Vector(231,207,109),
		["npc_dota_hero_phantom_assassin"] = Vector(169,255,250),
		["npc_dota_hero_phantom_lancer"] = Vector(255,234,172),
		["npc_dota_hero_phoenix"] = Vector(255,173,30),
		["npc_dota_hero_puck"] = Vector(236,52,156),
		["npc_dota_hero_pudge"] = Vector(69,58,24),
		["npc_dota_hero_pugna"] = Vector(149,240,109),
		["npc_dota_hero_queenofpain"] = Vector(195,0,0),
		["npc_dota_hero_rattletrap"] = Vector(202,128,0),
		["npc_dota_hero_razor"] = Vector(0,89,255),
		["npc_dota_hero_riki"] = Vector(97,92,255),
		["npc_dota_hero_rubick"] = Vector(32,140,0),
		["npc_dota_hero_sand_king"] = Vector(252,228,94),
		["npc_dota_hero_shadow_demon"] = Vector(250,7,41),
		["npc_dota_hero_shadow_shaman"] = Vector(255,54,0),
		["npc_dota_hero_shredder"] = Vector(255,209,109),
		["npc_dota_hero_silencer"] = Vector(41,167,255),
		["npc_dota_hero_skeleton_king"] = Vector(0,239,135),
		["npc_dota_hero_skywrath_mage"] = Vector(131,248,249),
		["npc_dota_hero_slardar"] = Vector(75,160,247),
		["npc_dota_hero_slark"] = Vector(138,127,221),
		["npc_dota_hero_sniper"] = Vector(251,213,111),
		["npc_dota_hero_spectre"] = Vector(254,98,241),
		["npc_dota_hero_spirit_breaker"] = Vector(42,162,192),
		["npc_dota_hero_storm_spirit"] = Vector(60,125,255),
		["npc_dota_hero_sven"] = Vector(255,248,195),
		["npc_dota_hero_techies"] = Vector(255,210,0),
		["npc_dota_hero_templar_assassin"] = Vector(254,94,162),
		["npc_dota_hero_terrorblade"] = Vector(113,138,184),
		["npc_dota_hero_tidehunter"] = Vector(166,204,220),
		["npc_dota_hero_tinker"] = Vector(66,205,240),
		["npc_dota_hero_tiny"] = Vector(231,175,101),
		["npc_dota_hero_treant"] = Vector(66,142,51),
		["npc_dota_hero_troll_warlord"] = Vector(140,211,252),
		["npc_dota_hero_tusk"] = Vector(43,86,248),
		["npc_dota_hero_undying"] = Vector(151,148,78),
		["npc_dota_hero_ursa"] = Vector(255,195,52),
		["npc_dota_hero_vengefulspirit"] = Vector(146,157,255),
		["npc_dota_hero_venomancer"] = Vector(153,185,108),
		["npc_dota_hero_viper"] = Vector(98,242,111),
		["npc_dota_hero_visage"] = Vector(69,190,180),
		["npc_dota_hero_warlock"] = Vector(255,164,91),
		["npc_dota_hero_weaver"] = Vector(95,123,56),
		["npc_dota_hero_windrunner"] = Vector(156,232,110),
		["npc_dota_hero_winter_wyvern"] = Vector(105,165,255),
		["npc_dota_hero_wisp"] = Vector(207,239,255),
		["npc_dota_hero_witch_doctor"] = Vector(142,143,186),
		["npc_dota_hero_zuus"] = Vector(113,255,250),
	}
	if hero_theme[heroname] then
		return hero_theme[heroname]
	end
	return false
end

function CDOTA_BaseNPC_Hero:GetHeroColorSecondary()
	local heroname = self:GetName()
	local hero_theme =
	{
		["npc_dota_hero_abaddon"] = Vector(55,220,190),
		["npc_dota_hero_abyssal_underlord"] = Vector(255,255,127),
		["npc_dota_hero_alchemist"] = Vector(30,112,57),
		["npc_dota_hero_ancient_apparition"] = Vector(46,118,238),
		["npc_dota_hero_antimage"] = Vector(0,18,255),
		["npc_dota_hero_arc_warden"] = Vector(43,130,210),
		["npc_dota_hero_axe"] = Vector(255,58,58),
		["npc_dota_hero_bane"] = Vector(51,19,54),
		["npc_dota_hero_batrider"] = Vector(255,192,104),
		["npc_dota_hero_beastmaster"] = Vector(89,63,13),
		["npc_dota_hero_bloodseeker"] = Vector(255,0,0),
		["npc_dota_hero_bounty_hunter"] = Vector(255,255,255),
		["npc_dota_hero_brewmaster"] = Vector(155,112,36),
		["npc_dota_hero_bristleback"] = Vector(255,200,83),
		["npc_dota_hero_broodmother"] = Vector(198,255,0),
		["npc_dota_hero_centaur"] = Vector(247,58,0),
		["npc_dota_hero_chaos_knight"] = Vector(247,156,49),
		["npc_dota_hero_chen"] = Vector(199,223,252),
		["npc_dota_hero_clinkz"] = Vector(192,39,12),
		["npc_dota_hero_crystal_maiden"] = Vector(117,175,241),
		["npc_dota_hero_dark_seer"] = Vector(71,75,248),
		["npc_dota_hero_dazzle"] = Vector(75,37,94),
		["npc_dota_hero_death_prophet"] = Vector(51,0,77),
		["npc_dota_hero_disruptor"] = Vector(105,176,255),
		["npc_dota_hero_doom_bringer"] = Vector(243,48,0),
		["npc_dota_hero_dragon_knight"] = Vector(255,216,0),
		["npc_dota_hero_drow_ranger"] = Vector(165,216,235),
		["npc_dota_hero_earth_spirit"] = Vector(254,241,127),
		["npc_dota_hero_earthshaker"] = Vector(255,60,0),
		["npc_dota_hero_elder_titan"] = Vector(76,255,244),
		["npc_dota_hero_ember_spirit"] = Vector(221,0,0),
		["npc_dota_hero_enchantress"] = Vector(255,214,181),
		["npc_dota_hero_enigma"] = Vector(77,57,136),
		["npc_dota_hero_faceless_void"] = Vector(35,63,120),
		["npc_dota_hero_furion"] = Vector(255,162,0),
		["npc_dota_hero_gyrocopter"] = Vector(255,50,3),
		["npc_dota_hero_huskar"] = Vector(255,140,16),
		["npc_dota_hero_invoker"] = Vector(189,93,30),
		["npc_dota_hero_jakiro"] = Vector(202,250,254),
		["npc_dota_hero_juggernaut"] = Vector(255,25,0),
		["npc_dota_hero_keeper_of_the_light"] = Vector(255,255,255),
		["npc_dota_hero_kunkka"] = Vector(24,48,62),
		["npc_dota_hero_legion_commander"] = Vector(171,80,0),
		["npc_dota_hero_leshrac"] = Vector(119,109,251),
		["npc_dota_hero_lich"] = Vector(150,236,255),
		["npc_dota_hero_life_stealer"] = Vector(67,0,0),
		["npc_dota_hero_lina"] = Vector(251,94,0),
		["npc_dota_hero_lion"] = Vector(249,227,42),
		["npc_dota_hero_lone_druid"] = Vector(223,255,112),
		["npc_dota_hero_luna"] = Vector(156,212,244),
		["npc_dota_hero_lycan"] = Vector(212,154,20),
		["npc_dota_hero_magnataur"] = Vector(0,104,177),
		["npc_dota_hero_medusa"] = Vector(87,205,80),
		["npc_dota_hero_meepo"] = Vector(112,94,100),
		["npc_dota_hero_mirana"] = Vector(127,223,254),
		["npc_dota_hero_monkey_king"] = Vector(255,171,97),
		["npc_dota_hero_morphling"] = Vector(156,181,176),
		["npc_dota_hero_naga_siren"] = Vector(0,71,131),
		["npc_dota_hero_necrolyte"] = Vector(196,190,28),
		["npc_dota_hero_nevermore"] = Vector(11,0,0),
		["npc_dota_hero_night_stalker"] = Vector(0,0,0),
		["npc_dota_hero_nyx_assassin"] = Vector(44,188,255),
		["npc_dota_hero_obsidian_destroyer"] = Vector(141,255,203),
		["npc_dota_hero_ogre_magi"] = Vector(255,72,0),
		["npc_dota_hero_omniknight"] = Vector(228,164,100),
		["npc_dota_hero_oracle"] = Vector(233,183,125),
		["npc_dota_hero_phantom_assassin"] = Vector(39,120,146),
		["npc_dota_hero_phantom_lancer"] = Vector(191,100,19),
		["npc_dota_hero_phoenix"] = Vector(201,76,0),
		["npc_dota_hero_puck"] = Vector(53,140,189),
		["npc_dota_hero_pudge"] = Vector(32,59,14),
		["npc_dota_hero_pugna"] = Vector(198,255,74),
		["npc_dota_hero_queenofpain"] = Vector(255,240,240),
		["npc_dota_hero_rattletrap"] = Vector(202,81,0),
		["npc_dota_hero_razor"] = Vector(250,250,255),
		["npc_dota_hero_riki"] = Vector(158,115,230),
		["npc_dota_hero_rubick"] = Vector(93,140,40),
		["npc_dota_hero_sand_king"] = Vector(255,173,85),
		["npc_dota_hero_shadow_demon"] = Vector(241,12,184),
		["npc_dota_hero_shadow_shaman"] = Vector(255,210,0),
		["npc_dota_hero_shredder"] = Vector(253,100,17),
		["npc_dota_hero_silencer"] = Vector(88,206,255),
		["npc_dota_hero_skeleton_king"] = Vector(0,239,67),
		["npc_dota_hero_skywrath_mage"] = Vector(245,204,81),
		["npc_dota_hero_slardar"] = Vector(101,206,255),
		["npc_dota_hero_slark"] = Vector(154,150,243),
		["npc_dota_hero_sniper"] = Vector(46,46,46),
		["npc_dota_hero_spectre"] = Vector(90,34,85),
		["npc_dota_hero_spirit_breaker"] = Vector(23,231,213),
		["npc_dota_hero_storm_spirit"] = Vector(98,247,255),
		["npc_dota_hero_sven"] = Vector(252,241,152),
		["npc_dota_hero_techies"] = Vector(255,229,218),
		["npc_dota_hero_templar_assassin"] = Vector(255,144,238),
		["npc_dota_hero_terrorblade"] = Vector(137,188,224),
		["npc_dota_hero_tidehunter"] = Vector(92,180,173),
		["npc_dota_hero_tinker"] = Vector(134,229,253),
		["npc_dota_hero_tiny"] = Vector(25,12,12),
		["npc_dota_hero_treant"] = Vector(79,123,98),
		["npc_dota_hero_troll_warlord"] = Vector(107,255,246),
		["npc_dota_hero_tusk"] = Vector(93,173,255),
		["npc_dota_hero_undying"] = Vector(133,207,109),
		["npc_dota_hero_ursa"] = Vector(204,0,0),
		["npc_dota_hero_vengefulspirit"] = Vector(52,143,255),
		["npc_dota_hero_venomancer"] = Vector(157,247,28),
		["npc_dota_hero_viper"] = Vector(33,85,38),
		["npc_dota_hero_visage"] = Vector(143,230,180),
		["npc_dota_hero_warlock"] = Vector(255,84,0),
		["npc_dota_hero_weaver"] = Vector(150,100,78),
		["npc_dota_hero_windrunner"] = Vector(232,209,110),
		["npc_dota_hero_winter_wyvern"] = Vector(209,238,255),
		["npc_dota_hero_wisp"] = Vector(72,79,255),
		["npc_dota_hero_witch_doctor"] = Vector(127,97,161),
		["npc_dota_hero_zuus"] = Vector(113,150,255),
	}
	if hero_theme[heroname] then
		return hero_theme[heroname]
	end
	return false
end

function CDOTA_BaseNPC:GetNetworth()
	if not self:IsRealHero() then return 0 end
	local gold = self:GetGold()

	-- Iterate over item slots adding up its gold cost
	for i = 0, 15 do
		local item = self:GetItemInSlot(i)
		if item then
			gold = gold + item:GetCost()
		end
	end

	return gold
end
