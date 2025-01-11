module TreasureHunt::controller {
    use aptos_framework::object::{Self, Object, ObjectCore};
    use std::signer;
    use std::vector;
    use std::error;

    struct TreasureChest has key, store {
        items: vector<Object<ObjectCore>>
    }

    struct SilverCoin has key {}
    struct GoldCoin has key {}

    struct UserDetail has key {
        balance: u64,
        chests: vector<Object<TreasureChest>>
    }

    struct TreasureChestStore has key {
        delete_ref: object::DeleteRef, // Ref for deletion of Object
        extend_ref: object::ExtendRef, // Ref for extending resources to object address
        transfer_ref: object::TransferRef // Ref for transferring ownership
    }

    struct Trophy has key {}

    struct UserDetailV2 has key {
        balance: u64,
        chests: vector<Object<TreasureChestStore>>
    }

    const E_USER_ALREADY_CREATED: u64 = 1;
    const E_USER_NOT_FOUND: u64 = 2;
    const E_INSUFFICENT_BALANCE: u64 = 3;
    const E_INVALID_ASSET_ID: u64 = 4;
    const E_NOT_OWNER: u64 = 5;
    const E_CHEST_NOT_FOUND: u64 = 6;

    const USER_INITIAL_BALANCE: u64 = 100;

    const TREASURE_HUNT_CREATION_COST: u64 = 5;
    const TREASURE_GOLD_COIN_PRICE: u64 = 3;
    const TREASURE_SILVER_COIN_PRICE: u64 = 2;
    const TREASURE_TROPHY_PRICE: u64 = 10;

    inline fun fetch_user_detail_from_address(sender_address: address): &mut UserDetailV2 acquires UserDetailV2 {
        assert!(
            exists<UserDetailV2>(sender_address),
            error::not_found(E_USER_NOT_FOUND)
        );

        borrow_global_mut<UserDetailV2>(sender_address)
    }

    inline fun fetch_treasure_chest_from_object_with_sender_address(sender_address: address, chest_object: Object<TreasureChest>): &mut TreasureChest acquires TreasureChest {
        assert!(object::is_owner(chest_object, sender_address), error::permission_denied(E_NOT_OWNER));

        let chest_object_address = object::object_address(&chest_object);
        borrow_global_mut<TreasureChest>(chest_object_address)
    }

    inline fun fetch_treasure_chest_store_from_object_with_sender_address(sender_address: address, chest_object: Object<TreasureChest>): &mut TreasureChestStore acquires TreasureChestStore {
        assert!(object::is_owner(chest_object, sender_address), error::permission_denied(E_NOT_OWNER));

        let chest_object_address = object::object_address(&chest_object);
        borrow_global_mut<TreasureChestStore>(chest_object_address)
    }

    inline fun fetch_user_detail(sender: &signer): &mut UserDetailV2 acquires UserDetailV2 {
        let sender_address = signer::address_of(sender);
        fetch_user_detail_from_address(sender_address)
    }

    inline fun fetch_treasure_chest_from_object(sender: &signer, chest_object: Object<TreasureChest>): &mut TreasureChest acquires TreasureChest {
        let sender_address = signer::address_of(sender);
        fetch_treasure_chest_from_object_with_sender_address(sender_address, chest_object)
    }

    inline fun fetch_treasure_chest_store_from_object(sender: &signer, chest_object: Object<TreasureChest>): &mut TreasureChestStore acquires TreasureChestStore {
        let sender_address = signer::address_of(sender);
        fetch_treasure_chest_store_from_object_with_sender_address(sender_address, chest_object)
    }

    inline fun create_object<T: key>(sender: &signer, resource: T): (Object<T>, &object::ConstructorRef) {
        let sender_address = signer::address_of(sender);

        // Reserves address_space in global storage
        // Provides reference to add resources to that address.
        let constructor_ref = &object::create_object(sender_address);

        // Get signer from the reference
        let object_creator_signer = &object::generate_signer(constructor_ref);

        // Move resource to the address space belonging to the object.
        move_to<T>(object_creator_signer, resource);

        // Return an Object Wrapper around that resource.
        (object::object_from_constructor_ref<T>(constructor_ref), constructor_ref)
    }

    #[view]
    public fun get_chest_object_by_index(sender_address: address, index: u64): Object<TreasureChest> acquires UserDetailV2 {
        let user_detail = fetch_user_detail_from_address(sender_address);

        // Fetch the chest object present at that index.
        let treasure_chest_store = *vector::borrow(&user_detail.chests, index);

        object::convert<TreasureChestStore, TreasureChest>(treasure_chest_store)
    }

    #[view]
    public fun total_coins_in_chest_by_type<T: key>(sender_address: address, chest_object: Object<TreasureChest>): u64 acquires TreasureChest {
        let chest = fetch_treasure_chest_from_object_with_sender_address(sender_address, chest_object);

        let coin_count: u64 = 0;
        vector::for_each(chest.items, |item| {
            let item_address = object::object_address(&item);
            if(object::object_exists<T>(item_address)) {
                coin_count = coin_count + 1;
            }
        });

        coin_count
    }

    #[view]
    public fun total_treasure_cost(sender_address: address, chest_object: Object<TreasureChest>): u64 acquires TreasureChest {
        let balance: u64 = TREASURE_HUNT_CREATION_COST;
        let chest_object_address = object::object_address(&chest_object);

        if(object::object_exists<Trophy>(chest_object_address)) balance = balance + TREASURE_TROPHY_PRICE;

        let chest = fetch_treasure_chest_from_object_with_sender_address(sender_address, chest_object);
        
        vector::for_each(chest.items, |coin| {
            let coin_address = object::object_address(&coin);
            if(object::object_exists<SilverCoin>(coin_address)) {
                balance = balance + TREASURE_SILVER_COIN_PRICE;
            } else if(object::object_exists<GoldCoin>(coin_address)) {
                balance = balance + TREASURE_GOLD_COIN_PRICE;
            }
        });

        balance
    }

    #[view]    
    public fun get_user_balance(sender: address): u64 acquires UserDetailV2 {
        let user_detail = fetch_user_detail_from_address(sender);
        user_detail.balance
    }

    public fun migrate_treasure_chest(sender: &signer, chest_object: Object<TreasureChest>) acquires UserDetailV2, TreasureChest, GoldCoin, SilverCoin {
        let sender_address = signer::address_of(sender);
        let treasure_chest_address = object::object_address(&chest_object);

        // Drop existing treasure chest
        let TreasureChest{items: coins} = move_from<TreasureChest>(treasure_chest_address);

        let user_detail_v2 = fetch_user_detail(sender);
        let current_index = vector::length(&user_detail_v2.chests);

        // Create Treasure Chest V2 for user
        create_treasure_for_user(sender);

        let chest_object_v2 = get_chest_object_by_index(sender_address, current_index);

        // migrate each coin
        vector::for_each(coins, |coin| {
            let coin_address = object::object_address(&coin);
            if(object::object_exists<SilverCoin>(coin_address)) {
                let SilverCoin{} = move_from<SilverCoin>(coin_address);
                mint_silver_coin_for_treasure(sender, chest_object_v2);
            } else if(object::object_exists<GoldCoin>(coin_address)) {
                let GoldCoin{} = move_from<GoldCoin>(coin_address);
                mint_gold_coin_for_treasure(sender, chest_object_v2);
            }
        });
    }

    public fun migrate_user(sender: &signer): (u64, vector<Object<TreasureChest>>) acquires UserDetail {
        let sender_address = signer::address_of(sender);

        // Drop the existing user details.
        let UserDetail{balance, chests } = move_from<UserDetail>(sender_address);

        // Create existing user with UserDetailsV2
        create_user(sender);

        // Return list of treasure chests.
        (balance, chests)
    }

    // Create user for a given signer with some balance
    public entry fun create_user(sender: &signer)  {
        let sender_address = signer::address_of(sender);
        assert!(
            !exists<UserDetail>(sender_address),
            error::already_exists(E_USER_ALREADY_CREATED)
        );

        move_to<UserDetailV2>(sender, UserDetailV2{
            balance: USER_INITIAL_BALANCE,
            chests: vector::empty<Object<TreasureChestStore>>()
        });
    }

    // Creates a treasure chest
    public entry fun create_treasure_for_user(sender: &signer) acquires UserDetailV2 {
        let user_detail = fetch_user_detail(sender);

        assert!(
            user_detail.balance >= TREASURE_HUNT_CREATION_COST, 
            error::aborted(E_INSUFFICENT_BALANCE)
        );

        user_detail.balance = user_detail.balance - TREASURE_HUNT_CREATION_COST;

        let (_, constructor_ref) = create_object(sender, TreasureChest {
            items: vector::empty<Object<ObjectCore>>()
        });

        // Creates ref for transfer, deletion and extending
        let transfer_ref = object::generate_transfer_ref(constructor_ref);
        let extend_ref = object::generate_extend_ref(constructor_ref);
        let delete_ref = object::generate_delete_ref(constructor_ref);

        let store_signer = &object::generate_signer(constructor_ref);

        // Disable ungated transfer i.e. no transfer without LinearTransferRef
        object::disable_ungated_transfer(&transfer_ref);

        move_to(store_signer, TreasureChestStore{
            transfer_ref,
            extend_ref,
            delete_ref      
        });

        let treasure_chest_store_object = object::object_from_constructor_ref(constructor_ref);

        vector::push_back(&mut user_detail.chests, treasure_chest_store_object);
    }

    public entry fun mint_trophy_for_treasure(sender: &signer, chest_object: Object<TreasureChest>) acquires UserDetailV2, TreasureChestStore {
        let user_detail = fetch_user_detail(sender);

        let chest_object_address = object::object_address(&chest_object);

        if(object::object_exists<Trophy>(chest_object_address)) return ();
        assert!(
            user_detail.balance >= TREASURE_TROPHY_PRICE, 
            error::aborted(E_INSUFFICENT_BALANCE)
        );

        let treasure_chest_store = fetch_treasure_chest_store_from_object(sender, chest_object);

        // Generate a signer to the same object address using ExtendRef
        let trophy_creator_signer = &object::generate_signer_for_extending(&treasure_chest_store.extend_ref);

        move_to(trophy_creator_signer, Trophy{});
        user_detail.balance = user_detail.balance - TREASURE_TROPHY_PRICE;
    }

    public entry fun burn_treasure(sender: &signer, chest_object: Object<TreasureChest>) acquires UserDetailV2, TreasureChest, TreasureChestStore, Trophy {
        let user_detail = fetch_user_detail(sender);
        let sender_address = signer::address_of(sender);

        assert!(object::is_owner(chest_object, sender_address), error::permission_denied(E_NOT_OWNER));
        let treasure_chest_store_address = object::object_address(&chest_object);
        let treasure_chest_store_object: Object<TreasureChestStore> = object::convert(chest_object);

        let (chest_exist, chest_index) = vector::index_of(&user_detail.chests, &treasure_chest_store_object);
        assert!(chest_exist, error::not_found(E_CHEST_NOT_FOUND));

        let chest_balance = total_treasure_cost(sender_address, chest_object); 

        // Delete and unpack  all the existing resources.
        let TreasureChestStore{delete_ref, extend_ref: _, transfer_ref: _} = move_from<TreasureChestStore>(treasure_chest_store_address);
        let TreasureChest{items: _} = move_from<TreasureChest>(treasure_chest_store_address);

        if(exists<Trophy>(treasure_chest_store_address)) {
            let Trophy{} = move_from<Trophy>(treasure_chest_store_address);
        };

        vector::remove(&mut user_detail.chests, chest_index);

        // Restore the balance for the resources burned
        user_detail.balance = user_detail.balance + chest_balance;

        // Delete the object from address
        object::delete(delete_ref);
    }

    public entry fun transfer_treasure(sender: &signer, chest_object: Object<TreasureChest>, to: address) acquires UserDetailV2, TreasureChest, TreasureChestStore {
        let user_detail = fetch_user_detail(sender);
        let sender_address = signer::address_of(sender);

        let treasure_chest_store = fetch_treasure_chest_store_from_object(sender, chest_object);
        let treasure_chest_store_object: Object<TreasureChestStore> = object::convert(chest_object);

        let (chest_exist, chest_index) = vector::index_of(&user_detail.chests, &treasure_chest_store_object);
        assert!(chest_exist, error::not_found(E_CHEST_NOT_FOUND));

        // Transfer ownership using LinearTransferRef
        let linear_transfer_ref = object::generate_linear_transfer_ref(&treasure_chest_store.transfer_ref);
        object::transfer_with_ref(linear_transfer_ref, to);
        
        // Remove the treasure chest from existing user
        vector::remove(&mut user_detail.chests, chest_index);

        let chest_balance = total_treasure_cost(sender_address, chest_object);

        // Restore the balance for the resources burned for old user
        user_detail.balance = user_detail.balance + chest_balance;

        // Burn the balance for new user
        let to_user_detail = fetch_user_detail_from_address(to);
        assert!(to_user_detail.balance >= chest_balance, error::aborted(E_INSUFFICENT_BALANCE));
        
        to_user_detail.balance = to_user_detail.balance - chest_balance;
        vector::push_back(&mut to_user_detail.chests, treasure_chest_store_object);
    }

    fun mint_coin_for_chest(sender: &signer, chest_object: Object<TreasureChest>, asset_id: u8) acquires UserDetailV2, TreasureChest  {
        let coin_minting_cost: u64;
        if (asset_id == 1) coin_minting_cost = TREASURE_SILVER_COIN_PRICE
        else if(asset_id == 2) coin_minting_cost = TREASURE_GOLD_COIN_PRICE
        else abort error::invalid_argument(E_INVALID_ASSET_ID);

        let user_detail = fetch_user_detail(sender);
        let treasure_chest = fetch_treasure_chest_from_object(sender, chest_object);

        assert!(
            user_detail.balance >= coin_minting_cost, 
            error::aborted(E_INSUFFICENT_BALANCE)
        );

        user_detail.balance = user_detail.balance - coin_minting_cost;

        let coin_object: Object<ObjectCore>;
        let coin_creator_ref: &object::ConstructorRef;
        if (asset_id == 1) {
            let silver_coin_object: Object<SilverCoin>;
            (silver_coin_object, coin_creator_ref) = create_object(sender, SilverCoin{});
            coin_object = object::convert(silver_coin_object);
        } else if (asset_id == 2) {
            let gold_coin_object: Object<GoldCoin>;
            (gold_coin_object, coin_creator_ref) = create_object(sender, GoldCoin{});
            coin_object = object::convert(gold_coin_object);
        } else {
            abort error::invalid_argument(E_INVALID_ASSET_ID)
        };

        // Transfer the ownership to treasure chest.
        object::transfer_to_object(sender, coin_object, chest_object);

        // Remove transferrable privileges for coin.
        object::set_untransferable(coin_creator_ref);

        // Add the coin object to the chest.
        vector::push_back(&mut treasure_chest.items, coin_object);
    }

    public entry fun mint_silver_coin_for_treasure(sender: &signer, chest_object: Object<TreasureChest>) acquires UserDetailV2, TreasureChest {
        mint_coin_for_chest(sender, chest_object, 1);
    }

    public entry fun mint_gold_coin_for_treasure(sender: &signer, chest_object: Object<TreasureChest>) acquires UserDetailV2, TreasureChest {
        mint_coin_for_chest(sender, chest_object, 2);
    }

    #[test(aaron = @0xcafe)]
    fun test_basic_flow(aaron: &signer) acquires UserDetailV2, TreasureChest {
        let aaron_address = signer::address_of(aaron);

        // Register aaron to treasure chest.
        create_user(aaron);

        // Create first treasure chest for aaron.
        create_treasure_for_user(aaron);
        let first_chest_object = get_chest_object_by_index(aaron_address, 0);        
        let first_chest_address = object::object_address(&first_chest_object);

        assert!(get_user_balance(aaron_address) == 95, 1);
        // Check ownership
        assert!(object::is_owner(first_chest_object, aaron_address), 2);

        // Create second treasure chest for aaron.
        create_treasure_for_user(aaron);
        let second_chest_object = get_chest_object_by_index(aaron_address, 1);
        let second_chest_address = object::object_address(&second_chest_object);

        assert!(get_user_balance(aaron_address) == 90, 3);
        assert!(object::is_owner(second_chest_object, aaron_address), 4);

        // Mint gold coin for aaron in first chest
        mint_gold_coin_for_treasure(aaron, first_chest_object);
        let first_chest = borrow_global<TreasureChest>(first_chest_address);
        let first_coin_from_first_chest_object = vector::borrow(&first_chest.items, 0);

        assert!(get_user_balance(aaron_address) == 87, 5);
        // First Chest is the owner of first gold coin
        assert!(object::is_owner(*first_coin_from_first_chest_object, first_chest_address), 6);
        assert!(total_coins_in_chest_by_type<GoldCoin>(aaron_address, first_chest_object) == 1, 7);
        assert!(total_coins_in_chest_by_type<SilverCoin>(aaron_address, first_chest_object) == 0, 8);


        // Mint silver coin for aaron in second chest
        mint_silver_coin_for_treasure(aaron, second_chest_object);
        let second_chest = borrow_global<TreasureChest>(second_chest_address);
        let first_coin_from_second_chest_object = vector::borrow(&second_chest.items, 0);

        assert!(get_user_balance(aaron_address) == 85, 9);
        // Second Chest is the owner of first silver coin
        assert!(object::is_owner(*first_coin_from_second_chest_object, second_chest_address), 10);
        assert!(total_coins_in_chest_by_type<GoldCoin>(aaron_address, second_chest_object) == 0, 11);
        assert!(total_coins_in_chest_by_type<SilverCoin>(aaron_address, second_chest_object) == 1, 12);
        
    }

}