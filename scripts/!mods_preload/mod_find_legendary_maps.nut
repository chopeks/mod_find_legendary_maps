::ModFindLegendaryMaps <- {
	ID = "mod_find_legendary_maps",
	Name = "Find Legendary Location Maps",
	Version = "0.1.2",
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

	local locations = ::ModFindLegendaryMaps.Locations;
	locations.push({ Target = "location.ancient_statue", Name = "Ancient Statue" });
	locations.push({ Target = "location.ancient_temple", Name = "Ancient Temple" });
	locations.push({ Target = "location.ancient_watchtower", Name = "Ancient Spire" });
	locations.push({ Target = "location.black_monolith", Name = "Black Monolith" });
	locations.push({ Target = "location.fountain_of_youth", Name = "Grotesque Tree" });
	locations.push({ Target = "location.icy_cave_location", Name = "Icy Cave" });
	locations.push({ Target = "location.kraken_cult", Name = "Stone Pillars" });
	locations.push({ Target = "location.land_ship", Name = "Curious Ship Wreck" });
	locations.push({ Target = "location.sunken_library", Name = "Sunken Library" });
	locations.push({ Target = "location.tundra_elk_location", Name = "Hunting Ground" });
	locations.push({ Target = "location.unhold_graveyard", Name = "Unhold Graveyard" });
	locations.push({ Target = "location.goblin_city", Name = "Rul\'gazhix" });
	locations.push({ Target = "location.waterwheel", Name = "Watermill" });
	locations.push({ Target = "location.witch_hut", Name = "Witch Hut" });
	locations.push({ Target = "location.holy_site.meteorite", Name = "The Fallen Star" });
	locations.push({ Target = "location.holy_site.oracle", Name = "The Oracle" });
	locations.push({ Target = "location.holy_site.vulcano", Name = "The Ancient City" });

	foreach (file in ::IO.enumerateFiles("hooks/"))
		::include(file);

	::ModFindLegendaryMaps.hasLegends = ::mods_getRegisteredMod("mod_legends") != null;
	if (::ModFindLegendaryMaps.hasLegends) {
		::logInfo("Legends detected, applying patch");
		local settingBlackmarket = page.addBooleanSetting(
		"EnableBlackmarket",
			false,
			"Available at blackmarket",
			"Works, but there might be doubles available, keep that in mind."
		);

		settingBlackmarket.addCallback(function(_value) { ::ModFindLegendaryMaps.BlackMarket = _value; });

		locations.push({ Target = "location.legend_mummy", Name = "Ancient Mastaba" });
		locations.push({ Target = "location.legend_tournament", Name = "Tournament" });
		locations.push({ Target = "location.legend_wizard_tower", Name = "Teetering Tower" });
		foreach (file in ::IO.enumerateFiles("hooksLegends/"))
			::include(file);
	}

	::ModFindLegendaryMaps.hasSSU = ::mods_getRegisteredMod("mod_sellswords") != null;
	if (::ModFindLegendaryMaps.hasSSU) {
		::logInfo("SSU detected, applying patch");
		locations.push({ Target = "location.crorc_fortress", Name = "Fortress of the Warlord" });
		locations.push({ Target = "location.kriegsgeist_castle", Name = "Kriegsgeist: Castle of Ghastly Screams" });
		locations.push({ Target = "location.dryad_tree", Name = "Yggdrasil" });
		locations.push({ Target = "location.crss_camp", Name = "Mercenary Camp" });
		foreach (file in ::IO.enumerateFiles("hooksSSU/"))
			::include(file);
	}


	::ModFindLegendaryMaps.hasStronghold = ::mods_getRegisteredMod("mod_stronghold") != null;
	if (::ModFindLegendaryMaps.hasStronghold) {
		::logInfo("Stronghold detected, applying patch");
//	mod.hook("scripts/factions/stronghold_player_faction", function(q) {
//		q.updateQuests = @(__original) function() {
//			__original();
//			local locations = this.World.EntityManager.getLocations();
//			foreach(location in locations) {
//				if ((location.m.LocationType & this.Const.World.LocationType.Unique) != 0) {
//					::logInfo("spawned legendary location: " + location.m.TypeID)
//				}
//			}
//			foreach(location in this.World.Statistics.mfl_getNotVisitedLegendaryLocations()) {
//				::logInfo("not visited: " + location.Target)
//			}
//			if (!this.getFlags().has("legendary_location")) {
//				local contract = this.new("scripts/contracts/contracts/rescue_scholars_for_legendary_location_contract");
//				contract.setEmployerID(this.getRandomCharacter().getID());
//				contract.setFaction(this.getID());
//				::World.Contracts.addContract(contract);
//				this.getFlags().add("legendary_location");
//			}
//		}
//	});
	}

	::ModFindLegendaryMaps.generateMap <- function() {
		local notVisitedLocations = [];
		if (::ModFindLegendaryMaps.OnlySpawned) {
			local locations = ::ModFindLegendaryMaps.Locations;
			local spawnedLocations = this.World.EntityManager.mfl_getSpawnedLegendaryLocations();
			foreach (spawned in spawnedLocations) {
				local spawnedLocation = null;
				foreach (location in locations) {
					if (spawned.m.TypeID == location.Target) {
						spawnedLocation = location;
						break;
					}
				}
				if (spawnedLocation != null) {
					notVisitedLocations.push(spawnedLocation);
				}
			}
		} else {
			local locations = ::ModFindLegendaryMaps.Locations;
			local visitedLocations = this.World.Statistics.mfl_getVisitedLegendaryLocations();
			foreach (location in locations) {
				local isVisited = false;
				foreach (visited in visitedLocations) {
					if (visited == location.Target) {
						isVisited = true;
						break;
					}
				}
				if (!isVisited) {
					notVisitedLocations.push(location);
				}
			}
		}
		local notOwnedLocations = [];
		local ownedMaps = this.World.Assets.mfl_getMaps();
		foreach (location in notVisitedLocations) {
			local isOwned = false;
			foreach (owned in ownedMaps) {
				if (owned.m.Target == location.Target) {
					isOwned = true;
					break;
				}
			}
			if (!isOwned) {
				notOwnedLocations.push(location);
			}
		}
		if (notOwnedLocations.len() == 0) {
			return { Target = null, Name = null }
		} else {
			return ::MSU.Array.rand(notOwnedLocations);
		}
	}
});