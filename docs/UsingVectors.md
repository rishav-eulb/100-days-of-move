# Introduction to Vectors

The Movement blockchain provides a robust framework for developers to manage assets, create dApps, and implement complex logic efficiently. Vectors, being a core data structure in the Movement blockchain, enable developers to handle collections of elements seamlessly. This README provides a comprehensive guide on how to use Vectors within the Movement blockchain ecosystem.

## What Are Vectors?

Vectors are dynamic, ordered collections of elements of the same type. They are a flexible and efficient way to store and manipulate data within smart contracts. In Movement, Vectors are particularly useful for:

- Managing lists of resources or values.
- Tracking states within a smart contract.
- Facilitating batch operations.

## Importing Vectors

Before using Vectors, you must import them into your module or script. Use the following syntax:

```move
use std::vector;
```

## Creating a Vector

You can create a new, empty Vector using the `vector::empty<T>()` function, where `T` is the type of elements the Vector will hold.

### Example

```move
fun create_empty_vector(): vector<u64> {
    vector::empty<u64>()
}
```

## Adding Elements to a Vector

To add elements, use the `vector::push_back` function.

### Example

```move
fun add_elements_to_vector() {
    let mut my_vector = vector::empty<u64>();
    vector::push_back(&mut my_vector, 10);
    vector::push_back(&mut my_vector, 20);
}
```

## Accessing Elements in a Vector

Use `vector::borrow` to access elements at a specific index.

### Example

```move
fun get_element_at_index(my_vector: &vector<u64>, index: u64): &u64 {
    vector::borrow(my_vector, index)
}
```

## Removing Elements from a Vector

To remove an element, use the `vector::pop_back` function, which removes and returns the last element.

### Example

```move
fun remove_last_element(my_vector: &mut vector<u64>): u64 {
    vector::pop_back(my_vector)
}
```

## Iterating Over a Vector

You can loop through a Vector using a simple `for` loop.

### Example

```move
fun iterate_over_vector(my_vector: &vector<u64>) {
    for (i in 0..vector::length(my_vector)) {
        let value = *vector::borrow(my_vector, i);
        // Perform operations with value
    }
}
```

Alternatively, one can also call `for_each` function to perform operations on list of items.

```Move
fun sum_over_vector(my_vector: vector<u64>) {
    let sum: u64 = 0;
    vector::for_each(my_vector, |item| {
        let sum = sum + item;
    });
}
```

Here `|item| {}` is an inline function.

## Checking Vector Length

To find the number of elements in a Vector, use `vector::length`.

### Example

```move
fun vector_length(my_vector: &vector<u64>): u64 {
    vector::length(my_vector)
}
```

## Clearing a Vector

To remove all elements from a Vector, you can use a loop with `pop_back` or recreate the Vector using `vector::empty`.

### Example

```move
fun clear_vector(my_vector: &mut vector<u64>) {
    while (vector::length(my_vector) > 0) {
        vector::pop_back(my_vector);
    }
}
```

## Advanced Operations

### Concatenating Two Vectors

You can merge two Vectors using `vector::append`.

### Example

```move
fun concatenate_vectors(v1: &mut vector<u64>, v2: vector<u64>) {
    vector::append(v1, v2);
}
```

### Sorting a Vector

Although Movement doesn’t provide a direct sorting function, you can implement sorting logic using loops and custom algorithms.

## Best Practices

1. **Type Consistency:** Ensure all elements in a Vector are of the same type.
2. **Memory Management:** Avoid excessive resizing by initializing Vectors with a reasonable capacity if possible.
3. **Immutability:** Use references for read-only operations to minimize data copying.
4. **Error Handling:** Always validate indices before accessing elements to avoid runtime errors.

## Summary

Vectors are powerful and versatile tools in the Movement blockchain, enabling developers to handle collections of data effectively. By understanding the key functions and best practices, you can build efficient and reliable smart contracts.

## Resources

- [Vector](https://move-language.github.io/move/vector.html)
- [Loops](https://aptos.dev/en/build/smart-contracts/book/loops)
- [Vector on Aptos](https://aptos.dev/en/build/smart-contracts/vector)
- [Vector Source Code](https://github.com/aptos-labs/aptos-core/blob/main/third_party/move/move-stdlib/sources/vector.move)
