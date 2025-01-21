module friends::friend_3{
    use std::string;
    use std::signer;
    use std::debug::print;

    #[test(test_addr = @0xcafe)]
    fun test_public(test_addr:&signer){
        friends::friend_2::setInformation(test_addr,string::utf8(b"Move"),21);
        let _addr = signer::address_of(test_addr);
        let _age = friends::friend_1::get_age(_addr);  // As public function it read the age from friend 1
        assert!(_age==21,1);
        print(b"test public passed");
    }

    #[test(test_addr = @0xcafe)]
    #[expected_failure(abort_code = 0)]
    fun test_friend(test_addr:&signer){
        friends::friend_1::setInformation(test_addr,string::utf8(b"Move"),21);
        let _addr = signer::address_of(test_addr);
        let _age = friends::friend_1::get_age(_addr); // As not a friend it can't read the age from friend 1
        print(b"test friend failed as not a friend");
    }

    #[test]
    #[expected_failure(abort_code = 0)]
    fun test_internal(){
        let year = friends::friend_1::get_year(); // Will throw error as internal function
    }

}