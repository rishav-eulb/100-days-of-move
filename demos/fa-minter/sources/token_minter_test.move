#[test_only]
module FAMinter::token_minter_test {
    use std::signer;
    use std::string::{utf8};
    use aptos_framework::fungible_asset::{Metadata};
    use aptos_framework::primary_fungible_store;
    
    use FAMinter::token_minter;
    

    #[test_only]
    public fun create_test_fa(admin: &signer) {
        token_minter::create_managed_fa(
            admin,
            utf8(b"Test Coin"),
            utf8(b"TST"),
            utf8(b"http://test.com/fav.ico"),
            utf8(b"http://test.com")
        );
    } 

    #[test(admin = @0xCAFE, aaron = @0xFACE, bob = @0xB0B)]
    fun test_basic_flow(
        admin: &signer,
        aaron: &signer,
        bob: &signer
    ) {
        let creator_address = signer::address_of(admin);
        let aaron_address = signer::address_of(aaron);
        let bob_address = signer::address_of(bob);
        create_test_fa(admin);
        let metadata = token_minter::get_metadata(creator_address, utf8(b"Test Coin"));

        token_minter::mint(admin, metadata, creator_address, 100);
        assert!(primary_fungible_store::balance(creator_address, metadata) == 100, 4);

        token_minter::freeze_account(admin, metadata, creator_address);
        assert!(primary_fungible_store::is_frozen(creator_address, metadata), 5);

        token_minter::unfreeze_account(admin, metadata, creator_address);
        assert!(!primary_fungible_store::is_frozen(creator_address, metadata), 6);

        primary_fungible_store::transfer<Metadata>(admin, metadata, aaron_address, 10);
        assert!(primary_fungible_store::balance(aaron_address, metadata) == 10, 7);

        primary_fungible_store::transfer(admin, metadata, bob_address, 10);
        assert!(primary_fungible_store::balance(bob_address, metadata) == 10, 8);

        primary_fungible_store::transfer(aaron, metadata, bob_address, 5);
        assert!(primary_fungible_store::balance(bob_address, metadata) == 15, 9);
        assert!(primary_fungible_store::balance(aaron_address, metadata) == 5, 10);

        
        token_minter::burn(admin, metadata, creator_address, 80);
        assert!(primary_fungible_store::balance(creator_address, metadata) == 0, 11);
    }

    #[test(admin = @0xCAFE)]
    #[expected_failure(abort_code = 0x70002, location = FAMinter::token_minter)]
    fun test_paused(admin: &signer) {
        let creator_address = signer::address_of(admin);
        create_test_fa(admin);

        let metadata = token_minter::get_metadata(creator_address, utf8(b"Test Coin"));

        token_minter::mint(admin, metadata, creator_address, 100);
        token_minter::set_pause(admin, metadata, true);
        token_minter::mint(admin, metadata, creator_address, 100);
    }

    #[test(admin = @0xCAFE, aaron = @0xFACE)]
    #[expected_failure(abort_code = 0x50001, location = FAMinter::token_minter)]
    fun test_user_access(admin: &signer, aaron: &signer) {
        let creator_address = signer::address_of(admin);
        create_test_fa(admin);

        let metadata = token_minter::get_metadata(creator_address, utf8(b"Test Coin"));
        token_minter::mint(aaron, metadata, creator_address, 100);
    }
}