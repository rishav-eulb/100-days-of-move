# Introduction to Smart Vectors

On [day 11](UsingVectors.md) we talked about how we use to vector store data of same type in contiguous memory. However, vectors have some size limitation.

**Limitations of Vector**

Vectors implementation is not scalable in general. With growing size, iteration and removal of elements from vector takes in more gas. Also there is only a limited space in a given address where users can store data.

## What Are Smart Vectors?

Smart Vector are a scalable implementation to vectors using `table`. It uses bucketing to store multiple vectors with a given bucket size and in case of overflow adds newer buckets. This makes all the linear operations efficient as they are always an order of the bucket size therefore consuming less gas. Smart Vectors are particularly advantageous for:

- Managing collections of smart assets or states.
- Performing batch operations on on-chain data.
- Building complex, data-driven logic.
- Efficient for handling large datasets over Vectors.

## Importing Smart Vectors

To use Smart Vectors, include them in your module or script with the following import statement:

```move
use aptos_std::smart_vector;
```

## Creating a Smart Vector

You can initialize an empty Smart Vector using the `smart_vector::new<T>()` function, where `T` is the type of elements.

### Example

```move
fun create_empty_smart_vector(): smart_vector<u64> {
    smart_vector::new<u64>()
}
```

## Adding Elements to a Smart Vector

Use `smart_vector::push_back` to add elements to the end of the Smart Vector.

### Example

```move
fun add_elements() {
    let mut my_smart_vector = smart_vector::new<u64>();
    smart_vector::push_back(&mut my_smart_vector, 42);
    smart_vector::push_back(&mut my_smart_vector, 99);
}
```

## Accessing Elements in a Smart Vector

Retrieve an element at a specific index using `smart_vector::borrow`.

### Example

```move
fun get_element(my_smart_vector: &smart_vector<u64>, index: u64): &u64 {
    smart_vector::borrow(my_smart_vector, index)
}
```

## Removing Elements from a Smart Vector

Remove and return the last element of a Smart Vector using `smart_vector::pop_back`.

### Example

```move
fun remove_last(my_smart_vector: &mut smart_vector<u64>): u64 {
    smart_vector::pop_back(my_smart_vector)
}
```

## Iterating Over a Smart Vector

Loop through a Smart Vector with a `for` loop to process its elements.

### Example

```move
fun iterate_smart_vector(my_smart_vector: &smart_vector<u64>) {
    for (i in 0..smart_vector::length(my_smart_vector)) {
        let value = *smart_vector::borrow(my_smart_vector, i);
        // Perform operations with value
    }
}
```

Alternatively, use `smart_vector::for_each` for inline operations:

```move
fun compute_sum(my_smart_vector: smart_vector<u64>) {
    let sum: u64 = 0;
    smart_vector::for_each(my_smart_vector, |item| {
        sum = sum + item;
    });
}
```

## Checking Smart Vector Length

Determine the number of elements in a Smart Vector with `smart_vector::length`.

### Example

```move
fun smart_vector_length(my_smart_vector: &smart_vector<u64>): u64 {
    smart_vector::length(my_smart_vector)
}
```

## Clearing a Smart Vector

Clear all elements from a Smart Vector either by using `pop_back` in a loop or reinitializing it.

### Example

```move
fun clear_smart_vector(my_smart_vector: &mut smart_vector<u64>) {
    while (smart_vector::length(my_smart_vector) > 0) {
        smart_vector::pop_back(my_smart_vector);
    }
}
```

## Advanced Operations

### Merging Smart Vectors

Combine two Smart Vectors into one using `smart_vector::append`.

### Example

```move
fun merge_smart_vectors(v1: &mut smart_vector<u64>, v2: smart_vector<u64>) {
    smart_vector::append(v1, v2);
}
```

### Sorting a Smart Vector

While native sorting isn’t available, you can implement custom sorting logic for Smart Vectors using loops and comparison functions.

## Best Practices

1. **Consistent Types:** Ensure all elements in a Smart Vector are of the same type for reliability.
2. **Efficient Memory Use:** Minimize resizing by initializing with appropriate capacity.
3. **Read-Only Operations:** Use immutable references when data modification is unnecessary.
4. **Error Checking:** Validate indices to avoid runtime exceptions.

## Summary

Smart Vectors in the Movement blockchain are a versatile and efficient tool for managing collections of data. Mastering their functionality and best practices will enable you to build sophisticated and high-performance packages.

## Resources

- [Smart Vector Documentation](https://aptos.dev/en/build/smart-contracts/smart-vector)
- [Smart Vector Source Code](https://github.com/aptos-labs/aptos-core/blob/main/aptos-move/framework/aptos-stdlib/sources/data_structures/smart_vector.move)
