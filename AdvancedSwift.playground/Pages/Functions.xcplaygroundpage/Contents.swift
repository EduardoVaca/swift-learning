/*:
 
 # Functions as Data
 ## From Advanced Swift
 
 This explains how we can leverage on the power of Swift functions to use them as **FirstClassObjects**
 */

import UIKit

//: ### Basic Intro
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

//: ### Capturing variables
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
//: ### Inout parameters and mutating methods
/*:
 When using `&` in `inout` params, they are **NOT** passed by reference. They are passed as **`passed-by-value-and-copy-back`**
 
 `"An inout parameter has a value that is passed in to the function, is modified by the function, and is passed back out of the function to replace the original value."`
 
 
 The `UnsafeMutablePointer` is **passed by reference**
 */

/*:
 ### KeyPaths
 It describes a path through a value hierarchy starting at the root value
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
    var address: Address
}

let nameKeyPath = \Citizen.name
let cityKeyPath = \Citizen.address.city

// This is Writable because all properties that form the path are mutable
type(of: cityKeyPath)
// This is only keyPath because it's not mutable
type(of: nameKeyPath)



