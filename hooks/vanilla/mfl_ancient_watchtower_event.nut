// Marks ancient watchtower as completed for mod purposes
::ModFindLegendaryMaps.Hooks.hook("scripts/events/events/dlc2/location/ancient_watchtower_event", function(q) {
    q.create = @(__original) function () {
        __original();
        foreach(screen in this.m.Screens) {
            if(screen.ID == "A") {
                local original = screen.start;
                screen.start = function (_event) {
                    original(_event);
                    this.World.Statistics.mfl_markLocationVisited("location.ancient_watchtower");
                    this.World.Assets.mfl_cleanUpMaps();
                }
                break;
            }
        }
    }
});
