/*:
 
 # Functions as Data
 ## From Advanced Swift
 
 This explains how we can leverage on the power of Swift functions to use them as **FirstClassObjects**
 */

import Foundation

//: ## Basic Intro
//: To start basic, we can assign functions to variables and return functions from funcitons
//: Important to notice that  *named parameters* don't exist in functions as objects

func printInt(i: Int) {
    print("U passed: \(i)")
}

let myFuncVar = printInt
myFuncVar(10)

func returnFunc() -> (Int) -> String {
    func innerFunc(i: Int) ->  String {
        return "You will return \(i)"
    }
    return innerFunc
}

let myReturnedFunc = returnFunc()
myReturnedFunc(20)

//: ## Capturing variables
//: In the following example, the var `counter` gets captured by the func `innerFunc` which is returned in the outer function.
//: Each var (counterF1 and F2) have their own captured variable `counter` and they will keep it around until the captured func gets destroyed.

func counterFunc() -> (Int) -> String {
    var counter = 0
    func innerFunc(i: Int) -> String {
        counter += i
        return "Running \(counter)"
    }
    return innerFunc
}

let counterF1 = counterFunc()
counterF1(2)
counterF1(10)

let counterF2 = counterFunc()
counterF2(5)
counterF2(1)

//: **Closure**: Combiantion of a func and an environment of captured variables
//:
//: ## Inout parameters and mutating methods
/*:
 When using `&` in `inout` params, they are **NOT** passed by reference. They are passed as **`passed-by-value-and-copy-back`**
 
 `"An inout parameter has a value that is passed in to the function, is modified by the function, and is passed back out of the function to replace the original value."`
 
 
 The `UnsafeMutablePointer` is **passed by reference**
 */

/*:
 ## KeyPaths
 It describes a path through a value hierarchy starting at the root value. In other words, they defer a call to the getter/setter of a property
 **They can describe properties and subscripts**
 
 IMPORTANT: They are **values**. This comes with certain advantages:
 1. You can test for *Equality*
 2. They are *Hashable* -> They can be used as keys in dicts
 3. Stateless
 */

struct Address {
    var street: String
    var city: String
}

struct Citizen {
    let name: String
    let age: Int
    var address: Address
}

let nameKeyPath = \Citizen.name
let cityKeyPath = \Citizen.address.city

// This is Writable because all properties that form the path are mutable
type(of: cityKeyPath)
// This is only keyPath because it's not mutable
type(of: nameKeyPath)

var franzis = Citizen(name: "Franzis", age: 24, address: Address(street: "Unv 1100", city: "Berlin"))
franzis[keyPath: cityKeyPath] = "Paris"
//: We can also use them to describe subscripts

let tom = Citizen(name: "Tom", age: 12, address: Address(street: "Main st", city: "CDMX"))
let teemu = Citizen(name: "Teemu", age: 28, address: Address(street: "Snow St", city: "Helsinki"))
let citizens = [tom, franzis, teemu]

citizens[keyPath: \.[1].name]

//: You can **append** KeyPaths
//:
//: KeyPath<Citizen, String> + KeyPath<Stirng, Int> = KeyPath<Citizen, Int>

// Swift.KeyPath<Citizen, Swift.Int>
let nameCountKeyPath = nameKeyPath.appending(path: \.count)

//: ### How can we leverage them?
//: We are familiar with a code like this:
var over18 = citizens.sorted(by: { $0.age < $1.age })
over18

//: New helper to evaluate on the same property
func their<Type, T: Comparable>(_ keyPath: KeyPath<Type, T>,
                                comparedWith comparator: @escaping (T, T) -> Bool = (<)) -> (Type, Type) -> Bool {
    return { obj1, obj2 in
        return comparator(obj1[keyPath: keyPath], obj2[keyPath: keyPath])
    }
}

over18 = citizens.sorted(by: their(\.age))
over18

//: ## Functions in action
/*:
 Imagine the following problem:
 
 Having a struct `Person` with `firstName`, `lastName` and `birthYear`. How could we sort an array of persons based on:
 1. LastName
 2. First Name
 3. BirthYear
 
 Swift doesn't have SortDescriptor, so how do we combine this sortings?
 Using **functions as data**!
 */

struct Person {
    let firstName: String
    let lastName: String
    let birthYear: Int
}

let people = [
    Person(firstName: "Eduardo", lastName: "Vaca", birthYear: 1995),
    Person(firstName: "Eduardo", lastName: "Carax", birthYear: 2000),
    Person(firstName: "Julian", lastName: "Carax", birthYear: 1999),
    Person(firstName: "Julian", lastName: "Carax", birthYear: 1980)
]

/// Let's define a sorting predicate that returns `true` if the first value should be ordered before the second
typealias SortDescriptor<Root> = (Root, Root) -> Bool

/// Builds a `SortDescriptor` function from a sorting predicate
/// and a `key` function thet, given an element to compare, produces
/// the value that should be use by the sorting predicate.
func sortDescriptor<Root, Value>(
    key: @escaping (Root) -> Value, /// This basically describes how to drill down into an element of type Root and extract type Value that is relevant for comp.
    by areInIncreasingOrder: @escaping (Value, Value) -> Bool)
    -> SortDescriptor<Root>
{
    return { areInIncreasingOrder(key($0), key($1)) }
}

let sortByBirthYear: SortDescriptor<Person> = sortDescriptor(key: { $0.birthYear }, by: <)
people.sorted(by: sortByBirthYear)

/// We can overload the variant that works for all `Comparable` types
func sortDescriptor<Root, Value>(key: @escaping (Root) -> Value) -> SortDescriptor<Root> where Value: Comparable {
    return { key($0) < key($1) }
}
let sortByBirthYear2: SortDescriptor<Person> = sortDescriptor(key: { $0.birthYear} )
people.sorted(by: sortByBirthYear2)

/// Adding support for a three-way `ComparisonResult`
func sortDescriptor<Root, Value>(
    key: @escaping (Root) -> Value,
    ascending: Bool = true,
    by comparator: @escaping (Value) -> (Value) -> ComparisonResult)
    -> SortDescriptor<Root>
{
    return { lhs, rhs in
        let order: ComparisonResult = ascending
            ? .orderedAscending
            : .orderedDescending
                
        return comparator(key(lhs))(key(rhs)) == order
    }
} /// This is variant and doesn't rely on runtime execution

let sortByFirstName: SortDescriptor<Person> = sortDescriptor(key: { $0.firstName }, by: String.localizedStandardCompare)
people.sorted(by: sortByFirstName)

let sortByLastName: SortDescriptor<Person> = sortDescriptor(key: { $0.lastName }, by: String.localizedStandardCompare)

//: ### How to combine the descriptors that we have?
/// If we want to support multiple sort descriptors, we need a function to combine multiple into one
func combine<Root>(sortDescriptors: [SortDescriptor<Root>]) -> SortDescriptor<Root> {
    return { lhs, rhs in
        for areIncreasingInOrder in sortDescriptors {
            if areIncreasingInOrder(lhs, rhs) { return true }
            if areIncreasingInOrder(rhs, lhs) { return false }
        }
        return false
    }
}

let combined: SortDescriptor<Person> = combine(sortDescriptors: [sortByFirstName, sortByLastName, sortByBirthYear])
people.sorted(by: combined)

//: ### We could even use KeyPaths here

/// Adding another SortDescriptor using KeyPaths
func sortDescriptor<Root, Value>(key: KeyPath<Root, Value>) -> SortDescriptor<Root> where Value: Comparable {
    return { $0[keyPath: key] < $1[keyPath: key] }
}

let streetSortDescriptor: SortDescriptor<Citizen> = sortDescriptor(key: \.address.street)
citizens.sorted(by: streetSortDescriptor)
