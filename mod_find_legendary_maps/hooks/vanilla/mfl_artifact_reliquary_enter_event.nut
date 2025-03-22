// Marks reliquary as completed for mod purposes
::ModFindLegendaryMaps.Hooks.hook("scripts/events/events/location/artifact_reliquary_enter_event", function(q) {
    q.create = @(__original) function () {
        __original();
        foreach(screen in this.m.Screens) {
            if(screen.ID == "Victory") {
                local original = screen.start;
                screen.start = function (_event) {
                    original(_event);
                    this.World.Statistics.mfl_markLocationVisited("location.artifact_reliquary");
                    this.World.Assets.mfl_cleanUpMaps();
                }
                break;
            }
        }
    }
});
