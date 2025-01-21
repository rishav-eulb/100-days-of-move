module friends::friend_1{
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

    fun get_year(): u64{
        return 2025
    } 

    public fun get_age(friend_address: address): u64 acquires Information {
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

    #[test]
    fun test_internal(){
        let year = get_year();
        assert(year==2025,1); // internal function can be read from the same contract
    }

    #[test(test_addr = @0xcafe)]
    fun test_friend(test_addr:&signer){
        friends::friend_2::setInformation(test_addr,string::utf8(b"Move"),21);
        let _addr = signer::address_of(test_addr);
        let _age = friends::friend_2::get_age(_addr); // as friend_2 is a friend, friend_1 can read the age
        assert!(_age==21,1);
    }
}