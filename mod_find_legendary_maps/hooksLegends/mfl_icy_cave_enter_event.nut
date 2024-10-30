// Marks icy_cave_location as completed for mod purposes
::ModFindLegendaryMaps.Hooks.hook("scripts/events/events/dlc4/location/icy_cave_destroyed_event", function(q) {
    q.create = @(__original) function () {
        __original();
        foreach(screen in this.m.Screens) {
            if(screen.ID == "Victory") {
                local original = screen.start;
                screen.start = function (_event) {
                    original(_event);
                    this.World.Statistics.mfl_markLocationVisited("location.icy_cave_location");
                    this.World.Assets.mfl_cleanUpMaps();
                }
                break;
            }
        }
    }
});