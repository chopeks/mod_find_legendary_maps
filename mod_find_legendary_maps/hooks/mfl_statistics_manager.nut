::ModFindLegendaryMaps.Hooks.hook("scripts/statistics/statistics_manager", function(q) {
    q.m.LegendaryLocationsVisited <- [];

    q.onDeserialize = @(__original) function(_in) {
        this.m.LegendaryLocationsVisited = ::ModFindLegendaryMaps.Mod.Serialization
            .flagDeserialize("LegendaryLocationsVisited", this.m.LegendaryLocationsVisited, [], this.getFlags());
        __original(_in);
    }

    q.onSerialize = @(__original) function(_out) {
        ::ModFindLegendaryMaps.Mod.Serialization
            .flagSerialize("LegendaryLocationsVisited",  this.m.LegendaryLocationsVisited, this.getFlags());
        __original(_out);
    }

    q.mfl_markLocationVisited <- function(_typeID) {
        this.m.LegendaryLocationsVisited.push(_typeID);
    }

    q.mfl_getVisitedLegendaryLocations <- function() {
        return this.m.LegendaryLocationsVisited;
    }

    q.mfl_getNotVisitedLegendaryLocations <- function() {
        local visitedLocations = this.m.LegendaryLocationsVisited;
        local list = [];
        foreach(location in ::ModFindLegendaryMaps.Locations) {
            if (!(location in visitedLocations)) {
                list.push(location)
            }
        }
        return list;
    }
});