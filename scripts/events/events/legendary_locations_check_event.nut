this.legendary_locations_check_event <- this.inherit("scripts/events/event", {
    m = {},
    function create() {
        this.m.ID = "event.legendary_locations_check_event";
        this.m.Title = "Your friendly legendary location check";
        this.m.Cooldown = 600000 * this.World.getTime().SecondsPerDay;
        this.m.Score = 0;
        this.m.Screens.push({
            ID = "A",
            Text = "[img]gfx/ui/events/event_16.png[/img]",
            Image = "",
            List = [],
            Options = [
            {
                Text = "Gotcha!",
                function getResult( _event ) {
                    this.World.Flags.add("legendary_locations_check_event");
                    return 0;
                }
            }
            ],
            function start( _event ) {
                local spawnedLocations = this.World.EntityManager.mfl_getSpawnedLegendaryLocations();
                local allLocations = ::ModFindLegendaryMaps.Locations;
                local missingLocations = [];
                foreach(location in allLocations) {
                    local isSpawned = false;
                    foreach(spawned in spawnedLocations) {
                        if (location.Target == spawned.m.TypeID) {
                            isSpawned = true;
                            break;
                        }
                    }
                    if(!isSpawned) {
                        missingLocations.push(location);
                    }
                }

                if(missingLocations.len() == 0) {
                    this.Text = "[img]gfx/ui/events/event_16.png[/img] All good. All locations spawned properly.";
                } else {
                    local txt = "[img]gfx/ui/events/event_16.png[/img] These locations are missing:";
                    foreach (location in missingLocations) {
                        txt = txt + "\n" + location.Name;
                    }
                    txt = txt + "\n\nIf you're not concerned about them, you can continue playing.";
                    this.Text = txt
                }
            }

        });
    }

    function onUpdateScore() {
    }

    function onPrepare() {
    }

    function onPrepareVariables( _vars ) {
    }

    function onClear() {
    }

});

