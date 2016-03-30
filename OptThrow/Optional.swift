postfix operator |? {}

public struct NilError: ErrorType {}

postfix public func |?<T>(optional: T?) throws -> T {
    guard let value = optional else {
        throw NilError()
    }
    
    return value
}