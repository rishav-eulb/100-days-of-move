# Introduction to Smart Tables

The Movement blockchain introduces Smart Tables, a powerful data structure designed for efficient and flexible key-value storage in decentralized applications. Smart Tables enable developers to manage and manipulate data in a structured and scalable way, making them an essential tool for building advanced smart contracts.

This README provides a detailed guide on how to use Smart Tables in the Movement blockchain ecosystem.

## What Are Smart Tables?

Smart Tables are key-value stores that allow developers to map keys to corresponding values. They are ideal for:

- Storing user-specific data or configurations.
- Managing large datasets with efficient lookup and modification capabilities.
- Implementing custom indexing mechanisms for complex logic.

## Importing Smart Tables

To use Smart Tables, include them in your module or script with the following import statement:

```move
use aptos_std::smart_table;
```

## Creating a Smart Table

You can initialize an empty Smart Table using the `smart_table::new<K, V>()` function, where `K` is the type of the key, and `V` is the type of the value.

### Example

```move
fun create_empty_smart_table(): smart_table<u64, u64> {
    smart_table::new<u64, u64>()
}
```

## Adding Entries to a Smart Table

Use `smart_table::add` to add a key-value pair to the Smart Table.

### Example

```move
fun add_entry(my_table: &mut smart_table<u64, u64>, key: u64, value: u64) {
    smart_table::add(my_table, key, value);
}
```

If user add a new record or modify an existing record then one can call `smart_table::upsert`.

```move
fun upsert_entry(my_table: &mut smart_table<u64, u64>, key: u64, value: u64) {
    smart_table::upsert(my_table, key, value);
}
```

## Retrieving Values from a Smart Table

Retrieve a value for a specific key using `smart_table::borrow`.

### Example

```move
fun get_value(my_table: &smart_table<u64, u64>, key: u64): u64 {
    *smart_table::borrow(my_table, key)
}
```

In case of mutable reference one can replace `borrow_mut` with `borrow`.

## Removing Entries from a Smart Table

Use `smart_table::remove` to delete a key-value pair from the table.

### Example

```move
fun remove_entry(my_table: &mut smart_table<u64, u64>, key: u64): u64 {
    smart_table::remove(my_table, key)
}
```

## Checking Table Size

To determine the number of entries in a Smart Table, use `smart_table::length`.

### Example

```move
fun table_size(my_table: &smart_table<u64, u64>): u64 {
    smart_table::length(my_table)
}
```

## Iterating Over a Smart Table

You can iterate through the key-value pairs in a Smart Table using `smart_table::for_each_ref`.

### Example

```move
fun iterate_table(my_table: &smart_table<u64, u64>) {
    smart_table::for_each_ref(my_table, |key, value| {
        // Process key-value pairs
        // key and value has type &u64
    });
}
```

## Clearing a Smart Table

Clear all entries from a Smart Table.

### Example

```move
fun clear_table(my_table: &mut smart_table<u64, u64>) {
    smart_table::clear(my_table)
}
```

## Advanced Operations

### Merging Smart Tables

Combine two Smart Tables by iterating through one and adding its entries to the other.

### Example

```move
fun merge_tables(t1: &mut smart_table<u64, u64>, t2: &smart_table<u64, u64>) {
    smart_table::for_each_ref(t2, |key, value| {
        smart_table::upsert(t1, *key, *value);
    });
}
```

### Handling Collisions

Implement custom logic to handle key collisions if necessary. For example, you can append values or overwrite them based on your requirements.

## Best Practices

1. **Unique Keys:** Ensure keys are unique to avoid unintended overwrites.
2. **Efficient Lookups:** Use appropriate key types for quick retrieval.
3. **Error Handling:** Handle missing keys gracefully to avoid runtime errors.
4. **Memory Management:** Regularly clear unused entries to optimize storage.

## Summary

Smart Tables in the Movement blockchain provide a robust and flexible way to manage key-value data structures. Understanding their functionality and best practices will help you design efficient and reliable smart contracts.

## Resources

- [Smart Table Documentation](https://aptos.dev/en/build/smart-contracts/smart-table)
- [Smart Table Source Code](https://github.com/aptos-labs/aptos-core/blob/main/aptos-move/framework/aptos-stdlib/sources/data_structures/smart_table.move)

