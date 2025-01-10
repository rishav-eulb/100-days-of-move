script {
    use TreasureHunt::controller;
    use std::vector;
    use std::signer;

 
    fun migrate_account(sender: &signer) {
        let sender_address = signer::address_of(sender);
        let (balance, treasure_chests) = controller::migrate_user(sender);

        vector::for_each(treasure_chests, |chest| {
            controller::migrate_treasure_chest(sender, chest);
        });

        assert!(balance == controller::get_user_balance(sender_address), 1);
    }
}