import Foundation

public struct Person {
    let firstName: String
    let lastName: String
    let birthYear: Int
    
    public init(firstName: String, lastName: String, birthYear: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.birthYear = birthYear
    }
}
