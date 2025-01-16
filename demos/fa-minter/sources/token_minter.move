module FAMinter::token_minter {
    use aptos_framework::fungible_asset::{
        Self,
        MintRef,
        TransferRef,
        BurnRef,
        Metadata
    };
    use aptos_framework::object::{Self, Object};
    use aptos_framework::primary_fungible_store;
    use std::error;
    use std::signer;
    use std::string::{bytes, String};
    use std::option;
    
    const ENOT_OWNER: u64 = 1;
    const EPAUSED: u64 = 2;
    const ECOIN_EXISTS: u64 = 3;
    const ENO_MINT_AUTHORITY: u64 = 4;
    const ENO_MINT_TOKEN_MISMATCH: u64 = 5;

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct ManagedFungibleAsset has key {
        mint_ref: MintRef,
        transfer_ref: TransferRef,
        burn_ref: BurnRef
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct State has key {
        paused: bool
    }

    inline fun get_fa_ref(metadata: Object<Metadata>): &ManagedFungibleAsset acquires ManagedFungibleAsset {
        let metadata_address = object::object_address(&metadata);
        let managed_ref = borrow_global<ManagedFungibleAsset>(metadata_address);
        managed_ref
    }

    inline fun get_state(metadata: Object<Metadata>): &mut State acquires State {
        let metadata_address = object::object_address(&metadata);
        borrow_global_mut<State>(metadata_address)
    }

    #[view]
    public fun get_metadata(creator: address, name: String): Object<Metadata> {
        let metadata_address = object::create_object_address(&creator, *bytes(&name));
        object::address_to_object<Metadata>(metadata_address)
    }

    fun assert_not_paused(metadata: Object<Metadata>) acquires State {
        let state = get_state(metadata);
        assert!(!state.paused, error::aborted(EPAUSED));
    }

    fun assert_metadata_owner(sender: &signer, metadata: Object<Metadata>) {
        assert!(
            object::is_owner(metadata, signer::address_of(sender)),
            error::permission_denied(ENOT_OWNER)
        )
    }

    public entry fun create_managed_fa(
        sender: &signer, 
        name: String, 
        symbol: String, 
        icon_uri: String, 
        project_uri: String
    ) {        
        let object_address = object::create_object_address(&signer::address_of(sender), *bytes(&name));
        let fa_exists = object::object_exists<ManagedFungibleAsset>(object_address);
        assert!(!fa_exists, error::already_exists(ECOIN_EXISTS));

        let constructor_ref = &object::create_named_object(sender, *bytes(&name)); 

        // Create the FA's Metadata with your name, symbol, icon, etc.
        primary_fungible_store::create_primary_store_enabled_fungible_asset(
            constructor_ref,
            option::none(),
            name,
            symbol,
            8,
            icon_uri,
            project_uri
        );
 
        // Generate all the ref
        let mint_ref = fungible_asset::generate_mint_ref(constructor_ref);
        let transfer_ref = fungible_asset::generate_transfer_ref(constructor_ref);
        let burn_ref = fungible_asset::generate_burn_ref(constructor_ref);

        let metadata_object_signer = object::generate_signer(constructor_ref);
        let managed_ref = ManagedFungibleAsset { mint_ref, transfer_ref, burn_ref };

        // Store the ref and FA State in same address as that of FA metadata.
        move_to(
            &metadata_object_signer,
            managed_ref
        );

        move_to(
            &metadata_object_signer,
            State { paused: false }
        );
    }

    // Pause or UnPause a given FA i.e creator can mint/burn a given asset or not
    public entry fun set_pause(pauser: &signer, metadata: Object<Metadata>, paused: bool) acquires State {
        assert_metadata_owner(pauser, metadata);
        let state = get_state(metadata);
        if (state.paused == paused) { return };
        state.paused = paused;
    }


    // Freeze FA account of a given user i.e. user can't deposit or withdraw this FA.
    public entry fun freeze_account(admin: &signer, metadata: Object<Metadata>, account: address) acquires ManagedFungibleAsset {
        assert_metadata_owner(admin, metadata);

        let transfer_ref = &get_fa_ref(metadata).transfer_ref;
        let wallet = primary_fungible_store::ensure_primary_store_exists(account, metadata);
        fungible_asset::set_frozen_flag(transfer_ref, wallet, true);
    }

    // Unfreeze FA account of a given user i.e. user can deposit or withdraw this FA.
    public entry fun unfreeze_account(admin: &signer, metadata: Object<Metadata>, account: address) acquires ManagedFungibleAsset {
        assert_metadata_owner(admin, metadata);

        let transfer_ref = &get_fa_ref(metadata).transfer_ref;
        let wallet = primary_fungible_store::ensure_primary_store_exists(account, metadata);
        fungible_asset::set_frozen_flag(transfer_ref, wallet, false);
    }

    public entry fun mint(admin: &signer, metadata: Object<Metadata>, to: address, amount: u64) acquires ManagedFungibleAsset, State {
        assert_not_paused(metadata);
        assert_metadata_owner(admin, metadata);

        let mint_ref = &get_fa_ref(metadata).mint_ref;
        let to_wallet = primary_fungible_store::ensure_primary_store_exists(to, metadata);
        fungible_asset::mint_to(mint_ref, to_wallet, amount);
    }

    public entry fun burn(admin: &signer, metadata: Object<Metadata>, from: address, amount: u64) acquires ManagedFungibleAsset, State {
        assert_not_paused(metadata);
        assert_metadata_owner(admin, metadata);

        let burn_ref = &get_fa_ref(metadata).burn_ref;
        let from_wallet = primary_fungible_store::primary_store(from, metadata);
        fungible_asset::burn_from(burn_ref, from_wallet, amount);
    }
}