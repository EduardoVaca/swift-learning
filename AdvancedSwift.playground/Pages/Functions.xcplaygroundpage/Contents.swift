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
//: Each var (counterF1 and F2) have their own captured variable `counter`.

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

