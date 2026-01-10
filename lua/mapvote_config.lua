-- Time in seconds until the mapvote is over from
-- when it starts.
SolidMapVote["Config"]["Length"] = 25

-- The time in seconds that the vote will stay on the screen
-- after the winning map has been chosen.
SolidMapVote["Config"]["Post Vote Length"] = 5

-- This option controls the size of the map vote buttons.
-- This will effect how the images look. If your switching from tall to
-- the square option, then the images should look fine. Vice Versa you'll
-- need to get some new pictures because up scaling small images up looks like butt.
-- 1 = Tall and skinny vote buttons
-- 2 = Square vote buttons
SolidMapVote["Config"]["Map Button Size"] = 1.0

-- This option allows you to set a time for when the map vote will
-- appear after. The first option must be set to true, then the second
-- option controls how long before it comes up in seconds. Simply math
-- can be used to control the length. The last option sets how long before
-- the vote pops up to show a reminder that it is going to happen.
SolidMapVote["Config"]["Enable Vote Autostart"] = false
SolidMapVote["Config"]["Vote Autostart Delay"] = 60 * 60 -- 60 Minutes
SolidMapVote["Config"]["Autostart Reminder"] = 3 * 60 -- 3 minutes
SolidMapVote["Config"]["Time Left Commands"] = {"!timeleft", "/timeleft", ".timeleft"}

-- This it the prefix for maps you want to unclude into
-- the possible maps for the mapvote.
-- List of typical gamemodes prefixes.
-- ttt  = Trouble in Terrorist Town
-- bhop = Bunny Hop
-- surf = Surf
-- hmcd = Homicide
-- rp   = Role Play
SolidMapVote["Config"]["Map Prefix"] = {"ttt", "rp", "gm", "mu", "hmcd", "de", "cs"}

local namecolor = {
	default = COLOR_WHITE,
	servermanager = Color(255, 50, 55),
	owner = Color(0, 227, 255),
	admin = Color(0, 191, 255),
	veteran = Color(255, 20, 147),
	moderator = Color(124, 252, 0),
	supporter = Color(255, 225, 0),
	servertreuer = Color(178, 34, 34),
	nutzer = Color(65, 105, 225),
	user = Color(230, 230, 250)
}

-- Use this function to give specific players or groups different colored
-- avatar borders on the map vote.
SolidMapVote["Config"]["Avatar Border Color"] = function(ply)
	if ply:IsUserGroup("servermanager") then return HSVToColor(math.sin(2 * RealTime()) * 128 + 127, 1, 1) end
	if ply:IsUserGroup("servertreuer") then return namecolor.servertreuer end

	-- This is the default color
	return color_white
end

-- Use this function to give players more vote power than others.
-- I would personally keep all players at the same power because
-- I beleive in equal vote power, but this is up to you.
SolidMapVote["Config"]["Vote Power"] = function(ply)
	if ply:IsAdmin() then return 1 end -- You can make admin's votes more powerfull

	--[[ Give our supporters the big benefits!
	if ply:IsUserGroup("supporterplus") then
		return 2
	elseif ply:IsUserGroup("sponsor") then
		return 3
	else
		return 1
	end --]]

	-- Default vote power
	-- Would keep this at 1, unless you know what your doing (you"re*)
	return 1
end

-- Enabling this option will give greater a chance to maps
-- that are played less often to be selected in the vote.
-- Disabling it will let the map vote randomly choose maps for the vote.
SolidMapVote["Config"]["Fair Map Recycling"] = true

-- Setting this to true will display on the map vote button how many
-- times the map was played in the past.
SolidMapVote["Config"]["Show Map Play Count"] = true

-- Setting the option below to true will allow you to manually set the
-- map pool using the table below. Only the maps inside the table will
-- be able to be chosen for the vote.
SolidMapVote["Config"]["Manual Map Pool"] = true
SolidMapVote["Config"]["Map Pool"] = {
	"cs_insertion2_dusk",
	"cs_office-unlimited",
	"freeway_thicc_v3",
	"gm_abandoned_factory",
	"gm_apartments_hl2",
	"cs_assault",
	"gm_csgoagency",
	"ttt_winter_v4",
	"gm_hmcd_rooftops",
	"ttt_theship_v1_32s",
	"gm_paradise_resort",
	"gm_wick",
	"mu_smallotown_v2_13",
	"ge_caverns_fix",
	"ttt_airbus_b3",
	"ttt_amsterville_open",
	"ttt_diescraper",
	"ttt_clue_2022",
	"ttt_fastfood_a6",
	"ttt_grovestreet_los",
	"ttt_drugbust",
	"ttt_minecraft_b5_fish_n_ships",
	"ttt_minecraftcity_v5",
	"ttt_terrortrain_2020_b5",
	"zavod",
    "ttt_waterworld_lite",
    "ttt_plaza_b6_ccf",
    "slash_selvage",
    "gm_asylum",
    "ph_scotch",
    "mu_powerhermit",
    "ttt_bank_change",
    "gm_building_v2",
	"gm_deschool",
	"zs_last_mansion_v3",
	"ttt_blackmesa_bahpu",
	"ttt_community_skating_v2a",
	"ttt_cripplecreek",
	"ttt_scream_v1n",
	"cs_militia",
	"ttt_warhawk_g2",
	"ttt_countdown_b1",
	"gm_ridgemont",
	"gm_sentimental98v1",
	"ttt_lookatthatview",
	"ttt_richland_remix_v1",
	"ttt_5c_plaza",
	"ttt_mcisland_b1",
	"ttt_palace_v1",


	-- "ttt_freeway_rain",
	-- "dm_steamlab",
	-- "gm_lilys_bedroom",
	-- "mu_smallotown_v2_13",
	-- "ph_scotch",
	-- "ttt_bank_change",

	-- Maps that need fixing
	-- "gm_church", -- Requires Checks for info_player spawns to be removed
	-- "ttt_pizzeria", -- Buggy NPCs and Players
}

SolidMapVote["Config"]["Construct Map Pool"] = {"gm_construct", "gm_flatgrass", "gm_bigcity_winter_day"}

-- Allow players to use their mics while in the mapvote
SolidMapVote["Config"]["Enable Voice"] = true

-- Allow players to use the chat box while in the mapvote
SolidMapVote["Config"]["Enable Chat"] = false

-- Here you can specify what players can force the mapvote to appear.
SolidMapVote["Config"]["Force Vote Permission"] = function(ply) return ply:IsAdmin() end

-- These commands can be used by players specified above to
-- start the mapvote regarless of the amount of players that rtv
SolidMapVote["Config"]["Force Vote Commands"] = {"!forcertv", "/forcertv", ".forcertv"}

-- This is the percentage of players that need to rtv in order for the vote
-- to come up
SolidMapVote["Config"]["RTV Percentage"] = 0.6

-- This is the time in seconds that must pass before players can begin to RTV
SolidMapVote["Config"]["RTV Delay"] = 60

-- If this is set to true, players will be able to remove their RTV
-- by typing the RTV command again.
SolidMapVote["Config"]["Enable UnVote"] = true

-- These commands will add to rocking the vote.
SolidMapVote["Config"]["Vote Commands"] = {"!rtv", "/rtv", ".rtv"}

-- Set this option to true if you want to ignore the
-- prefix and just use all the maps in your maps folder.
SolidMapVote["Config"]["Ignore Prefix"] = true

-- These commands will open the nomination menu
SolidMapVote["Config"]["Nomination Commands"] = {"!nominate", "/nominate", ".nominate"}

-- Set this option to true if you want players to be able to
-- nominate maps.
SolidMapVote["Config"]["Allow Nominations"] = true

-- You can use this function to only allow certain players to be able to
-- use the nomination system. Open a support ticket if you need assistance
-- setting this up.
SolidMapVote["Config"]["Nomination Permissions"] = function(ply) return true end

-- Set this to true if you want the option to extend the map on the vote
-- Set to false to disable
SolidMapVote["Config"]["Enable Extend"] = true
SolidMapVote["Config"]["Extend Image"] = "http://i.imgur.com/zzBeMid.png"

-- Set this to true if you want the option to choose a random map
-- Set to false to disable
SolidMapVote["Config"]["Enable Random"] = true
-- This option controls how the random button works
-- 1 = Random map will be selected from the maps on the vote menu
-- 2 = Random map will be selected from the entire map pool
SolidMapVote["Config"]["Random Mode"] = 1
SolidMapVote["Config"]["Random Image"] = "http://i.imgur.com/oqeqWhl.png"

-- This is the image for maps that are missing an image
SolidMapVote["Config"]["Missing Image"] = ""
SolidMapVote["Config"]["Missing Image Size"] = {
	width = 1920,
	height = 1080
}

-- In this table you can add information for the map to make it more
-- appealing on the mapvote.
SolidMapVote["Config"]["Specific Maps"] = {
	{
		filename = "ttt_minecraft_b5_fish_n_ships",
		displayname = "Minecraft B5",
		image = "https://i.imgur.com/u2pFlcs.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_wick",
		displayname = "Wick's House",
		image = "https://i.imgur.com/qPwmEke.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_blackmesa_bahpu",
		displayname = "Black Mesa",
		image = "https://i.imgur.com/v0zYPia.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "mu_smallotown_v2_snow",
		displayname = "Small Town (Snow)",
		image = "https://i.imgur.com/xquWM5T.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_csgoagency",
                displayname = "Agency",
                image = "https://i.imgur.com/jOlJpVb.jpeg",
                width = 1920,
                height = 1080
	},
	{
		filename = "gm_deschool",
		displayname = "School",
		image = "https://i.imgur.com/JoPG7Wm.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "mu_powerhermit",
		displayname = "Powerhermit",
		image = "https://i.imgur.com/D0nBUZY.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "cs_militia",
		displayname = "Milita Base",
		image = "https://i.imgur.com/hGBVSnq.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_drugbust",
		displayname = "Meth House",
		image = "https://i.imgur.com/ao4GJpx.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_fastfood_a6",
		displayname = "Fastfood",
		image = "https://i.imgur.com/AZmGWhd.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_clue_xmas",
		displayname = "Clue (Christmas)",
		image = "materials/levels/minecraftb5.jpg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_minecraftcity_v5",
		displayname = "Minecraft City",
		image = "https://i.imgur.com/LGlZOMT.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_theship_v1_32s",
                displayname = "Ship",
                image = "https://i.imgur.com/8sKotVT.jpeg",
                width = 1920,
                height = 1080 
	},
	{
		filename = "ttt_diescraper",
		displayname = "Skyscraper",
		image = "https://i.imgur.com/I6Kvh9U.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_waterworld_lite",
                displayname = "Waterworld",
                image = "https://i.imgur.com/CocAjp4.jpeg",
                width = 1920,
                height = 1080
	},
	{
		filename = "slash_selvage",
                displayname = "Selvage",
                image = "https://i.imgur.com/2E6okNq.jpeg",
                width = 1920,
                height = 1080	                                                                                                                                                                                                
	},
	{
		filename = "gm_asylum",
                displayname = "Asylum",
                image = "https://i.imgur.com/ejCQ1ub.jpeg",
                width = 1920,
                height = 1080 
	},
	{
		filename = "ttt_plaza_b6_ccf",
                displayname = "Plaza",
                image = "https://i.imgur.com/d3o7frt.jpeg",
                width = 1920,
                height = 1080
	},
	{
		filename = "cs_office",
		displayname = "Office",
		image = "https://i.imgur.com/8kVbpdc.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_community_skating_v2a",
		displayname = "Community Iceskating Rink",
		image = "https://i.imgur.com/5N08KiU.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_scream_v1n",
		displayname = "Stu Matcher's House",
		image = "https://i.imgur.com/H9oA0Zd.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_airbus_b3",
		displayname = "Airbus",
		image = "https://i.imgur.com/QZBCtOb.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_grovestreet_los",
		displayname = "Grove Street",
		image = "https://i.imgur.com/1w3FxcH.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_cripplecreek",
		displayname = "Cripple Creek",
		image = "https://i.imgur.com/jSk5dbw.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_terrortrain_2020_b5",
		displayname = "Terror Train",
		image = "https://i.imgur.com/HJNGC9p.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_abandoned_factory",
		displayname = "Abandoned Factory",
		image = "https://i.imgur.com/qa3zbOn.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "cs_assault",
		displayname = "Assault",
		image = "https://i.imgur.com/l9uncGb.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_winter_v4",
		displayname = "Nuclear Facility",
		image = "https://i.imgur.com/AuIpqPu.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_hmcd_rooftops",
		displayname = "Rooftops",
		image = "https://i.imgur.com/u88YPdE.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_warhawk_g2",
		displayname = "Warhawk",
		image = "https://i.imgur.com/VsPfTEG.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ge_caverns_fix",
		displayname = "Subterranean Caverns",
		image = "https://i.imgur.com/SmDLR4i.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "cs_insertion2_dusk",
		displayname = "Insertion II (Fixed)",
		image = "https://i.imgur.com/KJAthSW.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_richland_remix_v1",
		displayname = "Richland Estate",
		image = "https://i.imgur.com/jWRB8pI.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "mu_smallotown_v2_13",
		displayname = "Small Town (Day)",
		image = "https://i.imgur.com/gYI8nD0.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_building_v2",
		displayname = "Office Building",
		image = "https://i.imgur.com/DIgrELg.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_crisis_v1",
		displayname = "Crisis",
		image = "https://i.imgur.com/zG6kEob.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_clue_2022",
		displayname = "Clue",
		image = "https://i.imgur.com/dHWDpkI.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_bank_change",
		displayname = "Bank",
		image = "https://i.imgur.com/aGJXyWJ.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "zs_last_mansion_v3",
		displayname = "Old Mansion",
		image = "https://i.imgur.com/x3f0nLU.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "freeway_thicc_v3",
		displayname = "Freeway",
		image = "https://i.imgur.com/w9wUmsm.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "zavod",
		displayname = "EFT Factory",
		image = "https://i.imgur.com/0o19pTl.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_mcisland_b1",
		displayname = "Minecraft Island",
		image = "https://i.imgur.com/dVOm57G.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_countdown_b1",
		displayname = "Countdown",
		image = "https://i.imgur.com/K0EVl8p.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_apartments_hl2",
		displayname = "Apartments",
		image = "https://i.imgur.com/ldMdurt.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_lookatthatview",
		displayname = "Israel Propaganda Control Center",
		image = "https://i.imgur.com/hNNd7sm.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "cs_office-unlimited",
		displayname = "Office",
		image = "https://i.imgur.com/S2T3jQ8.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_5c_plaza",
		displayname = "5 Cambie Plaza",
		image = "https://i.imgur.com/rjisaC0.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_sentimental98v1",
		displayname = "Sentimental idk bro",
		image = "https://i.imgur.com/CgGGAhP.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ph_scotch",
		displayname = "Scotch",
		image = "https://i.imgur.com/pWp9Az4.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_ridgemont",
		displayname = "Fallen Church",
		image = "https://i.imgur.com/M3JZnqc.jpeg",
		width = 1920,
		height = 1080
	},
}
