::ModFindLegendaryMaps.Hooks.hookTree("scripts/events/event_manager", function(q) {
	q.create = @(__original) function() {
		__original();
		this.addSpecialEvent("event.legendary_locations_check_event");
	}
});
