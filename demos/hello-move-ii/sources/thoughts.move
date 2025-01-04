module HelloMove::thoughts {
    use std::string;
    use std::signer;
    use std::debug::print;
    use std::error;

    struct MyResource has key, drop {
        thought: string::String
    }

    const E_THOUGHT_ALREADY_EXIST: u64 = 1;
    const E_THOUGHT_NOT_FOUND: u64 = 2;

    // User wants to publish his thoughts.
    public entry fun create_thoughts(author: &signer, thought: string::String) {
        // Get address for author
        let author_address = signer::address_of(author);

        // Check if there is already a thought present under author's address.
        let thought_already_exists = exists<MyResource>(author_address);

        // Throw error if it does.
        assert!(!thought_already_exists, error::already_exists(E_THOUGHT_ALREADY_EXIST));

        move_to<MyResource>(author, MyResource {
            thought: thought
        });
    }

    // User wants to see thoughts of other user.
    #[view]
    public fun get_thoughts(user: address): string::String acquires MyResource {
        // Check if there is a thought present under author's address.
        let thought_already_exists = exists<MyResource>(user);

        // Throw error if it does not.
        assert!(thought_already_exists, error::not_found(E_THOUGHT_NOT_FOUND));


        borrow_global<MyResource>(user).thought
    }


    public entry fun delete_thoughts(author: &signer) acquires MyResource {
        let author_address = signer::address_of(author);

        let _ = get_thoughts(author_address);

        move_from<MyResource>(author_address);
    }

    // User wants to edit his thoughts.
    public entry fun edit_thoughts(author: &signer, thought: string::String) acquires MyResource {
        // Check if there is a thought present under author's address.
        let author_address = signer::address_of(author);

        let thought_already_exists = exists<MyResource>(author_address);

        // Throw error if it does not.
        assert!(thought_already_exists, error::not_found(E_THOUGHT_NOT_FOUND));


        let author_thought = borrow_global_mut<MyResource>(author_address);
        author_thought.thought = thought;
    }

    // We should test everything before pushing to prod.
    #[test(aaron = @0xcafe)]
    fun test_basic_flow(aaron: &signer) acquires MyResource {
        // Create a thought for aaron.
        let thought = b"Hello Move";

        // Store it to the blockchain.
        create_thoughts(aaron, string::utf8(thought));

        // Fetch aaron's address
        let aaron_address = signer::address_of(aaron); 

        // Get the thought at his address.
        let aaron_thought = get_thoughts(aaron_address); 

        // Print your thought
        print(&aaron_thought);

        // Check if the thought present at that address is actually "Hello Move"
        assert!(aaron_thought == string::utf8(b"Hello Move"), 1);
    }

    // Test if we are able to edit our thoughts
    #[test(aaron = @0xcafe)]
    fun test_edit_flow(aaron: &signer) acquires MyResource {
        let aaron_address = signer::address_of(aaron); 

        let thought = b"Hello Move";

        create_thoughts(aaron, string::utf8(thought));
        let aaron_thought = get_thoughts(aaron_address);
        assert!(aaron_thought == string::utf8(b"Hello Move"), 1);

        let edited_thoughts = b"Hello Movement";
        edit_thoughts(aaron, string::utf8(edited_thoughts));

        let edited_aaron_thought = get_thoughts(aaron_address);
        assert!(edited_aaron_thought == string::utf8(b"Hello Movement"), 2);
    }

    // Test if we are able to edit our thoughts
    #[test(aaron = @0xcafe)]
    #[expected_failure(abort_code = 0x60002, location = HelloMove::thoughts)]
    fun test_delete_flow(aaron: &signer) acquires MyResource {
        let aaron_address = signer::address_of(aaron); 

        let thought = b"Hello Move";

        create_thoughts(aaron, string::utf8(thought));
        let aaron_thought = get_thoughts(aaron_address);
        assert!(aaron_thought == string::utf8(b"Hello Move"), 1);

        delete_thoughts(aaron);
        let _ = get_thoughts(aaron_address);
    }
}