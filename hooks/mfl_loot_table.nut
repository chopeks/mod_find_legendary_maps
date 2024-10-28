// Makes maps guaranteed loot from vampire covens
::ModFindLegendaryMaps.Hooks.hook("scripts/entity/world/locations/undead_vampire_coven_location", function(q) {
    q.onDropLootForPlayer = @(__original) function (_lootTable) {
        _lootTable.push(this.new("scripts/items/misc/mfl_legendary_map"));
        __original(_lootTable);
    }
});
// Makes named maps obtainable in bandit and nomad camps
local namedMapLocations = [
    "scripts/entity/world/locations/bandit_camp_location",
    "scripts/entity/world/locations/bandit_hideout_location",
    "scripts/entity/world/locations/bandit_ruins_location",
    "scripts/entity/world/locations/nomad_hidden_camp_location",
    "scripts/entity/world/locations/nomad_ruins_location",
    "scripts/entity/world/locations/nomad_tent_city_location",
    "scripts/entity/world/locations/nomad_tents_location"
]
foreach (location in namedMapLocations) {
    ::ModFindLegendaryMaps.Hooks.hook(location, function(q) {
        q.onDropLootForPlayer = @(__original) function (_lootTable) {
            if (this.Math.rand(1, 4) == 1)
                _lootTable.push(this.new("scripts/items/misc/mfl_named_map"));
            __original(_lootTable);
        }
    });
}