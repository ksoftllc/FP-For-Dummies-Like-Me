import Foundation
/*:
 All source code in this playground is copyrighted and provided as is under the  [MIT License](@next)
 
 # Functional Composition in Swift for Dummies Like Me - Part 3
 
 ![](puzzlePieces.png)
 
 This is the third installment of my series on function composition in Swift. If you haven't already, I suggest you read [part 1](https://medium.com/@chuck.krutsinger/functional-composition-in-swift-for-dummies-like-me-part-1-86527efac58e) and [part 2](https://medium.com/@chuck.krutsinger/functional-composition-in-swift-for-dummies-like-me-part-2-db7663e7b7ee) because this article builds on the previous articles.
 
 ## Recap of Parts 1 and 2
 
 Previously, I discussed how understanding function composition begins with understanding that functions have a shape defined by the input types and output types of the function. Up to now, the discussion has focused on functions that have a single input and a single output. Function shape is critical to functional composition because composing (or connecting) functions requires that the input and output shapes be the same, i.e. the previous function must pass a value that the next function can take as input.
 
 The first shape that I discussed is an endomorphism, which is a function that has the same input and output types. Using A as a generic type, its shape is `(A) -> A`. Such functions can be used to produce a modified version of some other thing. Examples from the last post included decorating strings by uppercasing them or adding an exclamation. Another example included creating a complete HTTP header by composing functions that each provide parts of the header. As this series of posts evolves, there will be more and more examples of how to use such shapes in composing powerful functions from smaller functions.
 
 The next shape that I discussed is a morphism, which is a function that has different input and output types. Its shape is `(A) -> B`. Examples include single argument initializers, Int to String, or String to Int, just to name a few. I also discussed how, as is the case with initializers, Swift generates many of these functions for you and you can access them as if they were free functions.
 
 I previously also introduced 2 infix operators: `|>` (called pipe forward) and `>>>` (called forward compose). Many projects push back on using these infix operators, but they are common in functional programming languages and I am using them in these articles to make the compositions easier to read. They allow composed functions to read from left to right rather than from the innermost function to the outermost function.
 
 Pipe forward, `|>`, passes the value to the left as input the function on the right. Therefore, `x |> f |> g` is equivalent to `g(f(x))`.
 
 Forward compose, `>>>`, forms a function by composing the function on the left with the function on the right to create a new function. Therefore, `let h = f >>> g` will produce a new function `h` equivalent to `{ x in g(f(x)) }`. You can call `h(x)`, which is equivalent to `g(f(x))`.
 
 Finally, we have introduced some important terms: endomorphism, morphism, point free style, and free function. If you aren't familiar with these, I recommend you review the previous articles or look them up online.
 
 ## Contextual Wrappers Around Values
 
 In Swift, we work with types that wrappers for other types all the time. For example, we are very familiar with `Array`s and `Optional`s. Both provide a way to wrap a value or values in useful ways. In fact, neither has meaning on its own. To define an `Array`, you must define a type it will contain. Same applies to an `Optional`. Swift 5 introduces another very useful wrapper, the `Result` type, that also provides a very useful context for handling the values they enclose. You have probably also created your own wrapper types. Structs, classes, and enums with associated values can all be used to wrap other values and provide useful abstractions for operating on those values.

 One way to conceptualize a wrapper type is to think of it as a type constructor. Just as a class or struct has its initializer (a.k.a. constructor), these wrapper classes have a way of constructing a new type. `Array<Int>` is not the same type as `Array<String>`. `Array<Int>` constructs a very specific type of `Array` that wraps an `Int`. Generics give us a way to pass a type as an argument into the initializer and create a new type.
 
 Now I want to look at useful compositions of these wrapper types. You've probably already used `map`, `filter`, and `reduce` on `Array`s, but that is just the tip of the iceberg. But before I do, I need to introduce a new term: "higher order function".
 
 ## Introducing Higher Order Functions
 
 A higher order function is simply a function that takes a function or closure as an argument. You'be been using them if you've ever used callbacks. Callbacks are functions that will execute in the future, when some other action has completed or failed. But there are other ways to compose other than callbacks. Let's look at some important ways to compose using morphisms and wrapper types.
 
 ## Introducing Functors - Think Map-able
 
 Feel free to search online for the complete definition of a Functor. For the purposes of this discussion, what you need to know is that a Functor is a wrapper type that has a `map` function. A `map` function takes a transformation function (or morphism) as an argument and applies that transformation to the value or values that are beging wrapped in the Functor. As you recall, a transformation function has the shape `(A) -> B`. Here is an example using an `Array<Int>`'s `map` function:
 */
print([1,2,3].map { $0 + 1 })


/*:
 As you can see, the values in the `Array<Int>` each get transformed by the function that was passed into `map`.
 
 A mistake I often see is thinking that `map` is for operating on collections. It certainly is useful for collections, but thinking of map as a way to operate on collections limits you to collection types. In Swift, there are `map` functions in the Swift standard library for `Optional` and for `Result` types as well, and you can probably define `map` for many other types that you define in your systems once you start to recognize where they are useful. Neither `Optional` nor `Result` is a collection and both of them are `map`-able. Both also have a state that cannot be mapped. When an `Optional` is `nil`, it cannot apply the transformation function provided to the `map` function because there is no value, so `map` skips executing the transformation function and the `Optional` value remains nil. This behavior is much like how Swift optional binding works, but without all the boilerplate. First, an example using optional binding rather than `map`:
 
 */

let site = "http://countermind.com"

if let siteUrl = URL(string: site) {
    let siteContents = try? String(contentsOf: siteUrl)
}

/*:
 Next, an example using `Optional`'s implementation of `map` to accomplish same task.
 */

let contents = URL(string: site)
    .map { siteUrl in try? String(contentsOf: siteUrl) }

/*:
 Finally, an example using `Optional`'s implementation of `map` to show that the transformation is skipped when the `Optional` is nil.
 */

let bogusSite = "xxxhttp://countermind.comxxx"
let noContents = URL(string: bogusSite)
    .map { siteUrl in try? String(contentsOf: siteUrl) }

/*:
 In a similar way, the value wrapped in the new Swift 5 `Result<A,E>` type cannot be transformed when it is a `.failure`, so the transformation function is skipped and the result of a chain of actions will be `.failure`. This will prove very useful in composing a chain of actions where you only want to execute steps in the chain when the previous steps have succeeded. I'll come back to that and expand on it further on in this article. Here are some snippets that demonstrate how `map` works on the `Result` type:
 */

enum DownloadError: Error {
    case downloadFailed(message: String)
}

let success: Result<String, DownloadError> = .success("succeeded")
let failure: Result<String, DownloadError> = .failure(.downloadFailed(message: "failed"))

let successMapped = success.map { value in "The map operation \(value)" }
let failureMapped = failure.map { _ in print("This never executes") }

print(successMapped)
print(failureMapped)

/*:
 The net result of all this is that you can chain together actions that are dependent on the outcome of the previous action without using nested ifs. The `map` function will correctly invoke or skip the transformation. However, there is an issue lurking in these examples. If the transformation function in the `map` of an `Optional` produces another `Optional`, then the result is an `Optional<Optional<B>>`, i.e. a nested `Optional`. Perfectly valid, but difficult to deal with. Look at the type of `validContents` in the example below:
 */

let validContents = URL(string: site)
    .map { siteUrl in try? String(contentsOf: siteUrl) }

type(of: validContents)

/*:
 There is a solution to avoid this nesting, and it's called `flatMap` in Swift (and other, but not all, functional languages).
 
 ## Introducing Monads - Think Mappable & FlatMappable
 
 As before, feel free to search online for the complete definition of a Monad. The definition from category theory is rather complex to parse. For the purposes of this discussion, what you need to know is that a Monad is a wrapper type that has a `flatMap` function as well as a `map` function. A `flatMap` function takes a specific type of transformation function (or morphism) as an argument and applies that transformation to the value or values that are wrapped. The specific transformation is one where the input type is the same as the wrapped type and the output type is the same type as the Monad itself but wraps a transformed value. In other words, the shape is `(A) -> M<B>` where M represents the Monad type being flatMapped. In other words, `flatMap` on `Optional<A>`, expects a transformation function with the shape `(A) -> Optional<B>`, 'flatMap` on `Result<A,E>` expects a transformation function with a shape of `(A) -> Result<B,E>`, and 'flatMap` on an `Array<A>` expects a transformation function of shape `(A) -> [B]`. You get the idea.
 
 In the previous example, the closure `{ siteUrl in try? String(contentsOf: siteUrl) }` has a shape of `(URL) -> Optional<String>`. And since `map` on `Optional` wraps the transformed value in an `Optional`, the result was a nested `Optional<Optional<String>>`. However, with `flatMap` on an `Optional`, the result is not nested into another `Optional` and you simply get an `Optional<String>`. Here is the same chain using `flatMap`:
 */

let notNested = URL(string: site)
    .flatMap { siteUrl in try? String(contentsOf: siteUrl) }
type(of: notNested)

/*:
 ![From Scott Wlaschin's Railway Oriented Programming Presentation](Recipe_Railway_Compose2.png)
 ## Composing with Map and FlatMap
 
 By chaining together operations using `map` and `flatMap`, you can create what Scott Wlaschin calls "railway oriented programming" (See his presentation at [https://fsharpforfunandprofit.com/rop/](https://fsharpforfunandprofit.com/rop/)). He likens these chained functions to a two-track railway where at any step in the chain, the contents can be routed onto the failure or nil track just by the nature of how `map` and `flatMap` operate and without using branching. Let's work through some examples that illustrate this style of programming.
 
 For this example, we want to look up a `getEvents` service's URL value from a `Dictionary` of event URL strings. The service will send back a JSON dictionary of `["index" : "event name"]` values. We'll look for the event name corresponding to index "1". The final result will either be a name or a nil if the index is not present in the dictionary.
 */
let getEvents = "getEvents"
let  services = [
    getEvents: "http://swipe.countermind.com:8080/SwipeServer/Service.asmx/GetEvents"
]

let eventIndex = "1"

public struct EventsJson: Codable {
    public let events: Dictionary<String, String>
}

let eventAtIndex = services[getEvents]
    .flatMap { URL(string: $0) }
    .flatMap { try? Data(contentsOf: $0) }
    .flatMap { try? JSONDecoder().decode(EventsJson.self, from: $0) }
    .map { $0.events[eventIndex] }

/*:
 Now, compare that to the imperative style of programming the same sequence of steps using a *pyramid of doom*.
 */

var eventAtIndex2: String? = nil
if let eventServiceAddress = services[getEvents] {
    if let url = URL(string: eventServiceAddress) {
        if let data = try? Data(contentsOf: url) {
            if let eventsJson = try? JSONDecoder().decode(EventsJson.self, from: data) {
                eventAtIndex2 = eventsJson.events[eventIndex]
            }
        }
    }
}

/*:
 ## TL;DR Conclusions
 
 Functional composition patterns rely heavily on Functors (think `map`-able) and Monads (think `flatMap`-able). Both are wrapper types that provide a structure around another type. Array, Optional, and Result are examples of wrapper types that are Monads. Once you start to see how to use them, you'll define your own Monads or realize that you already have Monads waiting for you to add `map` and `flatMap` functions to them.
 
 With Monads, you can chain together operations in a succinct and expressive way that cuts down on boilerplate code such as `if let... else...`. Some Monads, such as `Optional` or `Result`, have two possible states: one where there is a wrapped type and the other where that wrapped type is missing. Those Monads permit a two-track design pattern for their mapping operations where steps get bypassed in the chain of operations if the wrapped type is absent. This has been likened to a two-track railway where one track is for successfully chaining successive operations and the other for bypassing the remaining chain of operations when one step fails.

 ## Next Topic: Currying
 
 In my next post, I want to dive into currying and how it can be used to chain together the free functions that are part of the standard library and part of your own type defintions. This should open up a wide world of functional compositions for your future projects.
 
*/

