import Foundation

@propertyWrapper
public struct UserDefault<Value: Codable> {
    public init(key: String, defaultValue: Value, container: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.container = container
    }
    
    let key: String
    let defaultValue: Value
    var container: UserDefaults = .standard

    public var wrappedValue: Value {
        get {
            let decoder = JSONDecoder()
            if let savedParam = UserDefaults.standard.object(forKey: key) as? Data {
                if let result = try? decoder.decode(Value.self, from: savedParam) {
                    return result
                }
            }
            return defaultValue
        }
        set {
            // If the value is an optional and contains nil remove the key
            if let optional = newValue as? AnyOptional, optional.isNil {
                UserDefaults.standard.removeObject(forKey: key)
            } else {
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(newValue) {
                    UserDefaults.standard.set(encoded, forKey: key)
                }
            }
        }
    }
    
}

fileprivate protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool { self == nil }
}

