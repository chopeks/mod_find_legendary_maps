::ModFindLegendaryMaps.Hooks.hook("scripts/factions/stronghold_player_faction", function(q) {
    q.updateQuests = @(__original) function() {
        __original();
        if (!this.getFlags().has("legendary_location")) {
            local contract = this.new("scripts/contracts/contracts/legendary_map_location_contract");
            contract.setEmployerID(this.getRandomCharacter().getID());
            contract.setFaction(this.getID());
            this.World.Contracts.addContract(contract);
            this.getFlags().add("legendary_location");
        }
    }
});