var playerPanels = {};

var localTeam = Players.GetTeam(Players.GetLocalPlayer())
if (localTeam != 2 && localTeam != 3) {
	HideBattlepass()
}

function HideBattlepass() {
	$.GetContextPanel().style.visibility = "collapse";
	$.Schedule(2.0, HideBattlepass)
}

var toggle = false;
var first_time = false;

var api = {
	base : "http://api.dota2imba.org",
	urls : {
		companions : "/imba/meta/companions",
		modifyDonator : "/imba/meta/modify-donator",
	},

	loadCompanions : function(callback) {
		$.AsyncWebRequest(api.base + api.urls.companions, {
			type : "GET",
			dataType : "json",
			timeout : 5000,
			success : function(obj) {
				if (obj.error || !obj.data || !obj.data.companions)
					$.Msg("Error Loading Companions! " + JSON.stringify(obj.message));
				else {
					$.Msg("Loaded " + obj.data.companions.length + " companions.");
					callback(obj.data.companions);
				}
			},
			error : function(err) {
				$.Msg("Error Loading Companions! " + JSON.stringify(err));
			}
		});
	},

	updateCompanion : function(data, success_callback, error_callback) {
		$.AsyncWebRequest(api.base + api.urls.modifyDonator, {
			type : "POST",
			data : data,
			timeout : 5000,
			success : function(obj) {
				if (obj.error) {
					$.Msg("Error updating companion");
					error_callback();
				} else {
					$.Msg("Updated companion");
					success_callback();
				}
			},
			error : function(err) {
				$.Msg("Error updating companion" + JSON.stringify(err));
				error_callback();
			}
		});
	}
};

function ToggleBattlepass() {
	if (toggle === false) {
		toggle = true;
		if (first_time === false) {
			first_time = true;
			Battlepass();
			HallOfFame("XP");
		}

		if ($("#BattlepassWindow").BHasClass("sethidden")) {
			$("#BattlepassWindow").RemoveClass("sethidden");
		}
		$("#BattlepassWindow").AddClass("setvisible");
	} else {
		toggle = false;
		if ($("#BattlepassWindow").BHasClass("setvisible")) {
			$("#BattlepassWindow").RemoveClass("setvisible");
		}
		$("#BattlepassWindow").AddClass("sethidden");
	}
}

var toggle = false;

function ToggleGameOptions() {
	var bool = "";

	if (toggle === false) {
		toggle = true;
		$("#ImbaGameInfo").style.visibility = "visible";
	} else {
		toggle = false;
		$("#ImbaGameInfo").style.visibility = "collapse";
	}
}

function RefreshBattlepass() {
	if ($("#RefreshBattlepass").BHasClass("Active")) {
		return;
	}

	var childrens = $("#BattlepassInfoContainer").FindChildrenWithClassTraverse("BattlepassRow");
	childrens.forEach(function(e) {
		e.DeleteAsync(0);
	});

	var donator_childrens = $("#DonatorInfoContainer").FindChildrenWithClassTraverse("DonatorRow");
	donator_childrens.forEach(function(e) {
		e.DeleteAsync(0);
	});

	$("#RefreshBattlepass").AddClass("Active");

	$.Schedule(1.0, function() {
		$("#RefreshBattlepass").RemoveClass("Active");
		Battlepass();
	});
}

function SwitchTab(tab) {
	$("#BattlepassInfoContainer").style.visibility = "collapse";
	$("#DonatorInfoContainer").style.visibility = "collapse";
	$("#LeaderboardInfoContainer").style.visibility = "collapse";

	$("#" + tab).style.visibility = "visible";
}

var companions = null;

function Battlepass() {
	var BattlepassRewards = CustomNetTables.GetTableValue("game_options", "battlepass").battlepass;

	api.loadCompanions(function(companions) {
		if (BattlepassRewards === undefined) {
			$.Msg("Battlepass undefined..");
			$.Schedule(1, Battlepass);
			return;
		} else {
			$.Msg("Companions and Battlepass information available");
			GenerateBattlepassPanel(BattlepassRewards, Players.GetLocalPlayer());
//			GenerateCompanionPanel(companions, Players.GetLocalPlayer());
		}
	});

	var plyData = CustomNetTables.GetTableValue("player_table", Game.GetLocalPlayerID());
	$("#XPProgressBar").style.width = plyData.XP / plyData.MaxXP * 100 + '%';
	$("#XPProgressBarLabel").text = plyData.XP + "/" + plyData.MaxXP;
	$("#XPProgressBarLevel").text = $.Localize("battlepass_level") + plyData.Lvl;
}

var companion_changed = false;

function SetCompanion(companion, name, id) {
	if (companion_changed === true) {
		$.Msg("SLOW DOWN BUDDY!");
		return;
	}

	if ($("#CompanionNotification").BHasClass("not_donator")) {
		$("#CompanionNotification").RemoveClass("not_donator");
	}

	if (IsDonator(Game.GetLocalPlayerID()) === false) {
		$("#CompanionNotification").AddClass("not_donator");
		$("#CompanionNotificationLabel").text = $.Localize("companion_not_donator");
		return;
	}

	api.updateCompanion({
		companion_id : id,
		steamid : Game.GetLocalPlayerInfo().player_steamid,
		companion_enabled : true
	}, function() {
		$("#CompanionNotification").AddClass("success");
		$("#CompanionNotificationLabel").text = $.Localize("companion_success") + $.Localize(name) + "!";
		GameEvents.SendCustomGameEventToServer("change_companion", {
			ID : Players.GetLocalPlayer(),
			unit : companion
		});
		$.Schedule(6.0, function() {
			$("#CompanionNotification").RemoveClass("success");
			companion_changed = false;
		});
	}, function() {
		$("#CompanionNotification").AddClass("failure");
		$("#CompanionNotificationLabel").text = $.Localize("companion_error");
		$.Schedule(6.0, function() {
			$("#CompanionNotification").RemoveClass("failure");
			companion_changed = false;
		});
	});

	companion_changed = true;
}

var current_type = "";

function HallOfFame(type) {
	if (current_type == type) {
		$.Msg("Bro don't reload you're fine!");
		return;
	}

	current_type = type;

	for (var i = 1; i <= 10; i++) {
		if (type == "XP") {
			var top_users = CustomNetTables.GetTableValue("top_xp", i.toString());
		} else if (type == "IMR") {
			var top_users = CustomNetTables.GetTableValue("top_imr5v5", i.toString());
		}

		if (top_users === undefined) {
			return;
		}

		if ($("#player_" + i)) {
			$("#player_" + i).DeleteAsync(0);
		}

		var player = $.CreatePanel("Panel", $('#Tops'), "player_" + i);
		player.AddClass("LeaderboardGames");
		var rank = $.CreatePanel("Label", player, "rank_" + i);
		rank.AddClass("LeaderboardRank");
		rank.text = i;

		var steam_id = $.CreatePanel("DOTAAvatarImage", player, "player_steamid_" + i);
		steam_id.AddClass("LeaderboardAvatar");
		steam_id.steamid = top_users.SteamID64;
		steam_id.style.width = "15%";
		steam_id.style.height = "100%";
		steam_id.style.borderLeft = "1px solid white";
		steam_id.style.borderTop = "1px solid white";
		steam_id.style.borderRight = "1px solid white";

		var imbar_container = $.CreatePanel("Panel", player, "imbar_container_" + i);
		imbar_container.AddClass("LeaderboardXP");
		var imbar = $.CreatePanel("ProgressBar", imbar_container, "imbar_" + i);
		imbar.AddClass("imbar-progress-bar");
		imbar.value = top_users.XP / top_users.MaxXP;

		var imbar_lvl = $.CreatePanel("Label", imbar_container, "imbar_lvl" + i);
		imbar_lvl.AddClass("imbar-lvl");
		imbar_lvl.text = "Level: " + top_users.Lvl;

		var imbar_rank = $.CreatePanel("Label", imbar_container, "imbar_rank" + i);
		imbar_rank.AddClass("imbar-rank");
		imbar_rank.text = top_users.title;
		imbar_rank.style.color = top_users.title_color;

		var imbar_xp = $.CreatePanel("Label", imbar_container, "imbar_xp" + i);
		imbar_xp.AddClass("imbar-xp");
		imbar_xp.text = top_users.XP + "/" + top_users.MaxXP;

		var imr = $.CreatePanel("Label", player, "rank_" + i);
		imr.AddClass("LeaderboardIMR");
		imr.text = top_users.IMR_5v5.toFixed([ 0 ]);
	}
}

function ClassBy(type) {
	HallOfFame(type);
}

function SafeToLeave() {
	$("#SafeToLeave").style.visibility = "visible";
}

function ShowImbathrowBar(args) {
	var Parent = $.GetContextPanel().GetParent().GetParent().GetParent()
	var hudElements = Parent.FindChildTraverse("HUDElements");
	// var topbar = hudElements.FindChildTraverse("topbar");

	if (args.imbathrow == true) {
		// topbar.style.visibility = "collapse";
	} else {
		Parent.FindChildTraverse("TopBarScoreboard").style.visibility = "collapse";
		// topbar.style.visibility = "visible";
	}
}

function GenerateBattlepassPanel(BattlepassRewards, player) {
	var i_count = 0;
	var class_option_count = 1;
	var plyData = CustomNetTables.GetTableValue("player_table", player);

	var reward_row = $.CreatePanel("Panel", $('#BattlepassInfoContainer'), "BattlepassRow" + class_option_count + "_"
			+ player);
	reward_row.AddClass("BattlepassRow");

	for (var i = 1; i <= 100; i++) {
		if (BattlepassRewards[i] != undefined) {

			i_count = i_count + 1;

			if (i_count > 10) {
				class_option_count = class_option_count + 1;
				var reward_row = $.CreatePanel("Panel", $('#BattlepassInfoContainer'), "BattlepassRow" + class_option_count + "_" + player);
				reward_row.AddClass("BattlepassRow");
				i_count = 1;
			}

			var reward = $.CreatePanel("Panel", $("#BattlepassRow" + class_option_count + "_" + player), BattlepassRewards[i]);
			reward.AddClass("BattlepassReward");

			// $.Msg(i + " " + BattlepassRewards[i])

			var reward_icon = $.CreatePanel("Panel", reward, BattlepassRewards[i] + "_icon");
			reward_icon.AddClass("BattlepassRewardIcon");
			reward_icon.style.backgroundImage = 'url("file://{images}/custom_game/battlepass/' + BattlepassRewards[i] + '.png")';

			var reward_label = $.CreatePanel("Label", reward, BattlepassRewards[i] + "_label");
			reward_label.AddClass("BattlepassRewardLabel");
			reward_label.text = $.Localize("battlepass_level") + i;

			if (plyData != null) {
				if (i <= plyData.Lvl) {
					var reward_label_unlocked = $.CreatePanel("Label", reward_icon, BattlepassRewards[i] + "_label");
					reward_label_unlocked.AddClass("BattlepassRewardLabelUnlocked");
					reward_label_unlocked.text = $.Localize("#battlepass_" + BattlepassRewards[i]);
				} else {
					reward_icon.AddClass("BattlepassRewardIcon_locked")
					var reward_label_locked = $.CreatePanel("Label", reward_icon, BattlepassRewards[i] + "_label");
					reward_label_locked.AddClass("BattlepassRewardLabelLocked");
					reward_label_locked.text = $.Localize("battlepass_reward_locked");
				}

				// all tooltips only show the last
				// created window...
				// (function () {
				// reward_icon.SetPanelEvent("onmouseover",
				// function() {
				// $.DispatchEvent("DOTAShowTextTooltip",
				// reward_icon, $.Localize("battlepass_"
				// + BattlepassRewards[i]));
				// })
				// reward_icon.SetPanelEvent("onmouseout",
				// function() {
				// $.DispatchEvent(
				// "DOTAHideTextTooltip", reward_icon);
				// })
				// })(reward_icon);
			} else {
				reward_icon.AddClass("BattlepassRewardIcon_locked")
				var reward_label_locked = $.CreatePanel("Label", reward_icon, BattlepassRewards[i] + "_label");
				reward_label_locked.AddClass("BattlepassRewardLabelLocked");
				reward_label_locked.text = $.Localize("battlepass_reward_locked");
			}

			// onmouseover="UIShowTextTooltip(
			// imba_gamemode_settings_tower_power_title_tooltip
			// )"
			// onmouseout="UIHideTextTooltip()">
		}
	}
}

function GenerateCompanionPanel(companions, player) {
	var i_count = 0;
	var class_option_count = 1;

	var donator_row = $.CreatePanel("Panel", $('#DonatorInfoContainer'), "DonatorRow" + class_option_count + "_" + player);
	donator_row.AddClass("DonatorRow");

	// Companion Generator
	var plyData = CustomNetTables.GetTableValue("player_table", Players.GetLocalPlayer());

	/*
	 * if (plyData.companion_enabled == 1) { if
	 * ($("#DonatorOptionsToggle").BHasClass("companion_disabled")) {
	 * $("#DonatorOptionsToggle").RemoveClass("companion_disabled") }
	 * $("#DonatorOptionsToggle").AddClass("companion_enabled")
	 * $("#DonatorOptionsToggleLabel").text = $.Localize("#companion_enabled") }
	 * else { if ($("#DonatorOptionsToggle").BHasClass("companion_enabled")) {
	 * $("#DonatorOptionsToggle").RemoveClass("companion_enabled") }
	 * $("#DonatorOptionsToggle").AddClass("companion_disabled")
	 * $("#DonatorOptionsToggleLabel").text = $.Localize("#companion_disabled") }
	 */

	var companion_unit = [];
	var companion_name = [];
	var companion_id = [];

	// +1 for unique companion (e.g: cookies, baumi,
	// bulldog, icefrog)
	for (var i = 0; i <= companions.length; i++) {
		var newbie = false;
		var vip = false;
		i_count = i_count + 1;

		if (i == companions.length - 1) {
			newbie = true;
		}

		if (companions[i] != undefined) {
			companion_unit[i] = companions[i].file;
			companion_name[i] = companions[i].name;
			companion_id[i] = companions[i].id;
		} else {
			var steamId = Game.GetLocalPlayerInfo().player_steamid;
			if (steamId == "76561198015161808") {
				companion_unit[i] = "npc_imba_donator_companion_cookies";
				vip = true;
			} else if (steamId == "76561198003571172") {
				companion_unit[i] = "npc_imba_donator_companion_baumi";
				vip = true;
			} else if (steamId == "76561198014254115") {
				companion_unit[i] = "npc_imba_donator_companion_icefrog";
				vip = true;
			} else if (steamId == "76561198003571172") {
				companion_unit[i] = "npc_imba_donator_companion_admiral_bulldog";
				vip = true;
			} else if (steamId == "76561198021465788") {
				companion_unit[i] = "npc_imba_donator_companion_suthernfriend";
				vip = true;
			} else {
				return;
			}

			companion_name[i] = $.Localize(companion_unit[i]);
		}

		if (i_count > 5) {
			class_option_count = class_option_count + 1;
			var donator_row = $.CreatePanel("Panel", $('#DonatorInfoContainer'), "DonatorRow" + class_option_count
					+ "_" + player);
			donator_row.AddClass("DonatorRow");
			i_count = 0;
		}

		var companion = $.CreatePanel("Panel", $("#DonatorRow" + class_option_count + "_" + player), companion_name[i]);
		companion.AddClass("DonatorReward");

		var companionpreview = $.CreatePanel("Button", companion, "CompanionPreview_" + i);
		companionpreview.style.width = "100%";
		companionpreview.style.height = "85%";
		companionpreview.BLoadLayoutFromString('<root><Panel><DOTAScenePanel style="width:100%; height:100%;" particleonly="false" unit="' + companion_unit[i.toString()] + '"/></Panel></root>', false, false);
		companionpreview.style.opacityMask = 'url("s2r://panorama/images/masks/hero_model_opacity_mask_png.vtex");'

		if (newbie == true) {
			companionpreview.AddClass("CompanionNew");
		}

		if (vip == true) {
			companionpreview.AddClass("CompanionUnique");
		}

		var companion_unit_name = companion_unit[i];

		/*
		 * This is weird. Seams like panorama v8 has a bug here.
		 * companion_unit_name should be copy-by-value but instead is
		 * copy-by-reference
		 */

		var event = function(ev, name, id) {
			return function() {
				SetCompanion(ev, name, id);
			}
		};

		companionpreview.SetPanelEvent("onactivate", event(companion_unit_name, companion_name[i], companion_id[i]));

		var reward_label = $.CreatePanel("Label", companion, companion_name[i] + "_label");
		reward_label.AddClass("BattlepassRewardLabel");
		reward_label.text = companion_name[i];
	}
}

function ToggleCompanion() {
	if ($("#CompanionNotification").BHasClass("not_donator")) {
		$("#CompanionNotification").RemoveClass("not_donator");
	}

	// check if player is donator; otherwise show advertisement
	if (IsDonator(Game.GetLocalPlayerID()) == false) {
		$("#CompanionNotification").AddClass("not_donator");
		$("#CompanionNotificationLabel").text = $.Localize("companion_not_donator");
		return;
	}

	$.AsyncWebRequest(url, {
		type : 'POST',
		success : function(d) {
			companions = d.data;
			$.Msg("Companion Api Good: " + JSON.stringify(d));
			$("#CompanionNotification").AddClass("success");
			$("#CompanionNotificationLabel").text = $.Localize("companion_success") + $.Localize(name) + "!";
			GameEvents.SendCustomGameEventToServer("change_companion", {
				ID : Players.GetLocalPlayer(),
				unit : companion
			});
			$.Schedule(6.0, function() {
				$("#CompanionNotification").RemoveClass("success");
			});
		},
		data : data,
		error : function(err) {
			$.Msg("Companion Api Error: " + JSON.stringify(err));
			$("#CompanionNotification").AddClass("failure");
			$("#CompanionNotificationLabel").text = $.Localize("companion_error");
			$.Schedule(6.0, function() {
				$("#CompanionNotification").RemoveClass("failure");
			});
		}
	});
}

(function() {
	GameEvents.Subscribe("hall_of_fame", HallOfFame);
	GameEvents.Subscribe("safe_to_leave", SafeToLeave);
})();
