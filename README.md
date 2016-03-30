# OptThrow

_OptThrow_ provides a convenient way to handle optionals with `do`, `try` and `catch`. The `|?` operator throws an `NilError` when the optional value is `nil`.

```swift
let a: Int? = Int(aString)
let b: Int? = Int(bString)

do {
  let sum = try a|? + b|?
} catch _ { // If `a` or `b` is `nil`
  // Error handling
}
```

## For What?

How can we handle multiple optional values easily?

For example, think about decoding a JSON and initialize an instance of the following `Person` type with the decoded values.

```swift
struct Person {
  let firstName: String
  let lastName: String
  let age: Int
}
```

Suppose that we have a library like [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) to decode JSONs. Then all values we get are optionals because every step of decoding can fail.

```swift
let firstName: String? = json["firstName"].string
let lastName: String? = json["lastName"].string
let age: Int? = json["age"].int
```

We need to unwrap those three optional values to initialize a `Person` instance.

An easy way is using _optional binding_.

```swift
if let firstName = json["firstName"].string,
  lastName = json["lastName"].string,
  age = json["age"].int {
  let person = Person(firstName: firstName, lastName: lastName, age: age)
} else {
  // Error handling
}
```

But we cannot always bind all optional values at once. We may need some additional operations between binding.

```swift
if let firstName = json["firstName"].string {
  // Some operations
  
  if let lastName = json["lastName"].string {
    // Some operations
    
    if let age = json["age"].int {
      let person = Person(firstName: firstName, lastName: lastName, age: age)
    } else {
      // Error handling
    }
  } else {
    // Error handling
  }
} else {
  // Error handling
}
```

It is awful. Using `guard` makes it better.

```swift
guard let firstName = json["firstName"].string else {
  // Error handling
}

// Some operations
  
guard let lastName = json["lastName"].string else {
  // Error handling
}

// Some operations
    
guard let age = json["age"].int else {
  // Error handling
}

let person = Person(firstName: firstName, lastName: lastName, age: age)
```

It is still bad. Error handling cannot be united. `guard` also force us to `return`, `break` or `continue` in its `else` clause. But such jumps are not always available. (Wrapping in a `while true { }` and `break`, or in a closure expression and `return` are available. But I do not want such hacks.)

Although we can use nested `flatMap`s, it is too complicated.

```swift
let person: Person? = json["firstName"].string.flatMap { firstName in
  json["lastName"].string.flatMap { lastName in
    json["age"].int.map { age in
      Person(firstName: firstName, lastName: lastName, age: age)
    }
  }
}
```

Applicative styles is much simpler to write. But they are not flexible and theoritically difficult.

```swift
let person: Person? = curry(Person.init)
  <^> json["firstName"].string
  <*> json["lastName"].string
  <*> json["age"].int
```

Something like Haskell's `do` notations are useful and convenient. Swift's `do`, `try` and `catch` are similar to them.

```haskell
sum = do
  a <- toInt aString
  b <- toInt bString
  Just (a + b)
```

```swift
let sum: Int?
do {
  let a: Int = try Int(aString)
  let b: Int = try Int(bString)
  sum = .Some(a + b)
} catch _ {
  sum = nil
}
```

So I wanted to make them available for optional values too.

_OptThrow_ provides the postfix `|?` operator for optional values, which unwraps the value or throws an `NilError` when the value is `nil`.

Initializing an `Person` instance can be written like the following with the `|?` operator.

```swift
do {
  let person: Person = try Person(
    firstName: json["firstName"].string|?,
    lastName: json["lastName"].string|?,
    age: json["age"].int|?
  )
} catch _ {
  // Error handling
}
```

### Why `|?`

It means separating (`|`) the wrapped value and `nil (`?`).

## Installation

### Carthage

```
github "koher/OptThrow" "master"
```

## License

[The MIT License](LICENSE)
