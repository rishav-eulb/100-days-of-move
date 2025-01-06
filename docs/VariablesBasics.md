# Move Basics I: Variables, References and More

Till now, we learned how to interact with Global Storage, Deployments and Error handling. Before moving forward, let's talk about basics of Move language how it behaves and what makes it different from other programming languages.

## Variables

### Defining Variables

Like any other programming lanuage, we can declare and intialize variables in Move as well.

```Move
let x: u8 = 1;
```

Here, we have defined a variable `x` of type `u8` with an assigned value of `1`.

Apart from that, one can declare and define variables separately, making it useful in case of conditional assignments like shown below.

```Move
let x; // Declaration
if (cond) {
  x = 1 // Initialization
} else {
  x = 0 // Initialization
}
```

In the above example on the basis of the condition one can initialize the value of `x` to `0` or `1`.

However, it's important to note that you can't use a variable before it's initialized.

```Move
let x;
x + x // ERROR!
```

Since, the value of `x` is not initalized the expression `x+x` would throw an error.

As shown in the first example one can annotate types for a variable.

```Move
let x: T = value;
```

Where `T` is the type of the variable. However, in a lot of cases type annotations is not required and Move automatically inferences the type.

```Move
let x = true; // It is inferred from the statement that x has boolean type.
```

Now as a part of naming the variables, they can contain underscores `_`, letters `a` to `z`, letters `A` to `Z`, and digits `0` to `9`. Variable names must start with either an underscore `_` or a letter `a` through `z`. However, they *cannot* start with uppercase letters.

Similarly, we can define variables with struct as shown below.

```Move
struct Test {
    x: u8
}

fun test() {
    let y = Test{x: 1};
    let Test{x: _} = y;
}
```

As one can see, we can define struct variables just like defining a normal variable as illustrated in the line `let y = Test{x: 1}`.

There are a lot more caveats one can look into when reading about assignments and declaring local variables. Kindly refer to the [resources](#resources-variables-basics) section below for more details.

### Unpacking

Apart from declaring and defining variables one can can also unpack variables explicitly struct variables. But what do we mean by unpacking? Unpacking means to destroy the variable and pass onto the ownership to another variable.

```Move
let x = Test{x: 1};
let Test{x: y} = x;
```

Here we are using defining a variable `x` and then unpacking it's values. Since `x` has no ability to copy it's value. On calling the final line we are transferring the ownership of x to another variable and then unpacking the struct and assigning the value of field `x` to variable `y`.

On re-using the variable x, we will again get an error as the variable ceases to exist.

```Move
let x = Test{x: 1};
let Test{x: y} = x;
let y = x; // ERROR variable has moved from x
```

Similarly there are many more scenarios of unpacking where we cannot unpack a variable and use the value of it's field further. In case the user's don't want to use a particular field values then they can use `_` to drop the field value.

```Move
struct Test2 {
    x: u8,
    y: u8
}
```

Here, we have defined another struct `Test2`. Let's define the variable and unpack it.

```Move
let test = Test2{x: 1, y: 1};
let Test2{x: x1, y: _} = test; // value of test is moved where x1 has test.x value
// and value of test.y is dropped.
```

As one can see in the example above value of test has moved to the anonymous declaration where `x1` has value of `test.x` however, value of `test.y` has been dropped since it's not assigned to any variable.

There are lot more use-cases where one can unpack to assign subtypes to different variables.

Also, note that, any struct without any ability is defined as a Resource since they cannot be copied or dropped post initialization and there ownership has to be transferred. As we have seen the numerous examples above we had to explicity unpack the struct variables in order to transfer there ownership.

This ensures that resources are never dropped or copied intentionally thereby preserving there integrity.

## References

Most of the primitive types in Move (`u8`, `u16`, `u32`, `bool` and many more) have a `copy` ability. Meaning that whenever we assign the value of a variable with a primitive type and then assign that variable to another variable the value is also copied.

This can cause issues in cases wherein users can unintentionally create a lot of copies for the same variables by passing it across functions or by defining new variables with existing variables. It can lead to huge memory usage.

Move mitigates this issue my giving us references. References are pointers which point to a given variable.

```Move
let x = 1;
let y = &mut x;
*y = 2;
x == *y // This will be true since y is pointing to variable x.
```

As shown in the example above by setting the value of pointer `y` to 2 we in-turn change the value of variable `x` since `y` is a reference to `x`.

### Operators

Move gives us a set of operators which can be used to fulfill use-case of references.

- `&e` - Is an immutable reference of variable `e`. By immutable we mean we can't modify the value of variable `e` but we can always read the value present at `e`.
- `&mut e` - Is an mutuable reference of variable `e`. By mutuable we mean whatever variable is assigned this value can in turn change the value present at variable `e`.
- `&e.f` || `&mut e.f` - In move if we want to create a reference for field `f` for variable `e` we can do that as well. `&e.f` denotes give me the reference for field f of variable `e`. Similarly `&mut e.f` denotes give me a mutable reference for field `f` of variable `e`.
- `freeze(e)` - If `e` is a mutable reference then we can call `freeze(e)` to get the immutable reference out of it.

### Modifying References

In move we can use the `*` operator to read and write the values of the variables pointed by a reference.

- `*e` - This gives us the value of the variable pointed by `e`.
- `*e1 = e2` - Here we assign value `e2` to the variable pointed by `e1`. Note that there `e1` should be a mutable reference for the type T which would be the type of underlying variable.

Apart, from modifying the value of underlying variables references can also be copied.

```Move
let s = &mut S{f: 1}; // s has type &mut of S
let s_copy1 = s; // ok
let s_extension = &mut s.f; // also ok
let s_copy2 = s; // still ok
```

In the sample shown above one can copy `&mut S` multiple types which is contrary to normal Structs. Move allows references to be copied i.e. reference of a type T always will have a copy ability.

However, in order for underlying value for a reference to be read, the underlying type should have the copy ability.

```Move
fun copy_resource_via_ref_bad(c: Coin) {
    let c_ref = &c;
    let counterfeit: Coin = *c_ref; // not allowed!
    pay(c);
    pay(counterfeit);
}
```

Here, when we are creating a reference to `c` variable, we can't dereference it as that would create a copy of variable `c` to be assigned to `counterfeit`. This would only be allowed if `Coin` itself has a copy ability.

Similarly for a reference underlying value to be modified the underlying type should have drop ability.

```Move
fun destroy_resource_via_ref_bad(ten_coins: Coin, c: Coin) {
    let ref = &mut ten_coins;
    *ref = c; // not allowed--would destroy 10 coins!
}
```

Here underlying value of `ref` or `*ref` can only be assigned if `Coin` has drop ability. Since we would require to drop the underlying value of `ref` so that it can be assigned `c`.

### Restrictions

It's important to note that references can't be stored in global persistant storage and need to be dropped immediately once not being used anymore. Also references don't have store ability i.e. they can't be stored in global persistant storage even as a field.

Therefore, no struct field can be a reference to a type.

## Move and Copy

In Move language we have the ability to specify if we want to move a variable or copy a variable.

```Move
let x = 1;
let y = move x;
x == 1; // Throws error since x has been moved to y. 
```

Move allows us to move the value from one variable to another destroying the current variable.

```Move
let x = 1;
let y = copy x;
x == 1; // No error since value of x has been copied to y.
```

Here since we have explicity used copy, variable `x` is not destroyed thereby keeping the last statement valid. However, in daily use-cases we don't have to specify move or copy when defining new variables or passing existing once.

Move figures it out on the basis of the ability of the type. If a type has `copy` ability then the variable is copied or else it is moved. Let's look at an example.

```Move
struct Test {
   x: u8
}

fun inner(t1: Test) {
    let Test{x: _} = t1;
}

fun test() {
    let t = Test{x: 1};
    inner(t)
    t.x = 1; // Throws error since t has been moved to t1.
}

```

However, if we add copy ability by modifying the line.

```Move

struct Test has copy {
    x: u8
}
```

We would see that the error at line `t.x = 2` would no longer exist. This is because Move has implicitly understood that value of `t` should be copied to `t1` and not moved.

## Type casting
In move, you can't perform operations of different types
```
fun plus_two_types(): u64 {
    let x: u8 = 10;
    let y: u32 = 12;
    x + y // x and y are different types -> failed to compile
}
```

You'll need to convert the variable to be of same type
```
fun plus_two_types(): u64 {
    let x: u8 = 10;
    let y: u32 = 12;
    (x as u32) + y // This will work as x and y are of same type
}
```

## Summary

Today, we learned about:

- How to declare and unpack variables.
- How to declare and use references.
- Talked about Move and Copy ability in further detail.
- Understood type casting.

## Resources <a id = "resources-variables-basics"></a>

- [Local Variables and Scope](https://move-language.github.io/move/variables.html)
- [References](https://move-language.github.io/move/references.html)
- [Integers](https://move-language.github.io/move/integers.html)
- [Bool](https://move-language.github.io/move/bool.html)
