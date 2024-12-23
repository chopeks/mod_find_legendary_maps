::ModFindLegendaryMaps.Hooks.hook("scripts/items/misc/mfl_legendary_map", function(q) {
    local locations = [
        { Target = "location.crorc_fortress", Name = "Fortress of the Warlord" },
        { Target = "location.kriegsgeist_castle", Name = "Kriegsgeist: Castle of Ghastly Screams" },
        { Target = "location.dryad_tree", Name = "Yggdrasil" },
        { Target = "location.crss_camp", Name = "Mercenary Camp" }
    ];
    foreach(it in locations)
        ::ModFindLegendaryMaps.Locations.push(it);

    q.getLocationScript = @(__original) function (_typeID) {
        switch (_typeID) {
            case "location.crorc_fortress":
                return "scripts/entity/world/locations/crorc_fortress_location";
            case "location.kriegsgeist_castle":
                return "scripts/entity/world/locations/kriegsgeist_location";
            case "location.dryad_tree":
                return "scripts/entity/world/locations/dryad_tree_location";
            case "location.crss_camp":
                return "scripts/entity/world/locations/crss_camp_location";
            default:
                return __original(_typeID);
        }
    }

    q.getAllowedTerrainType = @(__original) function (_typeID) {
        switch(_typeID) {
            case "location.crorc_fortress":
                return [
                    this.Const.World.TerrainType.Plains
                ];
            case "location.kriegsgeist_castle":
                return [
                    this.Const.World.TerrainType.Plains
                ];
            case "location.dryad_tree":
                return [
                    this.Const.World.TerrainType.Forest,
                    this.Const.World.TerrainType.LeaveForest,
                    this.Const.World.TerrainType.AutumnForest
                ];
            case "location.crss_camp":
                return [
                    this.Const.World.TerrainType.Forest,
                    this.Const.World.TerrainType.LeaveForest,
                    this.Const.World.TerrainType.AutumnForest
                ];
            default:
                return __original(_typeID);
        }
    }
});