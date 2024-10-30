::ModFindLegendaryMaps.Hooks.hook("scripts/states/world_state", function(q) {
    q.onCombatFinished = @(__original) function() {
        __original();
        this.m.Assets.mfl_cleanUpMaps();
    }
});