::ModFindLegendaryMaps.Hooks.hook("scripts/entity/world/settlement", function(q) {
    q.onUpdateShopList = @(__original) function (_id, _list) {
        if (::ModFindLegendaryMaps.BlackMarket) {
            if (_id == "building.blackmarket") {
                _list.push({
                    R = 0, // always spawn
                    P = 40.0, // 14k coins base
                    S = "misc/mfl_legendary_map"
                });
                _list.push({
                    R = 0, // always spawn
                    P = 4.0, // 1,4k coins base
                    S = "misc/mfl_named_map"
                });
            }
        }
        __original(_id, _list);
    }
});