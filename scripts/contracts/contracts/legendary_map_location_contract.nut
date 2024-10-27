this.legendary_map_location_contract <- this.inherit("scripts/contracts/contract", {
	m = {
		Reward = 0,
		Destination = null,
		Title = "Scout report about maps"
	},
	function create() {
		this.m.DifficultyMult = ::Math.rand(116, 130) * 0.01;
		this.m.Flags = this.new("scripts/tools/tag_collection");
		this.m.TempFlags = this.new("scripts/tools/tag_collection");
		this.createStates();
		this.createScreens();
		this.m.Type = "contract.legendary_map_location_contract";
		this.m.Name = "Rescue scholars";
		this.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * 1500.0;
	}

	function onImportIntro() {
		#this.importSettlementIntro();
	}

	function start() {
		this.contract.start();
	}
	
	function getBanner() {
		return "ui/banners/factions/banner_05s"
	}

	function createStates()	{
		this.m.States.push({
			ID = "Offer",
			function start() {
				this.Contract.m.BulletpointsObjectives = [
					"Find the location your scouts found on the desert."
				];
				this.Contract.setScreen("Task");
			}

			function end() {
				this.World.Contracts.setActiveContract(this.Contract);
				this.Contract.setScreen("Overview_Building");
			}
		});
		
		this.m.States.push({
			ID = "Running",
			function start() {
				if (this.Contract.m.Destination) {
					this.Contract.m.Destination.getSprite("selection").Visible = true;
					this.Contract.m.Destination.setOnEnterCallback(this.onDestinationAttacked.bindenv(this));
				} else {
					local disallowedTerrain = [];
					local camp;
					local distanceToOthers = 15;

					for(local i = 0; i < this.Const.World.TerrainType.COUNT; i = ++i ) {
						if (i != this.Const.World.TerrainType.Desert) {
							disallowedTerrain.push(i);
						}
					}

					local tile = this.Contract.getTileToSpawnLocation(this.Contract.m.Home.getTile(), 20, 300, disallowedTerrain);

					if (tile != null) {
						camp = this.World.spawnLocation("scripts/entity/world/locations/undead_vampire_coven_location", tile.Coords);
					}

					if (camp != null) {
						tile.TacticalType = this.Const.World.TerrainTacticalType.Desert;
						camp.onSpawned();
						camp.getSprite("selection").Visible = true;
						camp.setDiscovered(true);
						camp.setAttackable(true);
						camp.setOnEnterCallback(this.onDestinationAttacked.bindenv(this));
						this.World.uncoverFogOfWar(camp.getTile().Pos, 500.0);
						this.Contract.m.Destination = this.WeakTableRef(camp)
					}
				}
			}
			
			function update() {
				if (this.Contract.m.Destination == null || this.Contract.m.Destination.isNull()) {
					this.Contract.setScreen("SearchingTheCamp");
					this.World.Contracts.finishActiveContract();
				}
			}

			function onDestinationAttacked( _dest, _isPlayerAttacking = true ) {
				this.Contract.setScreen("EnteringTheCamp");
				this.World.Contracts.showActiveContract();
			}
		
		});
	}

	function createScreens() {
		this.m.Screens.push({
			ID = "Task",
			Title = this.m.Title,
			Text = "You approach your castellan office.",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "Enter",
					function getResult() {
						return "Overview_Building";
					}
				},
				{
					Text = "Not now",
					function getResult() {
						return 0;
					}

				}
			],
			function start() {}

		});
		
		this.m.Screens.push({
			ID = "Overview_Building",
			Title = this.m.Title,
			Text = "You see %employer% sitting at the desk filled with last reports.%SPEECH_ON%Our scouts report, that they found a location, that most likely cointains some ancient maps. I thought you might be interested in it.%SPEECH_OFF%Are you willing to embark?",
			Image = "",
			List = [],
			ShowEmployer = true,
			Options = [
				{
					Text = "Yes.",
					function getResult() {
						this.Contract.setState("Running");
						return 0;
					}

				},
				{
					Text = "No.",
					function getResult() {
						this.Contract.removeThisContract();
						return 0;
					}

				}
			],
			ShowObjectives = true,
			ShowPayment = true,
			ShowEmployer = true,
			ShowDifficulty = false,
			function start() {
				this.Contract.m.IsNegotiated = true;
			}
		});
		
		this.m.Screens.push({
			ID = "SearchingTheCamp",
			Title = "After the battle...",
			Text = "[img]gfx/ui/events/event_161.png[/img]{Your scouts were indeed correct.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "We've got what we came for.",
					function getResult() {
						return 0;
					}

				}
			],
			function start() {}
		});

		this.m.Screens.push({
			ID = "EnteringTheCamp",
			Title = "As you approach",
			Text = "[img]gfx/ui/events/event_167.png[/img]{You see an ancient structure, who knows what dwells inside. You notice some shadows moving your way.}",
			Image = "",
			List = [],
			Options = [
				{
					Text = "To arms!",
					function getResult() {
						this.World.State.getLastLocation().setFaction(this.World.FactionManager.getFactionOfType(this.Const.FactionType.Beasts).getID());
						this.World.Contracts.showCombatDialog();
					}
				},
				{
				Text = "Run, you fools!",
					function getResult() {
						return 0;
					}
				}
			]
		});
	}
	
	function onPrepareVariables( _vars ){}
	function onHomeSet() {}

	function onClear() {
		if (this.m.IsActive) {
			if (this.m.Destination != null && !this.m.Destination.isNull()) {
				this.m.Destination.die()
			}
			this.World.FactionManager.getFaction(this.getFaction()).setActive(true);
			this.m.Home.getSprite("selection").Visible = false;
		}
	}

	function cancel() {
		this.onCancel();
	}

	function removeThisContract() {
		this.World.Contracts.removeContract(this);
		this.Stronghold.getPlayerFaction().getFlags().remove("legendary_location");
		this.World.State.getTownScreen().updateContracts();
	}

	function onSerialize( _out ) {
		_out.writeI32(0);
		if (this.m.Destination != null && !this.m.Destination.isNull()) {
			_out.writeU32(this.m.Destination.getID());
		} else {
			_out.writeU32(0);
		}
		this.contract.onSerialize(_out);
	}

	function onDeserialize( _in ) {
		_in.readI32();
		local destination = _in.readU32();

		if (destination != 0) {
			this.m.Destination = this.WeakTableRef(this.World.getEntityByID(destination));
		}
		this.contract.onDeserialize(_in);
	}
});

