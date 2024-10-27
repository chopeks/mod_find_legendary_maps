// Marks icy cavern as completed for mod purposes
::ModFindLegendaryMaps.Hooks.hook("scripts/events/events/legends/location/legend_mummy_enter_event", function(q) {
    q.create = @(__original) function () {
        __original();
        foreach(screen in this.m.Screens) {
            if(screen.ID == "Victory") {
                local original = screen.start;
                screen.start = function (_event) {
                    original(_event);
                    this.World.Statistics.mfl_markLocationVisited("location.legend_mummy");
                    this.World.Assets.mfl_cleanUpMaps();
                }
                break;
            }
        }
    }
});