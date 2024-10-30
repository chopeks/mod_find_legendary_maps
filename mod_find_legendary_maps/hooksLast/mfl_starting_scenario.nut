::ModFindLegendaryMaps.Hooks.hookTree("scripts/scenarios/world/starting_scenario", function(q) {
    q.onSpawnPlayer = @(__original) function() {
        __original();
        this.Time.scheduleEvent(this.TimeUnit.Virtual, 10, function ( _tag ) {
            this.World.Events.fire("event.legendary_locations_check_event");
        }, null);
    }
});

