"use strict";

var Collapsed = false;
var Hud;
var RadiantBar;
var DireBar;

(function () {
	Hud = $.GetContextPanel().GetParent().GetParent().GetParent()
	RadiantBar = Hud.FindChildTraverse("HUDElements").FindChildTraverse("TopBarRadiantScore")
	DireBar = Hud.FindChildTraverse("HUDElements").FindChildTraverse("TopBarDireScore")
})();

function UpdateScore(table_name, key, data) {
	RadiantBar.text = data.radiant_score;
	DireBar.text = data.dire_score;
}
CustomNetTables.SubscribeNetTableListener("game_score", UpdateScore)

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

function OverrideTopBarHeroImage(args) {
	var arcana_level = args.arcana + 1
	var team = "Radiant"
	if (Players.GetTeam(Players.GetLocalPlayer()) == 3) {
		team = "Dire"
	}

	var panel = FindDotaHudElement(team + "Player" + Players.GetLocalPlayer()).FindChildTraverse("HeroImage")

	if (panel) {OverrideHeroImage(arcana_level, panel)}
}
/*
var team = "Radiant"
if (FindDotaHudElement(team + "Player" + Players.GetLocalPlayer()).FindChildTraverse("HeroImage")) {
	var panel = FindDotaHudElement(team + "Player" + Players.GetLocalPlayer()).FindChildTraverse("HeroImage")
	OverrideHeroImage("1", panel, "pudge", "topbar")
}
*/
function OverrideHeroImage(arcana_level, panel) {
	if (arcana_level != false) {
		// list of heroes wich have arcana implented in imbattlepass
		var newheroimage = $.CreatePanel('Panel', panel, '');
		newheroimage.style.width = "100%";
		newheroimage.style.height = "100%";
		newheroimage.style.backgroundImage = 'url("file://{images}/heroes/npc_dota_hero_pudge_alt' + arcana_level + '.png")';
		newheroimage.style.backgroundSize = "cover";

//		panel.style.border = "1px solid #99ff33";
//		panel.style.boxShadow = "fill lightgreen -4px -4px 8px 8px";

//		var newherolabel = $.CreatePanel('Label', panel, '');
//		newherolabel.AddClass("Arcana")
//		newherolabel.text = "Arcana!"
	}
}

GameEvents.Subscribe("override_hero_image", OverrideTopBarHeroImage);
