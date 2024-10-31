this.mfl_named_map <- this.inherit("scripts/items/item", {
    m = {
        Target = null
        LocationName = ""
    },
    function create() {
        this.m.ID = "misc.mfl_named_map";
        this.m.Name = "Scout report";
        this.m.Description = "This map points to a location with valuable loot.";
        this.m.Icon = "named_map.png";
        this.m.SlotType = this.Const.ItemSlot.None;
        this.m.ItemType = this.Const.Items.ItemType.Usable;
        this.m.IsUsable = true;
        this.m.IsDroppedAsLoot = true;
        this.m.Value = 350;
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

    function setLocation() {
        if(this.m.Target != null && !this.m.Target.isNull()) {
            this.m.LocationName = this.m.Target.get().getName();
            this.m.Description = "This map points to a location with valuable loot. [color=" + ::Const.UI.Color.PositiveEventValue + "]" + this.m.LocationName + "[/color]"
        }
    }

    function onUse( _actor, _item = null ) {
        if (this.m.Target == null) {
            local maps = this.World.Assets.mfl_getNamedMaps();
            local bestD = 9999;
            local bestLocation = null;
            foreach (location in this.World.EntityManager.getLocations()) {
                if (location.isAlliedWithPlayer() || location.getLoot().isEmpty()) {
                    continue;
                }
                local d = location.getTile().getDistanceTo(this.World.State.getPlayer().getTile());
                if (d < bestD) {
                    local isOwned = false;
                    foreach(map in maps) {
                        if (map.m.Target == null || map.m.Target.isNull())
                            continue;
                        if (map.m.Target.getID() == location.getID()) {
                            isOwned = true;
                            break;
                        }
                    }
                    if (!isOwned) {
                        bestD = d;
                        bestLocation = location;
                    }
                }
            }
            if (bestLocation != null) {
                this.m.Target = this.WeakTableRef(bestLocation)
            }
        }

        local location = this.m.Target;
        if (this.m.Target != null && !this.m.Target.isNull()) {
            setLocation();

            this.World.uncoverFogOfWar(location.getPos(), 250.0);
            this.Settings.getTempGameplaySettings().CameraLocked = false
            this.World.State.getMenuStack().popAll(true);
            this.World.getCamera().Zoom = 1.0;
            this.World.getCamera().setPos(location.getPos());
        }

        this.Sound.play("sounds/scribble.wav", this.Const.Sound.Volume.Inventory);
        return false;
    }

    function onSerialize( _out ) {
        if (this.m.Target != null && !this.m.Target.isNull()) {
            _out.writeU32(this.m.Target.getID());
        } else {
            _out.writeU32(0);
        }
        this.item.onSerialize(_out);
    }

    function onDeserialize( _in ) {
        local target = _in.readU32();
        if (target != 0) {
            this.m.Target = this.WeakTableRef(this.World.getEntityByID(target));
        } else {
			this.m.Target = null;
		}
        this.item.onDeserialize(_in);
        if (this.m.Target != null && !this.m.Target.isNull()) {
            this.setLocation();
        }
    }
});