::ModFindLegendaryMaps.Hooks.hook("scripts/states/world/asset_manager", function(q) {
    q.mfl_getMaps <- function() {
        local items = this.m.Stash.getItems();
        local maps = [];
        foreach(item in items) {
            if (item != null && item.m.ID == "misc.mfl_legendary_map") {
                maps.push(item);
            }
        }
        return maps;
    }

    q.mfl_removeMap <- function(_typeID) {
        foreach(map in this.mfl_getMaps()) {
            if (map.m.Target == _typeID) {
                this.m.Stash.remove(map);
            }
        }
    }

    q.mfl_cleanUpMaps <- function() {
        local visitedLocations = this.World.Statistics.mfl_getVisitedLegendaryLocations();
        foreach(map in this.mfl_getMaps()) {
            foreach(location in visitedLocations) {
                if (map.m.Target == location) {
                    this.m.Stash.remove(map);
                }
            }
        }
    }
});
