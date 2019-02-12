/* global $ */
'use strict';

/*
 * Author: Angel Arena Blackstar Credits: Angel Arena Blackstar
 */

if (typeof module !== 'undefined' && module.exports) {
	module.exports.FindDotaHudElement = FindDotaHudElement;
	module.exports.ColorToHexCode = ColorToHexCode;
	module.exports.ColoredText = ColoredText;
	module.exports.LuaTableToArray = LuaTableToArray;
}

var HudNotFoundException = /** @class */
(function() {
	function HudNotFoundException(message) {
		this.message = message;
	}
	return HudNotFoundException;
}());

function FindDotaHudElement(id) {
	return GetDotaHud().FindChildTraverse(id);
}

function GetDotaHud() {
	var p = $.GetContextPanel();
	while (p !== null && p.id !== 'Hud') {
		p = p.GetParent();
	}
	if (p === null) {
		throw new HudNotFoundException('Could not find Hud root as parent of panel with id: ' + $.GetContextPanel().id);
	} else {
		return p;
	}
}

/**
 * Takes an array-like table passed from Lua that has stringified indices
 * starting from 1 and returns an array of type T containing the elements of the
 * table. Order of elements is preserved.
 */
function LuaTableToArray(table) {
	var array = [];

	for (var i = 1; table[i.toString()] !== undefined; i++) {
		array.push(table[i.toString()]);
	}

	return array;
}

/**
 * Takes an integer and returns a hex code string of the color represented by
 * the integer
 */
function ColorToHexCode(color) {
	var red = (color & 0xff).toString(16);
	var green = ((color & 0xff00) >> 8).toString(16);
	var blue = ((color & 0xff0000) >> 16).toString(16);

	return '#' + red + green + blue;
}

function ColoredText(colorCode, text) {
	return '<font color="' + colorCode + '">' + text + '</font>';
}

/*
 * Author: EarthSalamander #42 Credits: EarthSalamander #42
 */

function IsDonator() {
	var i = 0
	if (CustomNetTables.GetTableValue("game_options", "donators") == undefined) {
		return false;
	}

	var local_steamid = Game.GetLocalPlayerInfo().player_steamid;
	var donators = CustomNetTables.GetTableValue("game_options", "donators");
		
	for (var key in donators) {
		var steamid = donators[key];
		if (local_steamid === steamid)
			return true;
	}

	return false;
}

function IsDeveloper(ID) {
	var i = 0
	if (CustomNetTables.GetTableValue("game_options", "developers") == undefined) {
		return false;
	}

	var local_steamid = Game.GetPlayerInfo(ID).player_steamid;
	var developers = CustomNetTables.GetTableValue("game_options", "developers");
		
	for (var key in developers) {
		var steamid = developers[key];
		if (local_steamid === steamid)
			return true;
	}

	return false;
}

function HideIMR(panel) {
	var map_info = Game.GetMapInfo();
	var imr_panel = panel.FindChildrenWithClassTraverse("es-legend-imr");
	var imr_panel_10v10 = panel.FindChildrenWithClassTraverse("es-legend-imr10v10");

	var hide = function(panels) {
		for ( var i in panels)
			panels[i].style.visibility = "collapse";
	};

	if (map_info.map_display_name == "pudgewars") {
		hide(imr_panel_10v10);
	} else if (map_info.map_display_name == "pudgewars_10v10") {
		hide(imr_panel);
	}
}

function OverrideTopBarHeroImage(args) {
	var arcana_level = args.arcana + 1
	var team = "Radiant"
	if (Players.GetTeam(Players.GetLocalPlayer()) == 3) {
		team = "Dire"
	}

	if (args.panel_type == "topbar") {
		var panel = FindDotaHudElement(team + "Player" + Players.GetLocalPlayer()).FindChildTraverse("HeroImage")
	} else if (args.panel_type == "pick_screen") {
		var panel = FindDotaHudElement("npc_dota_hero_pudge")
	}

	if (panel) {OverrideHeroImage(arcana_level, panel, args.hero_name, args.panel_type)}
}

function OverrideHeroImage(arcana_level, panel, hero_name, panel_type) {
	if (arcana_level != false) {
		// list of heroes wich have arcana implented in imbattlepass
		var newheroimage = $.CreatePanel('Panel', panel, '');
		newheroimage.style.width = "100%";
		newheroimage.style.height = "100%";
		newheroimage.style.backgroundImage = 'url("file://{images}/heroes/npc_dota_hero_' + hero_name + '_alt' + arcana_level + '.png")';
		newheroimage.style.backgroundSize = "cover";

		if (panel_type == "pick_screen") {
			panel.style.border = "1px solid #99ff33";
			panel.style.boxShadow = "fill lightgreen -4px -4px 8px 8px";
			var newherolabel = $.CreatePanel('Label', panel, '');
			newherolabel.AddClass("Arcana")
			newherolabel.text = "Arcana!"
		}
	}
}

GameEvents.Subscribe("override_hero_image", OverrideTopBarHeroImage);
