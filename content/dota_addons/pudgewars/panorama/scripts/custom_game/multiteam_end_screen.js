"use strict";

(function () {

function EndScoreboard() {
	GameEvents.Subscribe("end_game", function (args) {
		$.Msg(args);

		// Hide all other UI
		var MainPanel = $.GetContextPanel().GetParent().GetParent().GetParent().GetParent()
		MainPanel.FindChildTraverse("topbar").style.visibility = "collapse";
		MainPanel.FindChildTraverse("minimap_container").style.visibility = "collapse";
		MainPanel.FindChildTraverse("lower_hud").style.visibility = "collapse";
//		MainPanel.FindChildTraverse("HudChat").style.visibility = "collapse";
		MainPanel.FindChildTraverse("NetGraph").style.visibility = "collapse";
		MainPanel.FindChildTraverse("quickstats").style.visibility = "collapse";

		// Gather info 
		var playerResults = args.players;
		var serverInfo = args.info;
		var xpInfo = args.xp_info;
		var mapInfo = Game.GetMapInfo();
		var radiantPlayerIds = Game.GetPlayerIDsOnTeam(DOTATeam_t.DOTA_TEAM_GOODGUYS);
		var direPlayerIds = Game.GetPlayerIDsOnTeam(DOTATeam_t.DOTA_TEAM_BADGUYS);

		// Victory Info text
		var victoryMessage = "winning_team_name Victory!";
		var victoryMessageLabel = $("#es-victory-info-text");

		if (serverInfo.winner == 2)
			victoryMessage = victoryMessage.replace("winning_team_name", $.Localize("#DOTA_GoodGuys"));
		else if (serverInfo.winner == 3)
			victoryMessage = victoryMessage.replace("winning_team_name", $.Localize("#DOTA_BadGuys"));
		victoryMessageLabel.text = victoryMessage;

		// Load frequently used panels
		var teamsContainer = $("#es-teams");

		var panels = {
			radiant: $("#es-radiant"),
			dire: $("#es-dire"),
			radiantPlayers: $("#es-radiant-players"),
			direPlayers: $("#es-dire-players"),
		};

		// the panorama xml file used for the player lines
		var playerXmlFile = "file://{resources}/layout/custom_game/multiteam_end_screen_player.xml";

		// sort a player by merging results from server and using getplayerinfo  
		var loadPlayer = function (id) {
			var playerInfo = Game.GetPlayerInfo(id);
			var resultInfo = null;
			var xp = null;

			for (var i in playerResults) {
				if (playerInfo.player_steamid == playerResults[i].steamid)
					resultInfo = playerResults[i];
			}

			$.Msg(xpInfo);
			for (var i in xpInfo) {
				$.Msg(xpInfo[i]);
				
				if (playerInfo.player_steamid == xpInfo[i].steamid)
					xp = xpInfo[i];
			}

			return {
				id: id,
				info: playerInfo,
				result: resultInfo,
				xp: xp
			};
		};
		
		// Load players = sort our data we got from above
		var radiantPlayers = [];
		var direPlayers = [];

		$.Each(radiantPlayerIds, function (id) { radiantPlayers.push(loadPlayer(id)); });
		$.Each(direPlayerIds, function (id) { direPlayers.push(loadPlayer(id)); });

		var createPanelForPlayer = function (player, parent) {
			// Create a new Panel for this player
			var pp = $.CreatePanel("Panel", parent, "es-player-" + player.id);
			pp.AddClass("es-player");
			pp.BLoadLayout(playerXmlFile, false, false);
			var xp_bar = pp.FindChildrenWithClassTraverse("es-player-xp")

			var values = {
				name: pp.FindChildInLayoutFile("es-player-name"),
				avatar: pp.FindChildInLayoutFile("es-player-avatar"),
				hero: pp.FindChildInLayoutFile("es-player-hero"),
				desc: pp.FindChildInLayoutFile("es-player-desc"),
				kills: pp.FindChildInLayoutFile("es-player-k"),
				deaths: pp.FindChildInLayoutFile("es-player-d"),
				assists: pp.FindChildInLayoutFile("es-player-a"),
				imr: pp.FindChildInLayoutFile("es-player-imr"),
				gold: pp.FindChildInLayoutFile("es-player-gold"),
				level: pp.FindChildInLayoutFile("es-player-level"),
				xp: {
					bar: xp_bar,
					progress: pp.FindChildInLayoutFile("es-player-xp-progress"),
					level: pp.FindChildInLayoutFile("es-player-xp-level"),
					rank: pp.FindChildInLayoutFile("es-player-xp-rank"),
					rank_name: pp.FindChildInLayoutFile("es-player-xp-rank-name"),
					earned: pp.FindChildInLayoutFile("es-player-xp-earned")
				}
			};

			// Avatar + Hero Image
			values.avatar.steamid = player.info.player_steamid;
			values.hero.heroname = player.info.player_selected_hero;

			// Steam Name + Hero name
			values.name.text = player.info.player_name;
			values.desc.text = $.Localize(player.info.player_selected_hero);

			// Stats
			values.kills.text = player.info.player_kills;
			values.deaths.text = player.info.player_deaths;
			values.assists.text = player.info.player_assists;
			values.gold.text = player.info.player_gold;
			values.level.text = player.info.player_level;

			// IMR
			$.Msg(player);

			if (player.result != null) {
//				values.imr.style.visibility = "visible";

				if (player.result.imr5v5_calibrating)
					values.imr.text = "TBD";
				else {
					var imr = Math.floor(player.result.imr5v5);
					var diff = Math.floor(player.result.imr5v5_difference);

					if (diff == 0) {
						values.imr.text = imr;
						values.imr.AddClass("es-text-white");
					} else if (diff > 0) {
						values.imr.text = imr + " (+" + diff + ")";
						values.imr.AddClass("es-text-green");
					} else {
						values.imr.text = imr + " (" + diff + ")";
						values.imr.AddClass("es-text-red");
					}
				}
			} else {
				values.imr.text = "N/A";
			}

			// XP
			if (player.result != null) {
				var diff = 0; // placeholder value
//				var diff = player.result.xp_difference;
				var xp = Math.floor(player.result.xp);
				var xpDiff = Math.floor(diff);

				if (xpDiff > 0) {
					values.xp.earned.text = "+" + xpDiff;
					values.xp.earned.AddClass("es-text-green");
				} else if (xpDiff == 0) {
					values.xp.earned.text = "0";
					values.xp.earned.AddClass("es-text-white");
				} else {
					values.xp.earned.text = new String(xpDiff);
					values.xp.earned.AddClass("es-text-red");
				}

				var old_xp = player.xp.progress.xp;
				if (old_xp == undefined || old_xp < 0) {
					$.Msg("XP undefined or below 0")
					old_xp = 0
				}
				var max_xp = player.xp.progress.max_xp;
				var new_xp = (old_xp + diff);
				var progress_bar = new_xp / max_xp * 100;

				$.Schedule(0.8, function () {
					values.xp.level.text = $.Localize("#battlepass_level") + player.xp.level;
					values.xp.rank_name.text = player.xp.title;
					values.xp.rank_name.style.color = player.xp.color;

					// if max level
					if (player.xp.level == 500) {
						values.xp.progress.style.width = "100%";
						values.xp.rank.text = "#42";
					}
					// if not leveling up
					else if (progress_bar >= 0 && progress_bar < 100) {
						values.xp.progress.style.width = progress_bar + "%";
						values.xp.rank.text = progress_bar * 100 / max_xp + "/" + max_xp;
					// else if leveling down
					} else if (progress_bar < 0) {
						values.xp.rank.text = max_xp + "/" + max_xp;
						values.xp.progress.style.width = "100%";

						if (values.xp.bar[0].BHasClass("level-down")) {
							values.xp.bar[0].RemoveClass("level-down")
						}
						values.xp.bar[0].AddClass("level-down")
						values.xp.level.text = "Level down..";
						values.xp.rank.text = "";
						progress_bar = progress_bar + 100;
						values.xp.progress.style.width = progress_bar + "%";
						$.Schedule(2.0, function() {
							var levelup_level = player.xp.level - 1
							var levelup_xp = progress_bar * 100 / max_xp // BUG: max_xp should be the max xp of previous level.
							values.xp.level.text = $.Localize("#battlepass_level") + levelup_level;
							values.xp.rank.text = levelup_xp + "/" + max_xp; // BUG: max_xp should be the max xp of previous level.
						});
					// else if leveling up
					} else {
						values.xp.rank.text = max_xp + "/" + max_xp;
						values.xp.progress.style.width = "100%";

						if (values.xp.bar[0].BHasClass("level-up")) {
							values.xp.bar[0].RemoveClass("level-up")
						}
						values.xp.bar[0].AddClass("level-up")
						values.xp.level.text = "Level up!";
						values.xp.rank.text = "";
						progress_bar = progress_bar -100;
						values.xp.progress.style.width = progress_bar + "%";
						$.Schedule(2.0, function() {
							var levelup_level = player.xp.level + 1
							var levelup_xp = old_xp + diff - max_xp // BUG: max_xp should be the max xp of previous level.
							values.xp.level.text = $.Localize("#battlepass_level") + levelup_level;
							values.xp.rank.text = levelup_xp + "/" + max_xp; // BUG: max_xp should be the max xp of previous level.
						});
					}
				});
			} else {
				values.xp.earned.text = "N/A";
			}
		};

		// Create the panels for the players
		$.Each(radiantPlayers, function (player) {
			createPanelForPlayer(player, panels.radiantPlayers);
		});

		$.Each(direPlayers, function (player) {
			createPanelForPlayer(player, panels.direPlayers);
		});

		// Set Team Score
		$("#es-team-score-radiant").text = new String(serverInfo.radiant_score);
		$("#es-team-score-dire").text = new String(serverInfo.dire_score);
	});
}
	
EndScoreboard()
})();
