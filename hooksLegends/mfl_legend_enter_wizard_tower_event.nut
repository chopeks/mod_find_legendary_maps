// Marks icy cavern as completed for mod purposes
::ModFindLegendaryMaps.Hooks.hook("scripts/events/events/legends/legend_enter_wizard_tower_event", function(q) {
    q.create = @(__original) function () {
        __original();
        foreach(screen in this.m.Screens) {
            if(screen.ID == "D") {
                local original = screen.start;
                screen.start = function (_event) {
                    original(_event);
                    this.World.Statistics.mfl_markLocationVisited("location.legend_tournament");
                    this.World.Assets.mfl_cleanUpMaps();
                }
                break;
            }
        }
    }
});