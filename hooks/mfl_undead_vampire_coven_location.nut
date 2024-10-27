// Makes maps guaranteed loot from vampire covens
::ModFindLegendaryMaps.Hooks.hook("scripts/entity/world/locations/undead_vampire_coven_location", function(q) {
    q.onDropLootForPlayer = @(__original) function (_lootTable) {
        _lootTable.push(this.new("scripts/items/misc/mfl_legendary_map"));
        __original(_lootTable);
    }
});