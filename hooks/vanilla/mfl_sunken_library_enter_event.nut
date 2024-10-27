// Marks sunken_library as completed for mod purposes
::ModFindLegendaryMaps.Hooks.hook("scripts/events/events/dlc6/location/sunken_library_enter_event", function(q) {
    q.create = @(__original) function () {
        __original();
        foreach(screen in this.m.Screens) {
            if(screen.ID == "Victory") {
                local original = screen.start;
                screen.start = function (_event) {
                    original(_event);
                    this.World.Statistics.mfl_markLocationVisited("location.sunken_library");
                    this.World.Assets.mfl_cleanUpMaps();
                }
                break;
            }
        }
    }
});
