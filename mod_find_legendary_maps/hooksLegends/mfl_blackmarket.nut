::ModFindLegendaryMaps.Hooks.hook("scripts/entity/world/settlements/buildings/blackmarket_building", function(q) {
    q.fillStash = @(__original) function (_list, _stash, _priceMult, _allowDamagedEquipment = false) {
        if (::ModFindLegendaryMaps.BlackMarket) {
            _list.extend([
                {
                    R = 0, // always spawn
                    P = 40.0, // 14k coins base
                    S = "misc/mfl_legendary_map"
                },
                {
                    R = 0, // always spawn
                    P = 4.0, // 1,4k coins base
                    S = "misc/mfl_named_map"
                }
            ]);
        }
        __original(_list, _stash, _priceMult, _allowDamagedEquipment);
    }
});