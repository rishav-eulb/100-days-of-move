module HelloMove::thoughts {
    use std::string;
    use std::signer;

    struct MyResource has key {
        thought: string::String
    }

    // User wants to publish his thoughts.
    public entry fun create_thoughts(author: &signer, thought: string::String) {
        move_to<MyResource>(author, MyResource {
            thought: thought
        });
    }

    // User wants to see thoughts of other user.
    #[view]
    public fun get_thoughts(user: address): string::String acquires MyResource {
        borrow_global<MyResource>(user).thought
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

        // Check if the thought present at that address is actually "Hello Move"
        assert!(aaron_thought == string::utf8(b"Hello Move"), 1);
    }
}