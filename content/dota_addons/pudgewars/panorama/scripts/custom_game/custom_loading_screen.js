"use strict";

var view = {
	title: $("#loading-title-text"),
	text: $("#loading-content-text"),
	map: $("#loading-map-text"),
	link: $("#loading-link"),
	link_text:  $("#loading-link-text")
};

var link_targets = "";

function ucwords (str) {
	return (str + '').replace(/^(.)|\s+(.)/g, function ($1) {
		return $1.toUpperCase();
	});
}

function info_already_available() {
	return Game.GetMapInfo().map_name != "";
}

function isInt(n) {
   return n % 1 === 0;
}

function fetch() {
	// if data is not available yet, reschedule
	if (!info_already_available()) {
		$.Schedule(0.1, fetch);
		return;
	}

	var game_options = CustomNetTables.GetTableValue("game_options", "game_version");

	if (game_options == undefined || game_options.value == undefined) {
		$.Schedule(0.1, fetch);
		return;
	}

	var game_version = game_options.value;

	if (isInt(game_version))
		game_version = game_version.toString() + ".0";

	game_version = game_version.toFixed(2);

	view.title.text = $.Localize("#addon_game_name") + " " + game_version;
	view.text.text = $.Localize("#loading_screen_description");
	view.link_text.text = $.Localize("#loading_screen_button");

//	$.Msg("Fetching and setting loading screen data");
	
	var mapInfo = Game.GetMapInfo();
	var map_name = ucwords(mapInfo.map_display_name.replace('_', " "));

	view.map.text = map_name;
/*
	api.resolve_map_name(mapInfo.map_display_name).then(function (data) {
		view.map.text = data;
	}).catch(function (err) {
		$.Msg("Failed to resolve map name: " + err.message);
		view.map.text = map_name;
	});

	api.loading_screen().then(function (data) {
		var lang = $.Language();
		var rdata = data.languages["en"];

		if (data.languages[lang] !== undefined)
			rdata = data.languages["en"];

		view.title.text = rdata.title;
		view.text.text = rdata.text;
		view.link_text.text = rdata.link_text;

		view.link.SetPanelEvent("onactivate", function() {
			$.DispatchEvent("DOTADisplayURL", rdata.link_value || "");
		});
		
	}).catch(function (reason) {
		$.Msg("Loading Loading screen information failed");
		$.Msg(reason);

		view.text.text = "News currently unavailable.";
	});
	*/
	/*
	var player_info = Game.GetPlayerInfo(Game.GetLocalPlayerID());
	
	api.player_info(player_info.player_steamid).then(function (data) {
		// TODO: do sth with the data
	}).catch(function (reason) {
		$.Msg("Loading player info for loading screen failed!")
		$.Msg(reason);
	});
	*/
};

function HoverableLoadingScreen() {
	if (Game.GameStateIs(2))
		$.GetContextPanel().style.zIndex = "1";
	else
		$.Schedule(1.0, HoverableLoadingScreen)
}

function OnVoteButtonPressed(category, vote)
{
//	$.Msg("Category: ", category);
//	$.Msg("Vote: ", vote);
	GameEvents.SendCustomGameEventToServer( "setting_vote", { "category":category, "vote":vote } );
}

function OnVotesReceived(data)
{
//	$.Msg(data)
//	$.Msg(data.vote.toString())
//	$.Msg(data.table)

//	$.Msg(data.table2)

	var vote_count = []
	vote_count[1] = 0;
	vote_count[2] = 0;
	vote_count[3] = 0;
	vote_count[4] = 0;
	vote_count[5] = 0;

	var map_name_cut = Game.GetMapInfo().map_display_name.replace('_', " ");

	// Reset tooltips
	for (var i = 1; i <= 3; i++) {
		$("#VoteGameModeText" + i).text = map_name_cut + " " + $.Localize("#vote_gamemode_" + i);
	}

	// Check number of votes for each gamemodes
	for (var id in data.table2){
		var gamemode = data.table2[id]
		vote_count[gamemode]++;
	}

	// Modify tooltips based on voted gamemode
	for (var i = 1; i <= 3; i++) {
		var vote_tooltip = "vote"
		if (vote_count[i] > 1)
			vote_tooltip = "votes"
		$("#VoteGameModeText" + i).text = $.Localize("#vote_gamemode_" + i) + " (" + vote_count[i] + " "+ vote_tooltip +")";
	}

//	if (data.category == "creep_lanes") {

//	}
}
/*
function SetGameModeTooltips() {
	// if data is not available yet, reschedule
	if (!info_already_available()) {
		$.Schedule(0.1, SetGameModeTooltips);
		return;
	}

	var map_name_cut = Game.GetMapInfo().map_display_name.replace('_', " ");
	for (var i = 1; i <= 3; i++) {
		$("#VoteGameModeText" + i).text = map_name_cut + " " + $.Localize("#vote_gamemode_" + i) + " (0 vote)";
	}
}
*/
(function(){
	HoverableLoadingScreen();
	fetch();
//	SetGameModeTooltips();

	GameEvents.Subscribe("send_votes", OnVotesReceived);
})();
