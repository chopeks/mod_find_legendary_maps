::ModFindLegendaryMaps.Hooks.hook("scripts/entity/world/entity_manager", function(q) {
    q.mfl_getSpawnedLegendaryLocation <- function (_typeID) {
        foreach(location in this.m.Locations) {
            if(location.m.TypeID == _typeID) {
                return location;
            }
        }
        return null;
    }

    q.mfl_getSpawnedLegendaryLocations <- function() {
        local list = [];
        foreach(location in this.m.Locations) {
            if(location != null && location.isLocationType(this.Const.World.LocationType.Unique)) {
                list.push(location);
            }
        }
        return list;
    }
});