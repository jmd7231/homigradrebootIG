-- Time in seconds until the mapvote is over from
-- when it starts.
SolidMapVote["Config"]["Length"] = 10

-- The time in seconds that the vote will stay on the screen
-- after the winning map has been chosen.
SolidMapVote["Config"]["Post Vote Length"] = 3

-- This option controls the size of the map vote buttons.
-- This will effect how the images look. If your switching from tall to
-- the square option, then the images should look fine. Vice Versa you'll
-- need to get some new pictures because up scaling small images up looks like butt.
-- 1 = Tall and skinny vote buttons
-- 2 = Square vote buttons
SolidMapVote["Config"]["Map Button Size"] = 2

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
SolidMapVote["Config"]["Fair Map Recycling"] = false

-- Setting this to true will display on the map vote button how many
-- times the map was played in the past.
SolidMapVote["Config"]["Show Map Play Count"] = true

-- Setting the option below to true will allow you to manually set the
-- map pool using the table below. Only the maps inside the table will
-- be able to be chosen for the vote.
SolidMapVote["Config"]["Manual Map Pool"] = true
SolidMapVote["Config"]["Map Pool"] = {
	"gm_crazyrooms",
	"gm_cs_office_ext",
	"gm_csgorialto",
	"gm_deschool",
	"gm_apartments_night",
	"gm_asylum",
	"gm_building_v2",
	"gm_funkis_night",
	"gm_house3v4improvednight",
	"gm_marquisclean",
	"gm_militia_big",
	"gm_wick_night",
	"gm_sentimental98v1dusk",
	"ttt_airbus_b3",
	"ttt_bank_change",
	"ttt_diescraper",
	"ttt_clue_2022",
	"zgr_fastfood_a6",
	"ttt_grovestreet_los",
	"ttt_hangar",
	"ttt_plaza_b7",
	"ttt_santamariabeach",
	"ttt_terrortrain_2020_b5",
	"ttt_surface",
    "ttt_rooftops_2016_v1",
    "ttt_cornershop",
    "ttt_depot_fof",
    "ttt_glacier",
    "ttt_hazard",
    "mu_powerhermit",
    "ttt_richland_remix_v1",
    "ttt_scream_v1n",
	"zs_abandonedmall_2025_v5a",
	"zs_adrift_v4",
	"rp_countryestatev1",
	"ttt_a_grassy_place",
	"freeway_thicc_v3_night",
	"hmcd_govnova_reborn",
	"mu_smallotown_v2_13",
	"ttt_warhawk_g2",
	"mu_smallotown_v2_13_night",
	"sm_manhattanmegamallnightv1",
	"gm_snowyisolation_v2",
	"ttt_vegas_casino",



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
SolidMapVote["Config"]["Enable Chat"] = true

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
SolidMapVote["Config"]["Random Mode"] = 2
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
		filename = "gm_crazyrooms",
		displayname = "Crazy Wacky Rooms",
		image = "https://i.imgur.com/a0CaqCQ.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_wick_night",
		displayname = "Wick's House (Night)",
		image = "https://i.imgur.com/z3OThAT.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_csgorialto",
		displayname = "Rialto",
		image = "https://i.imgur.com/Q94xFc1.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_deschool",
		displayname = "School",
		image = "https://i.imgur.com/JBYkXt9.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_apartments_night",
                displayname = "Night Time Apartments",
                image = "https://i.imgur.com/VcX1qCO.jpeg",
                width = 1920,
                height = 1080
	},
	{
		filename = "gm_asylum",
		displayname = "Asylum Center",
		image = "https://i.imgur.com/P9rZTAK.jpeg",
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
		filename = "gm_militia_big",
		displayname = "Milita Base (Bigger)",
		image = "https://i.imgur.com/XLnXSHS.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_building_v2",
		displayname = "Building",
		image = "https://i.imgur.com/IVEDrZ4.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "zgr_fastfood_a6",
		displayname = "Fastfood (Dusk)",
		image = "https://i.imgur.com/onsAAdx.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_funkis_night",
		displayname = "90's Modern House",
		image = "https://i.imgur.com/WvbIMQn.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_house3v4improvednight",
		displayname = "3v4 House (Night)",
		image = "https://i.imgur.com/ne4O0Wz.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_marquisclean",
                displayname = "Paris",
                image = "https://i.imgur.com/XTn1ppK.jpeg",
                width = 1920,
                height = 1080 
	},
	{
		filename = "ttt_diescraper",
		displayname = "Skyscraper",
		image = "https://i.imgur.com/zeSWoVj.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "gm_sentimental98v1dusk",
                displayname = "Sentimental (Dusk)",
                image = "https://i.imgur.com/UDN6DYC.jpeg",
                width = 1920,
                height = 1080
	},
	{
		filename = "ttt_hangar",
                displayname = "Hangar",
                image = "https://i.imgur.com/ycFgmQz.jpeg",
                width = 1920,
                height = 1080	                                                                                                                                                                                                
	},
	{
		filename = "gm_cs_office_ext",
                displayname = "Office (Extended)",
                image = "https://i.imgur.com/eFALwO1.jpeg",
                width = 1920,
                height = 1080 
	},
	{
		filename = "ttt_plaza_b7",
                displayname = "Plaza",
                image = "https://i.imgur.com/mErMDXR.jpeg",
                width = 1920,
                height = 1080
	},
	{
		filename = "ttt_santamariabeach",
		displayname = "Santa Maria Beach",
		image = "https://i.imgur.com/JRHMGEG.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_surface",
		displayname = "Russian Snow Town",
		image = "https://i.imgur.com/nXoRcVP.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_scream_v1n",
		displayname = "Stu Matcher's House",
		image = "https://i.imgur.com/Syc3ig1.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_airbus_b3",
		displayname = "Airbus",
		image = "https://i.imgur.com/G1UMeka.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_grovestreet_los",
		displayname = "Grove Street",
		image = "https://i.imgur.com/nEoUrL2.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_depot_fof",
		displayname = "Depot",
		image = "https://i.imgur.com/phuHyJO.jpeg",
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
		filename = "ttt_rooftops_2016_v1",
		displayname = "2016 Rooftops",
		image = "https://i.imgur.com/N2dVXxk.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_cornershop",
		displayname = "Corner Shop",
		image = "https://i.imgur.com/xORHy3l.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_glacier",
		displayname = "Glacier Base",
		image = "https://i.imgur.com/AtHKLT9.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_hazard",
		displayname = "Hazard Facility",
		image = "https://i.imgur.com/TxoYzyT.jpeg",
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
		image = "https://i.imgur.com/kDbjN0G.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "mu_smallotown_v2_13",
		displayname = "Small Town (Day)",
		image = "https://i.imgur.com/xkkzlzQ.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_vegas_casino",
		displayname = "Vegas",
		image = "https://i.imgur.com/50w29OK.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "hmcd_govnova_reborn",
		displayname = "Govnova Bunker",
		image = "https://i.imgur.com/Hsghqa7.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_clue_2022",
		displayname = "Clue",
		image = "https://i.imgur.com/yd9RMiV.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_bank_change",
		displayname = "Change Bank",
		image = "https://i.imgur.com/wHYTnIY.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "mu_smallotown_v2_13_night",
		displayname = "Small Town (Night)",
		image = "https://i.imgur.com/pIeWWH5.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "freeway_thicc_v3_night",
		displayname = "Freeway (Night)",
		image = "https://i.imgur.com/Ijhuy9h.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "zs_abandonedmall_2025_v5a",
		displayname = "Abandoned Mall",
		image = "https://i.imgur.com/Y8b0nJG.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "ttt_a_grassy_place",
		displayname = "Hunting Lodge",
		image = "https://i.imgur.com/QFveRR7.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "sm_manhattanmegamallnightv1",
		displayname = "Not Abandoned Mall",
		image = "https://i.imgur.com/hSaTZF3.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "zs_adrift_v4",
		displayname = "Adrifted Island",
		image = "https://i.imgur.com/Xa7TNI2.jpeg",
		width = 1920,
		height = 1080
	},
	{
		filename = "rp_countryestatev1",
		displayname = "Country Estate",
		image = "https://i.imgur.com/oJREBFU.jpeg",
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
		filename = "gm_snowyisolation_v2",
		displayname = "Snowed Work Place",
		image = "https://i.imgur.com/RAeoqp9.jpeg",
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
