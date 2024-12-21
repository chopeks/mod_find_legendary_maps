::ModFindLegendaryMaps.Hooks.hook("scripts/items/misc/mfl_legendary_map", function(q) {
    local locations = [
        { Target = "location.legend_mummy", Name = "Ancient Mastaba" },
        { Target = "location.legend_tournament", Name = "Tournament" },
//        { Target = "location.legend_wizard_tower", Name = "Teetering Tower" }
    ];
    foreach(it in locations)
        ::ModFindLegendaryMaps.Locations.push(it);

    q.getLocationScript = @(__original) function (_typeID) {
        switch (_typeID) {
            case "location.legend_mummy":
                return "scripts/entity/world/locations/legendary/legend_mummy_location";
            case "location.legend_tournament":
                return "scripts/entity/world/locations/legendary/legend_tournament_location";
            case "location.legend_wizard_tower":
                return "scripts/entity/world/locations/legendary/legend_wizard_tower_location";
            default:
                return __original(_typeID);
        }
    }

    q.getAllowedTerrainType = @(__original) function (_typeID) {
        switch(_typeID) {
            case "location.legend_mummy":
                return [
                    this.Const.World.TerrainType.Desert
                ];
            case "location.legend_tournament":
                return [
                    this.Const.World.TerrainType.Hills,
                    this.Const.World.TerrainType.Mountains
                ];
            case "location.legend_wizard_tower":
                return [
                    this.Const.World.TerrainType.Hills,
                    this.Const.World.TerrainType.Mountains
                ];
            default:
                return __original(_typeID);
        }
    }
});