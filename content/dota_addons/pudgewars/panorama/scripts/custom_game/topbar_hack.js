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
