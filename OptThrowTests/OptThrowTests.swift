import XCTest
@testable import OptThrow

class OptThrowTests: XCTestCase {
    func testBasic() {
        do {
            let a: Int? = 2
            let b: Int? = 3
            
            do {
                let sum = try a|? + b|?
                XCTAssertEqual(sum, 5)
            } catch is NilError {
                XCTFail()
            } catch _ {
                XCTFail()
            }
        }
        
        do {
            let a: Int? = 2
            let b: Int? = nil
            
            do {
                _ = try a|? + b|?
                XCTFail()
            } catch is NilError {
            } catch _ {
                XCTFail()
            }
        }
        
        do {
            let a: Int? = nil
            let b: Int? = 3
            
            do {
                _ = try a|? + b|?
                XCTFail()
            } catch is NilError {
            } catch _ {
                XCTFail()
            }
        }
        
        do {
            let a: Int? = nil
            let b: Int? = nil
            
            do {
                _ = try a|? + b|?
                XCTFail()
            } catch is NilError {
            } catch _ {
                XCTFail()
            }
        }
    }
    
    func testSample() {
        do {
            /**/ let aString = "2"
            /**/ let bString = "3"
            
            let a: Int? = Int(aString)
            let b: Int? = Int(bString)
            
            do {
                let sum = try a|? + b|?
                /**/ XCTAssertEqual(sum, 5)
            } catch _ { // If `a` or `b` is `nil`
                // Error handling
                /**/ XCTFail()
            }
        }
        
        /**/ let json: JSON = .object([
        /**/     "firstName": .string("Albert"),
        /**/     "lastName": .string("Einstein"),
        /**/     "age": .number(27),
        /**/ ])
        
        do {
            let firstName: String? = json["firstName"].string
            let lastName: String? = json["lastName"].string
            let age: Int? = json["age"].int
            /**/ XCTAssertEqual(firstName, "Albert")
            /**/ XCTAssertEqual(lastName, "Einstein")
            /**/ XCTAssertEqual(age, 27)
        }
        
        do {
            if let firstName = json["firstName"].string,
                lastName = json["lastName"].string,
                age = json["age"].int {
                let person = Person(firstName: firstName, lastName: lastName, age: age)
                /**/ XCTAssertEqual(person.firstName, "Albert")
                /**/ XCTAssertEqual(person.lastName, "Einstein")
                /**/ XCTAssertEqual(person.age, 27)
            } else {
                // Error handling
                /**/ XCTFail()
            }
        }
        
        do {
            if let firstName = json["firstName"].string {
                // Some operations
                
                if let lastName = json["lastName"].string {
                    // Some operations
                    
                    if let age = json["age"].int {
                        let person = Person(firstName: firstName, lastName: lastName, age: age)
                        /**/ XCTAssertEqual(person.firstName, "Albert")
                        /**/ XCTAssertEqual(person.lastName, "Einstein")
                        /**/ XCTAssertEqual(person.age, 27)
                    } else {
                        // Error handling
                        /**/ XCTFail()
                    }
                } else {
                    // Error handling
                    /**/ XCTFail()
                }
            } else {
                // Error handling
                /**/ XCTFail()
            }
        }

        
        do {
            guard let firstName = json["firstName"].string else {
                // Error handling
                /**/ fatalError()
            }
            
            // Some operations
                
            guard let lastName = json["lastName"].string else {
                // Error handling
                /**/ fatalError()
            }

            // Some operations
                    
            guard let age = json["age"].int else {
                // Error handling
                /**/ fatalError()
            }
            
            let person = Person(firstName: firstName, lastName: lastName, age: age)
            /**/ XCTAssertEqual(person.firstName, "Albert")
            /**/ XCTAssertEqual(person.lastName, "Einstein")
            /**/ XCTAssertEqual(person.age, 27)
        }

        do {
            let person: Person? = json["firstName"].string.flatMap { firstName in
                json["lastName"].string.flatMap { lastName in
                    json["age"].int.map { age in
                        Person(firstName: firstName, lastName: lastName, age: age)
                    }
                }
            }
            /**/ XCTAssertEqual(person?.firstName, "Albert")
            /**/ XCTAssertEqual(person?.lastName, "Einstein")
            /**/ XCTAssertEqual(person?.age, 27)
        }
        
        do {
            let person: Person? = curry(Person.init)
                <^> json["firstName"].string
                <*> json["lastName"].string
                <*> json["age"].int
            /**/ XCTAssertEqual(person?.firstName, "Albert")
            /**/ XCTAssertEqual(person?.lastName, "Einstein")
            /**/ XCTAssertEqual(person?.age, 27)
        }
        
        do {
            do {
                let person: Person = try Person(
                    firstName: json["firstName"].string|?,
                    lastName: json["lastName"].string|?,
                    age: json["age"].int|?
                )
                /**/ XCTAssertEqual(person.firstName, "Albert")
                /**/ XCTAssertEqual(person.lastName, "Einstein")
                /**/ XCTAssertEqual(person.age, 27)
            } catch _ {
                // Error handling
                /**/ XCTFail()
            }
        }
    }
}

struct Person {
    let firstName: String
    let lastName: String
    let age: Int
}

enum JSON {
    case number(Double)
    case string(String)
    case boolean(Bool)
    case object([String: JSON])
    case array([JSON])
    case null
    case error
    
    subscript(name: String) -> JSON {
        guard case let .object(fields) = self else { return .error }
        guard let json = fields[name] else { return .error }
        return json
    }
    
    subscript(index: Int) -> JSON {
        guard case let .array(values) = self else { return .error }
        return values[index]
    }
    
    var double: Double? {
        guard case let .number(value) = self else { return nil }
        return value
    }
    
    var int: Int? {
        guard case let .number(value) = self else { return nil }
        return Int(value)
    }
    
    var string: String? {
        guard case let .string(value) = self else { return nil }
        return value
    }
    
    var bool: Bool? {
        guard case let .boolean(value) = self else { return nil }
        return value
    }
    
    var null: ()? {
        guard case .null = self else { return nil }
        return ()
    }
}

infix operator <^> { associativity left precedence 130 }
infix operator <*> { associativity left precedence 130 }

func <^><T, U>(lhs: T -> U, rhs: T?) -> U? {
    return rhs.map(lhs)
}

func <*><T, U>(lhs: (T -> U)?, rhs: T?) -> U? {
    return lhs.flatMap { lhs in rhs.map(lhs) }
}

func curry<A, B, R>(f: (A, B) -> R) -> A -> B -> R {
    return { a in { b in f(a, b) } }
}

func curry<A, B, C, R>(f: (A, B, C) -> R) -> A -> B -> C -> R {
    return { a in { b in { c in f(a, b, c) } } }
}