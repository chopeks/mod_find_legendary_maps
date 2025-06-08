::ModFindLegendaryMaps.Hooks.hookTree("scripts/scenarios/world/starting_scenario", function(q) {
    q.onSpawnPlayer = @(__original) function() {
        __original();
        if (this.m.ID != "scenario.tutorial") {
            ::Time.scheduleEvent(::TimeUnit.Virtual, 10, function ( _tag ) {
                ::World.Events.fire("event.legendary_locations_check_event");
            }, null);
        } else {
            ::World.Assets.getStash().makeEmptySlots(1);
            ::World.Assets.getStash().add(::new("scripts/items/misc/mfl_legendary_location_check"));
        }
    }
});
