module TreasureHunt::controller {
    use aptos_framework::object::{Self, Object, ObjectCore};
    use std::signer;
    use std::vector;
    use std::error;

    struct TreasureChest has key {
        items: vector<Object<ObjectCore>>
    }

    struct SilverCoin has key {}
    struct GoldCoin has key {}

    struct UserDetail has key {
        balance: u64,
        chests: vector<Object<TreasureChest>>
    }

    const E_USER_ALREADY_CREATED: u64 = 1;
    const E_USER_NOT_FOUND: u64 = 2;
    const E_INSUFFICENT_BALANCE: u64 = 3;
    const E_INVALID_ASSET_ID: u64 = 4;
    const E_NOT_OWNER: u64 = 5;

    const USER_INITIAL_BALANCE: u64 = 100;

    const TREASURE_HUNT_CREATION_COST: u64 = 5;
    const TREASURE_GOLD_COIN_PRICE: u64 = 3;
    const TREASURE_SILVER_COIN_PRICE: u64 = 2;

    inline fun fetch_user_detail_from_address(sender_address: address): &mut UserDetail acquires UserDetail {
        assert!(
            exists<UserDetail>(sender_address),
            error::not_found(E_USER_NOT_FOUND)
        );

        borrow_global_mut<UserDetail>(sender_address)
    }

    inline fun fetch_user_detail(sender: &signer): &mut UserDetail acquires UserDetail {
        let sender_address = signer::address_of(sender);
        fetch_user_detail_from_address(sender_address)
    }

    #[view]
    public fun get_chest_object_by_index(sender_address: address, index: u64): Object<TreasureChest> acquires UserDetail {
        let user_detail = fetch_user_detail_from_address(sender_address);

        // Fetch the chest object present at that index.
        *vector::borrow<Object<TreasureChest>>(&user_detail.chests, index)
    }

    #[view]
    public fun total_coins_in_chest_by_type<T: key>(sender_address: address, chest_object: Object<TreasureChest>): u64 acquires TreasureChest {
        assert!(object::is_owner(chest_object, sender_address), error::permission_denied(E_NOT_OWNER));

        let chest_object_address = object::object_address(&chest_object);
        let chest = borrow_global<TreasureChest>(chest_object_address);

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
    public fun get_user_balance(sender: address): u64 acquires UserDetail {
        let user_detail = fetch_user_detail_from_address(sender);
        user_detail.balance
    }

    // Create user for a given signer with some balance
    public entry fun create_user(sender: &signer)  {
        let sender_address = signer::address_of(sender);
        assert!(
            !exists<UserDetail>(sender_address),
            error::already_exists(E_USER_ALREADY_CREATED)
        );

        move_to<UserDetail>(sender, UserDetail{
            balance: USER_INITIAL_BALANCE,
            chests: vector::empty<Object<TreasureChest>>()
        });
    }

    // Creates a treasure chest
    public entry fun create_treasure_for_user(sender: &signer) acquires UserDetail {
        let sender_address = signer::address_of(sender);
        let user_detail = fetch_user_detail(sender);

        assert!(
            user_detail.balance >= TREASURE_HUNT_CREATION_COST, 
            error::aborted(E_INSUFFICENT_BALANCE)
        );

        user_detail.balance = user_detail.balance - TREASURE_HUNT_CREATION_COST;

        // Reserves address_space in global storage
        // Provides reference to add resources to that address.
        let treasure_chest_constructor_ref = &object::create_object(sender_address);

        // Get signer from the reference
        let treasure_chest_creator_signer = &object::generate_signer(treasure_chest_constructor_ref);

        move_to<TreasureChest>(treasure_chest_creator_signer, TreasureChest {
            items: vector::empty<Object<ObjectCore>>()
        });

        let treasure_chest_object = object::object_from_constructor_ref<TreasureChest>(treasure_chest_constructor_ref);

        vector::push_back(&mut user_detail.chests, treasure_chest_object);
    }

    fun mint_coin_for_chest(sender: &signer, chest_object: Object<TreasureChest>, asset_id: u8) acquires UserDetail, TreasureChest  {
        let coin_minting_cost: u64;
        if (asset_id == 1) coin_minting_cost = TREASURE_SILVER_COIN_PRICE
        else if(asset_id == 2) coin_minting_cost = TREASURE_GOLD_COIN_PRICE
        else abort error::invalid_argument(E_INVALID_ASSET_ID);

        let user_detail = fetch_user_detail(sender);
        let sender_address = signer::address_of(sender);

        // Check is sender is the actual owner of chest_object
        assert!(object::is_owner(chest_object, sender_address), error::permission_denied(E_NOT_OWNER));
        assert!(
            user_detail.balance >= coin_minting_cost, 
            error::aborted(E_INSUFFICENT_BALANCE)
        );

        user_detail.balance = user_detail.balance - coin_minting_cost;

        // Fetch TreasureChest from TreasureChest object
        let chest_object_address = object::object_address(&chest_object);
        let chest = borrow_global_mut<TreasureChest>(chest_object_address);

        // Reserves address_space in global storage
        // Provides reference to add resources to that address.
        let coin_constructor_ref = &object::create_object(sender_address);

        // Get signer from the reference
        let coin_creator_signer = &object::generate_signer(coin_constructor_ref);
        if (asset_id == 1) {
            move_to(coin_creator_signer, SilverCoin{});
        } else if (asset_id == 2) {
            move_to(coin_creator_signer, GoldCoin{});
        };

        // Rather than adding Object<SilverCoin> or Object<GoldCoin> we use ObjectCore as a generic representation
        let coin_object = object::object_from_constructor_ref<ObjectCore>(coin_constructor_ref);

        // Transfer the ownership to treasure chest which is indirectly owned by the same sender.
        object::transfer_to_object(sender, coin_object, chest_object);

        vector::push_back(&mut chest.items, coin_object);
    }

    public entry fun mint_silver_coin_for_treasure(sender: &signer, chest_object: Object<TreasureChest>) acquires UserDetail, TreasureChest {
        mint_coin_for_chest(sender, chest_object, 1);
    }

    public entry fun mint_gold_coin_for_treasure(sender: &signer, chest_object: Object<TreasureChest>) acquires UserDetail, TreasureChest {
        mint_coin_for_chest(sender, chest_object, 2);
    }

    #[test(aaron = @0xcafe)]
    fun test_basic_flow(aaron: &signer) acquires UserDetail, TreasureChest {
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


        // Mint silver coin for aaron in second chest
        mint_silver_coin_for_treasure(aaron, second_chest_object);
        let second_chest = borrow_global<TreasureChest>(second_chest_address);
        let first_coin_from_second_chest_object = vector::borrow(&second_chest.items, 0);

        assert!(get_user_balance(aaron_address) == 85, 8);
        // Second Chest is the owner of first silver coin
        assert!(object::is_owner(*first_coin_from_second_chest_object, second_chest_address), 9);
        assert!(total_coins_in_chest_by_type<SilverCoin>(aaron_address, second_chest_object) == 1, 10);
    }

}