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

    #[test(aaron = @0xcafe)]
    fun test_basic_flow(aaron: &signer) acquires MyResource {
        let aaron_address = signer::address_of(aaron);
        create_thoughts(aaron, string::utf8(b"Hello World"));
        assert!(get_thoughts(aaron_address) == string::utf8(b"Hello World"), 1);
    }
}