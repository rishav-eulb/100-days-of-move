# Functions in Move

Functions in Move are the brain of the modules. It contains logic that defines what actions needs to be performed on the global storage. 

They allow developers to write reusable code to manipulate data and implement application logic. Functions in Move are deterministic, meaning they always produce the same output given the same input, ensuring reliability and predictability in blockchain operations

Let's dive a bit deeper in the world of functions with an example:
1. Go to demos/functions folder.
2. Setup the repo through README present there.
There are 3 contracts
    1. **friend_1**: Contains internal, public, entry functions
    2. **friend_2**: Contains public, entry and friend functions
    3. **friend_3**: Contains test cases and tries to call other contract functions
## Types of functions
Functions are declared with the fun keyword followed by the function name, type parameters, parameters, a return type, acquires annotations, and finally the function body.
```js
fun <identifier><[type_parameters: constraint],*>([identifier: type],*): <return_type> <acquires [identifier],*> <function_body>
```
Eg:
```js
fun foo<T1, T2>(x: u64, y: T1, z: T2): (T2, T1, u64) { (z, y, x) }
```
### Internal function
All functions in move modules are internal(private) by default,i.e., they can only be called by other functions inside the same module
Example: In file [friend_1.move](/demos/functions/sources/friend_1.move)
```js
    // This function can only be called from other functions in friend_1
    fun get_year(): u64{
        return 2025
    }
```
### Public functions
When you add public in front of any other func it can be called from any other module as well. Public functions can be called by:
- other functions defined in the same module
- functions defined in another module

Example: In file [friend_1.move](/demos/functions/sources/friend_1.move)
```js
    // This function can be called from any module
    public fun get_age(friend_address: address): u64 acquires Information {
        let name_exists = exists<Information>(friend_address);
        assert!(name_exists, error::not_found(E_ADDRESS_NOT_FOUND));
        return  borrow_global<Information>(friend_address).birth_year
    }
```
### Public friend functions
You can also define which module can call your functions by using a keyword `friend`. This will add extra layer of check. It can be called by:
- other functions defined in the same module
- functions defined in modules which are explicitly specified in the friend list 

Example: In file [friend_2.move](/demos/functions/sources/friend_2.move)
```js   
    module friends::friend_2{
        friend friends::friend_1; // friend_1 module can call the friend functions but no other module can call them
        public(friend) fun get_age(friend_address: address): u64 acquires Information {
            let name_exists = exists<Information>(friend_address);
            assert!(name_exists, error::not_found(E_ADDRESS_NOT_FOUND));
            return  borrow_global<Information>(friend_address).birth_year
        }
    }
```
In the above example only  `friend_1` is able to call the function `get_age`.

### Entry function
These functions are the one that users use to interact with modules. Essentially, entry functions are the "main" functions of a module, and they specify where Move programs start executing.
Example: In file [friend_2.move](/demos/functions/sources/friend_2.move)
```js   
    entry public fun setInformation(author: &signer,_name:string::String, _age:u64){
        move_to<Information>(author,Information{name:_name,birth_year:_age});
    }
```
If public is removed from the function, other modules won't be able to call it but users will still be able to interact with the contract

## Other important thing
### Reading from storage
If a module is reading from a global storage they should use the keyword `acquire` to gain access to the storage
Example: In file [friend_2.move](/demos/functions/sources/friend_2.move)
```js 
    module friends::friend_2{  
        struct Information has key, drop {
            name: string::String ,
            birth_year: u64  
        }
        // the below function uses the Information struct to make changes and thus it uses the acquire keyword
        entry fun change_name(author: &signer,_name:string::String) acquires Information{
            let author_address = signer::address_of(author);
            let name_exists = exists<Information>(author_address);
            assert!(name_exists, error::not_found(E_ADDRESS_NOT_FOUND));
            let author_name = borrow_global_mut<Information>(author_address);
            author_name.name = _name;
        }
    }
```
*A function can acquire multiple structs*
`acquires` annotations must also be added for transitive calls within the module.
Example
```js
    module example {
        struct Balance has key { value: u64 }

        public fun add_balance(s: &signer, value: u64) {
            move_to(s, Balance { value })
        }

        public fun extract_balance(addr: address): u64 acquires Balance {
            let Balance { value } = move_from(addr); // acquires needed
            value
        }

        public fun extract_and_add(sender: address, receiver: &signer) acquires Balance {
            let value = extract_balance(sender); // acquires needed here
            add_balance(receiver, value)
        }
    }
```
### Returning a value
If a function returns something it should specify the return type. Also, when returning data from function one should not use `;` 
Example: In file [friend_2.move](/demos/functions/sources/friend_2.move)
```js
    #[view]
    public fun get_name(author: address): string::String acquires Information{
        let name_exists = exists<Information>(author);
        assert!(name_exists, error::not_found(E_ADDRESS_NOT_FOUND));
        return borrow_global<Information>(author).name // ; is not used as it returns a value
    }
```

### Calling a function
When a module calls another module function it should mention the location of the function and params. It should follow the format: `[Address]::[Module]::[Function](<PARAMS>)`
Example: In file [friend_3.move](/demos/functions/sources/friend_3.move)
```js
    friends::friend_2::setInformation(test_addr,string::utf8(b"Move"),21);
```

### Naming Convention
Function names can start with letters a to z or letters A to Z. After the first character, function names can contain underscores _, letters a to z, letters A to Z, or digits 0 to 9.
```js
fun FOO() {}
fun bar_42() {}
fun _bAZ19() {} // Invalid function name '_bAZ19'Function names cannot start with '_'
```

### Native functions
Some functions do not have a body specified, and instead have the body provided by the VM. These functions are marked native.

Without modifying the VM source code, a programmer cannot add new native functions. Furthermore, it is the intent that native functions are used for either standard library code or for functionality needed for the given Move environment
```
module std::vector {
    native public fun empty<Element>(): vector<Element>;
    ...
}
```

## Summary
In this tutorial you learnt how to define and use different kind of functions depending on our use case. In the next tutorial we'll learn about fungible asset and coins.

## References:
- [Move Book](https://move-language.github.io/move/functions.html)
- [Aptos Documentation](https://aptos.dev/en/build/smart-contracts/book/functions)
- [Movement Documentation](https://developer.movementnetwork.xyz/learning-paths/basic-concepts/03-functions-view-functions-and-visibility)