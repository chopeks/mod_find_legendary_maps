this.mfl_legendary_map <- this.inherit("scripts/items/item", {
    m = {
        Target = "location.land_ship"
        LocationName = "Curious Ship Wreck"
    },
    function create() {
        this.m.ID = "misc.mfl_legendary_map";
        this.m.Name = "Legendary location map";
        this.m.Icon = "legendary_map.png";
        this.m.SlotType = this.Const.ItemSlot.None;
        this.m.ItemType = this.Const.Items.ItemType.Usable;
        this.m.IsUsable = true;
        this.m.IsDroppedAsLoot = true;
        this.m.Value = 350;
        this.randomizeLocation();
    }

    function getBuyPrice() {
        if (this.m.IsSold) {
            return this.getSellPrice();
        }
        if (("State" in this.World) && this.World.State != null && this.World.State.getCurrentTown() != null) {
            return this.Math.max(this.getSellPrice(), this.Math.ceil(this.getValue() * this.getPriceMult() * this.World.State.getCurrentTown().getBuyPriceMult() * this.Const.World.Assets.BaseBuyPrice));
        }
        return this.item.getBuyPrice();
    }

    function getSellPrice() {
        if (this.m.IsBought) {
            return this.getBuyPrice();
        }
        if (("State" in this.World) && this.World.State != null && this.World.State.getCurrentTown() != null) {
            return this.Math.floor(this.getValue() * this.World.State.getCurrentTown().getSellPriceMult() * this.Const.World.Assets.BaseSellPrice);
        }
        return this.item.getSellPrice();
    }

    function onUse( _actor, _item = null ) {
        if (this.m.Target == null)
            return false;
        local location = this.World.EntityManager.mfl_getSpawnedLegendaryLocation(this.m.Target);
        if (::ModFindLegendaryMaps.OnlySpawned) {
            if (location == null) {
                local allowedTerrain = this.getAllowedTerrainType(this.m.Target);
                if (allowedTerrain == null) {
                    ::logWarning("allowed terrain undefined for " + this.m.Target);
                    return false;
                }
                local locationScript = this.getLocationScript(this.m.Target);
                if (locationScript == null) {
                    ::logWarning("location script missing for " + this.m.Target);
                    return false;
                }

                local camp;
                local distanceToOthers = 15;
                local disallowedTerrain = [];
                for(local i = 0; i < this.Const.World.TerrainType.COUNT; i = ++i) {
                    if (!(i in allowedTerrain)) {
                        disallowedTerrain.push(i);
                    }
                }

                local tile = this.getTileToSpawnLocation(1000, disallowedTerrain, 7, 1000, 1000, 7, 7, this.World.State.getPlayer().getTile(), distanceToOthers, distanceToOthers);
                if (tile != null) {
                    camp = this.World.spawnLocation(locationScript, tile.Coords);
                }
                if (camp != null) {
                    camp.onSpawned();
                }
                location = this.World.EntityManager.mfl_getSpawnedLegendaryLocation(this.m.Target);
            }
        }

        if (location == null) {
            ::logInfo("Failed to apply map, because " + this.m.Target + " is not spawned");
            return false;
        }

        if (!location.getVisibilityMult()) {
            ::logInfo("Icy Cave frist, then Hunting Grounds.");
            return false;
        }

        this.World.uncoverFogOfWar(location.getPos(), 250.0);
        this.Settings.getTempGameplaySettings().CameraLocked = false
        this.World.State.getMenuStack().popAll(true);
        this.World.getCamera().Zoom = 1.0;
        this.World.getCamera().setPos(location.getPos());

        this.Sound.play("sounds/scribble.wav", this.Const.Sound.Volume.Inventory);
        return false;
    }

    function setLocation(_target, _name) {
        this.m.Target = _target;
        this.m.LocationName = _name;
        if (this.m.Target == null) {
            this.m.Name = "Old map";
            this.m.IsUsable = false;
            this.m.Description = "This map unfortunately is unreadable, though you may be able to find someone to pay hefty sum for it."
        } else {
            this.m.Name = "Legendary location map";
            this.m.IsUsable = true;
            this.m.Description = "This map seems to have marked location and a lot of annotations. After studing it for a moment, you conclude that it might be [color=" + ::Const.UI.Color.PositiveEventValue + "]" + _name + "[/color]";
        }
    }

    function randomizeLocation() {
        local location = ::ModFindLegendaryMaps.generateMap();
        this.setLocation(location.Target, location.Name)
    }

    function onSerialize( _out ) {
        _out.writeString(this.m.Target);
        _out.writeString(this.m.LocationName);
        this.item.onSerialize(_out);
    }

    function onDeserialize( _in ) {
        local target = _in.readString();
        local locationName = _in.readString();
        this.item.onDeserialize(_in);
        this.setLocation(target, locationName)
    }

    function getTileToSpawnLocation(_maxTries = 500, _notOnTerrain = [], _minDistToSettlements = 7, _maxDistToSettlements = 1000, _maxDistanceToAllies = 1000, _minDistToEnemyLocations = 7, _minDistToAlliedLocations = 7, _nearTile = null, _minY = 0.0, _maxY = 1.0 ) {
        local minDistToEnemyLocations = _minDistToEnemyLocations;
        local minDistToAlliedLocations = _minDistToAlliedLocations;
        local mapSize = this.World.getMapSize();
        local navSettings = this.World.getNavigator().createSettings();
        navSettings.ActionPointCosts = this.Const.World.TerrainTypeNavCost;
        navSettings.RoadMult = 1.0;
        local used = [];
        local tries = 0;
        while (minDistToEnemyLocations > 2 && minDistToAlliedLocations > 2) {
            tries = 0;
            while (tries++ < _maxTries) {
                local x;
                local y;

                if (_nearTile != null) {
                    x = this.Math.rand(this.Math.max(3, _nearTile.SquareCoords.X - 10), this.Math.min(mapSize.X - 3, _nearTile.SquareCoords.X + 10));
                    y = this.Math.rand(this.Math.max(3, _nearTile.SquareCoords.Y - 10), this.Math.min(mapSize.Y - 4, _nearTile.SquareCoords.Y + 10));
                } else {
                    x = this.Math.rand(3, mapSize.X - 3);
                    y = this.Math.rand(this.Math.max(3, mapSize.Y * _minY), this.Math.min(mapSize.Y - 4, mapSize.Y * _maxY));
                }

                local tile = this.World.getTileSquare(x, y);
                if (used.find(tile.ID) != null) {
                    continue;
                }

                used.push(tile.ID);

                if (tile.IsOccupied || tile.HasRoad || tile.HasRiver) {
                    continue;
                }

                if (tile.Type == this.Const.World.TerrainType.Ocean || tile.Type == this.Const.World.TerrainType.Shore) {
                    continue;
                }

                if (this.World.State.getPlayer() != null && this.World.State.getPlayer().getTile().getDistanceTo(tile) < 6) {
                    continue;
                }

                local abort = false;

                foreach (t in _notOnTerrain) {
                    if (tile.Type == t) {
                        abort = true;
                        break;
                    }
                }

                if (abort) {
                    continue;
                }

                for (local i = 0; i != 6; i = ++i) {
                    if (tile.hasNextTile(i)) {
                        local next = tile.getNextTile(i);
                        if (next.HasRoad || next.Type == this.Const.World.TerrainType.Ocean || _maxDistanceToAllies > 1000 && next.Type == this.Const.World.TerrainType.Shore) {
                            abort = true;
                            break;
                        }
                    }
                }

                if (abort) {
                    continue;
                }

                local settlements = this.World.EntityManager.getSettlements();
                local dist = 1000;

                foreach (s in settlements) {
                    local d = s.getTile().getDistanceTo(tile);

                    if (d < dist) {
                        dist = d;
                    }
                }

                if (dist < _minDistToSettlements || dist > _maxDistToSettlements) {
                    continue;
                }

                local locations = this.World.EntityManager.getLocations();
                foreach (loc in locations) {
                    local d = tile.getDistanceTo(loc.getTile());
                    if (d < minDistToEnemyLocations) {
                        abort = true;
                        break;
                    }
                }

                if (abort) {
                    continue;
                }



//            if (this.m.Faction.getSettlements().len() != 0 && _maxDistanceToAllies != 0 && _maxDistanceToAllies != 1000) {
//                local dist = 1000;
//                foreach( s in this.m.Faction.getSettlements()) {
//                    local d = s.getTile().getDistanceTo(tile);
//                    if (d < dist) {
//                        dist = d;
//                    }
//                }
//
//                for(; dist > _maxDistanceToAllies; ) {}
//            }

                for (local i = x - 3; i < x + 3; i = ++i) {
                    for (local j = y - 3; j < y + 3; j = ++j) {
                        if (!this.World.isValidTileSquare(i, j)) {
                        } else if (this.World.getTileSquare(i, j).HasRoad) {
                            abort = true;
                            break;
                        }
                    }
                }

                if (abort) {
                    continue;
                }

                abort = true;

                foreach (v in locations) {
                    if (v.isIsolated()) {
                        continue;
                    }

                    local path = this.World.getNavigator().findPath(tile, v.getTile(), navSettings, 0);
                    if (!path.isEmpty()) {
                        abort = false;
                        break;
                    }
                }
                if (abort) {
                    continue;
                }
                return tile;
            }
            minDistToEnemyLocations--;
            minDistToAlliedLocations--;
        }
        return null;
    }

    function getLocationScript(_typeID) {
        switch (_typeID) {
            case "location.ancient_statue":
                return "scripts/entity/world/locations/legendary/ancient_statue_location";
            case "location.ancient_temple":
                return "scripts/entity/world/locations/legendary/ancient_temple_location";
            case "location.ancient_watchtower":
                return "scripts/entity/world/locations/legendary/ancient_watchtower_location";
            case "location.black_monolith":
                return "scripts/entity/world/locations/legendary/black_monolith_location";
            case "location.fountain_of_youth":
                return "scripts/entity/world/locations/legendary/fountain_of_youth_location";
            case "location.icy_cave_location":
                return "scripts/entity/world/locations/legendary/icy_cave_location";
            case "location.kraken_cult":
                return "scripts/entity/world/locations/legendary/kraken_cult_location";
            case "location.land_ship":
                return "scripts/entity/world/locations/legendary/land_ship_location";
            case "location.sunken_library":
                return "scripts/entity/world/locations/legendary/sunken_library_location";
            case "location.tundra_elk_location":
                return "scripts/entity/world/locations/legendary/tundra_elk_location";
            case "location.unhold_graveyard":
                return "scripts/entity/world/locations/legendary/unhold_graveyard_location";
            case "location.goblin_city":
                return "scripts/entity/world/locations/legendary/unique_goblin_city_location";
            case "location.waterwheel":
                return "scripts/entity/world/locations/legendary/waterwheel_location";
            case "location.witch_hut":
                return "scripts/entity/world/locations/legendary/witch_hut_location";
            case "location.holy_site.meteorite":
                return "scripts/entity/world/locations/legendary/meteorite_location";
            case "location.holy_site.oracle":
                return "scripts/entity/world/locations/legendary/oracle_location";
            case "location.holy_site.vulcano":
                return "scripts/entity/world/locations/legendary/vulcano_location";
            default:
                return null;
        }
    }

    function getAllowedTerrainType(_typeID) {
        switch(_typeID) {
            case "location.ancient_statue":
                return [
                    this.Const.World.TerrainType.Plains,
                    this.Const.World.TerrainType.Swamp,
                    this.Const.World.TerrainType.Hills,
                    this.Const.World.TerrainType.LeaveForest,
                    this.Const.World.TerrainType.AutumnForest,
                    this.Const.World.TerrainType.Urban,
                    this.Const.World.TerrainType.Farmland,
                    this.Const.World.TerrainType.Badlands,
                    this.Const.World.TerrainType.Tundra,
                    this.Const.World.TerrainType.Steppe,
                    this.Const.World.TerrainType.Shore,
                    this.Const.World.TerrainType.Desert,
                    this.Const.World.TerrainType.Oasis
                ];
            case "location.ancient_temple":
                return [
                    this.Const.World.TerrainType.Plains,
                    this.Const.World.TerrainType.Swamp,
                    this.Const.World.TerrainType.Hills,
                    this.Const.World.TerrainType.LeaveForest,
                    this.Const.World.TerrainType.AutumnForest,
                    this.Const.World.TerrainType.Urban,
                    this.Const.World.TerrainType.Farmland,
                    this.Const.World.TerrainType.Badlands,
                    this.Const.World.TerrainType.Tundra,
                    this.Const.World.TerrainType.Steppe,
                    this.Const.World.TerrainType.Shore,
                    this.Const.World.TerrainType.Forest,
                    this.Const.World.TerrainType.Oasis
                ];
            case "location.ancient_watchtower":
                return [
                    this.Const.World.TerrainType.Mountains,
                    this.Const.World.TerrainType.Hills
                ];
            case "location.black_monolith":
                return [
                    this.Const.World.TerrainType.Hills,
                    this.Const.World.TerrainType.Steppe,
                    this.Const.World.TerrainType.Tundra,
                    this.Const.World.TerrainType.Plains
                ];
            case "location.fountain_of_youth":
                return [
                    this.Const.World.TerrainType.Forest,
                    this.Const.World.TerrainType.LeaveForest,
                    this.Const.World.TerrainType.AutumnForest
                ];
            case "location.icy_cave_location":
                return [
                    this.Const.World.TerrainType.Snow,
                    this.Const.World.TerrainType.SnowyForest
                ];
            case "location.kraken_cult":
                return [this.Const.World.TerrainType.Swamp];
            case "location.land_ship":
                return [];
            case "location.sunken_library":
                return [this.Const.World.TerrainType.Desert];
            case "location.tundra_elk_location":
                return [this.Const.World.TerrainType.Tundra];
            case "location.unhold_graveyard":
                return [
                    this.Const.World.TerrainType.Hills,
                    this.Const.World.TerrainType.Mountains,
                    this.Const.World.TerrainType.Plains,
                    this.Const.World.TerrainType.Steppe,
                    this.Const.World.TerrainType.Desert,
                    this.Const.World.TerrainType.Oasis,
                    this.Const.World.TerrainType.SnowyForest,
                    this.Const.World.TerrainType.Forest,
                    this.Const.World.TerrainType.LeaveForest,
                    this.Const.World.TerrainType.AutumnForest
                ];
            case "location.goblin_city":
                return [
                    this.Const.World.TerrainType.Hills,
                    this.Const.World.TerrainType.Mountains
                ];
            case "location.waterwheel":
                return [this.Const.World.TerrainType.Plains];
            case "location.witch_hut":
                return [
                    this.Const.World.TerrainType.Forest,
                    this.Const.World.TerrainType.LeaveForest,
                    this.Const.World.TerrainType.AutumnForest
                ];
            case "location.holy_site.meteorite":
                return [
                    this.Const.World.TerrainType.Steppe,
                    this.Const.World.TerrainType.Plains
                ];
            case "location.holy_site.oracle":
                return [
                    this.Const.World.TerrainType.Steppe,
                    this.Const.World.TerrainType.Desert
                ];
            case "location.holy_site.vulcano":
                return [
                    this.Const.World.TerrainType.Desert
                ];
            default:
                return null;
        }
    }
});