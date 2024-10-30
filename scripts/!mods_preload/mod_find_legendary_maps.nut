::ModFindLegendaryMaps <- {
	ID = "mod_find_legendary_maps",
	Name = "Find Legendary Location Maps",
	Version = "0.3.5",
	OnlySpawned = true,
	BlackMarket = false,
	// other mods compat
	hasLegends = false,
	hasSSU = false,
	hasStronghold = false
}

::ModFindLegendaryMaps.Locations <- []

local mod = ::Hooks.register(::ModFindLegendaryMaps.ID, ::ModFindLegendaryMaps.Version, ::ModFindLegendaryMaps.Name);

::ModFindLegendaryMaps.Hooks <- mod;

mod.require("mod_msu >= 1.2.6", "mod_modern_hooks >= 0.4.0");

mod.queue(">mod_msu", ">mod_modern_hooks", ">mod_legends", ">mod_sellswords", ">mod_stronghold",  function() {
	::ModFindLegendaryMaps.Mod <- ::MSU.Class.Mod(::ModFindLegendaryMaps.ID, ::ModFindLegendaryMaps.Version, ::ModFindLegendaryMaps.Name);
	::ModFindLegendaryMaps.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, "https://github.com/chopeks/mod_find_legendary_maps");
	::ModFindLegendaryMaps.Mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);

	local page = ::ModFindLegendaryMaps.Mod.ModSettings.addPage("General");
	local settingOnlySpawned = page.addBooleanSetting(
		"EnableSpawning",
		false,
		"[EXPERIMENTAL] Attempt to spawn",
		"Because of worldgen bugs, there is a possibility, that location was not generated at the start of campaign. This will try to generate them anyway. My tests suggest, that it works for some locations, while other will just refuse to spawn. Use at your own risk. I do not advise to use this settings with ongoing campaign. If checked, it will try to generate maps for locations not present on the map at the moment, so the option for that will be ignored."
	);

	settingOnlySpawned.addCallback(function(_value) { ::ModFindLegendaryMaps.OnlySpawned = !_value; });

	local locations = [ // vanilla locations
		{ Target = "location.ancient_statue", Name = "Ancient Statue" },
		{ Target = "location.ancient_temple", Name = "Ancient Temple" },
		{ Target = "location.ancient_watchtower", Name = "Ancient Spire" },
		{ Target = "location.black_monolith", Name = "Black Monolith" },
		{ Target = "location.fountain_of_youth", Name = "Grotesque Tree" },
		{ Target = "location.icy_cave_location", Name = "Icy Cave" },
		{ Target = "location.kraken_cult", Name = "Stone Pillars" },
		{ Target = "location.land_ship", Name = "Curious Ship Wreck" },
		{ Target = "location.sunken_library", Name = "Sunken Library" },
		{ Target = "location.tundra_elk_location", Name = "Hunting Ground" },
		{ Target = "location.unhold_graveyard", Name = "Unhold Graveyard" },
		{ Target = "location.goblin_city", Name = "Rul\'gazhix" },
		{ Target = "location.waterwheel", Name = "Watermill" },
		{ Target = "location.witch_hut", Name = "Witch Hut" },
		{ Target = "location.holy_site.meteorite", Name = "The Fallen Star" },
		{ Target = "location.holy_site.oracle", Name = "The Oracle" },
		{ Target = "location.holy_site.vulcano", Name = "The Ancient City" }
	];
	foreach(it in locations)
		::ModFindLegendaryMaps.Locations.push(it);

	foreach (file in ::IO.enumerateFiles("mod_find_legendary_maps/hooks/"))
		::include(file);

	::ModFindLegendaryMaps.hasLegends = ::mods_getRegisteredMod("mod_legends") != null;
	if (::ModFindLegendaryMaps.hasLegends) {
		local settingBlackmarket = page.addBooleanSetting(
			"EnableBlackmarket",
			false,
			"Available at blackmarket",
			"Works, but there might be doubles available, keep that in mind."
		);

		settingBlackmarket.addCallback(function(_value) { ::ModFindLegendaryMaps.BlackMarket = _value; });

		foreach (file in ::IO.enumerateFiles("mod_find_legendary_maps/hooksLegends/"))
			::include(file);
	}

	::ModFindLegendaryMaps.hasSSU = ::mods_getRegisteredMod("mod_sellswords") != null;
	if (::ModFindLegendaryMaps.hasSSU) {
		foreach (file in ::IO.enumerateFiles("mod_find_legendary_maps/hooksSSU/"))
			::include(file);
	}


	::ModFindLegendaryMaps.hasStronghold = ::mods_getRegisteredMod("mod_stronghold") != null;
	if (::ModFindLegendaryMaps.hasStronghold) {
		foreach (file in ::IO.enumerateFiles("mod_find_legendary_maps/hooksStronghold/"))
			::include(file);
	}

	::ModFindLegendaryMaps.generateMap <- function() {
		local filteredLocations = [];
		if (::ModFindLegendaryMaps.OnlySpawned) {
			local spawnedLocations = this.World.EntityManager.mfl_getSpawnedLegendaryLocations();
			local locations = ::ModFindLegendaryMaps.Locations;
			foreach (spawned in spawnedLocations) {
				local spawnedLocation = null;
				foreach (location in locations) {
					if (spawned.m.TypeID == location.Target) {
						spawnedLocation = location;
						break;
					}
				}
				if (spawnedLocation != null) {
					filteredLocations.push(spawnedLocation);
				}
			}
		} else {
			local locations = ::ModFindLegendaryMaps.Locations;
			foreach (location in locations) {
				filteredLocations.push(location);
			}
		}
		// filter out visited locations
		local visitedLocations = this.World.Statistics.mfl_getVisitedLegendaryLocations();
		foreach(visited in visitedLocations) {
			foreach(location in filteredLocations) {
				if (location.Target == visited) {
					::MSU.Array.removeByValue(filteredLocations, location);
					break;
				}
			}
		}
		// filter out owned maps
		local ownedMaps = this.World.Assets.mfl_getMaps();
		foreach (owned in ownedMaps) {
			foreach (location in filteredLocations) {
				if (location.Target == owned.m.Target) {
					::MSU.Array.removeByValue(filteredLocations, location);
					break;
				}
			}
		}

		if (filteredLocations.len() == 0) {
			return { Target = "x", Name = null }
		} else {
			return ::MSU.Array.rand(filteredLocations);
		}
	}
});

mod.queue(function () {
	foreach (file in ::IO.enumerateFiles("mod_find_legendary_maps/hooksLast/"))
		::include(file);
}, ::Hooks.QueueBucket.Late);
