::ModFindLegendaryMaps.Hooks.hookTree("scripts/events/event_manager", function(q) {
	q.create = @(__original) function() {
		__original();
		this.addSpecialEvent("event.legend_legendary_locations_check");
	}
});
