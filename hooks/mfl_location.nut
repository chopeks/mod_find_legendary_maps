::ModFindLegendaryMaps.Hooks.hook("scripts/entity/world/location", function(q) {
    q.onCombatLost = @(__original) function() {
        foreach (location in ::ModFindLegendaryMaps.Locations) {
            if (this.m.TypeID == location.Target) {
                this.World.Statistics.mfl_markLocationVisited(this.m.TypeID);
                this.World.Assets.mfl_removeMap(this.m.TypeID);
                break;
            }
        }
        this.World.Assets.mfl_removeNamedMap(this.getID());
        __original();
    }
});