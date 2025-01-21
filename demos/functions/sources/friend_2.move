module friends::friend_2{
    friend friends::friend_1;

    use std::string;
    use std::signer;
    use std::error;

    struct Information has key, drop {
        name: string::String ,
        birth_year: u64  
    }

    const E_ADDRESS_NOT_FOUND: u64 = 2;

    entry public fun setInformation(author: &signer,_name:string::String, _age:u64){
        move_to<Information>(author,Information{name:_name,birth_year:_age});
    }

    entry fun change_name(author: &signer,_name:string::String) acquires Information{
        let author_address = signer::address_of(author);
        let name_exists = exists<Information>(author_address);
        assert!(name_exists, error::not_found(E_ADDRESS_NOT_FOUND));
        let author_name = borrow_global_mut<Information>(author_address);
        author_name.name = _name;
    }

    public(friend) fun get_age(friend_address: address): u64 acquires Information {
        let name_exists = exists<Information>(friend_address);
        assert!(name_exists, error::not_found(E_ADDRESS_NOT_FOUND));
        return  borrow_global<Information>(friend_address).birth_year
    }

    #[view]
    public fun get_name(author: address): string::String acquires Information{
        let name_exists = exists<Information>(author);
        assert!(name_exists, error::not_found(E_ADDRESS_NOT_FOUND));
        return borrow_global<Information>(author).name
    }

}