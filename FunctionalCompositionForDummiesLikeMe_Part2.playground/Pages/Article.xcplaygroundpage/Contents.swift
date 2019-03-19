/*:
 All source code in this playground is copyrighted and provided as is under the  [MIT License](@next)
 
 # Functional Composition in Swift for Dummies Like Me - Part 2
 
 This is the second in a series of posts hoping to help Swift programmers who are less experienced in functional programming be able to apply functional techniques to write better software using Swift. If you haven't already read it, you may want to read [part 1](https://medium.com/@chuck.krutsinger/functional-composition-in-swift-for-dummies-like-me-part-1-86527efac58e) before reading this post. This series uses a minimum of technical jargon, especially jargon from category theory which can be very hard to grok. Instead, I try to use simpler terminology while not sacrificing clarity.
 */
import Foundation



/*:
 ## Recap of Part 1
 If you've already read the first post, you can skip ahead to the next section introducing shape 2.
 
 In the previous post I discussed how understanding function composition begins with understanding that functions have a shape defined by the input types and output types of the function. For now, the discussion is focused on functions that have a single input and a single output. Function shape is critical to functional composition because composing (or connecting) functions requires that the input and output shapes be the same, i.e. the previous function must pass a value that the next function can take as input.
 
 The first shape that I discussed is an endomorphism, which is a function that has the same input and output types. Using A as a generic type, its shape is (A) -> A. Such functions can be used to produce a modified version of some other thing. Examples from the last post included decorating strings by uppercasing them or adding an exclamation. Another example included creating a complete HTTP header by composing functions that each provide parts of the header. As this series of posts evolves, there will be more and more examples of how to use such shapes in composing powerful functions from smaller functions.
 
 Finally, the first post introduced the pipe forward infix operator to make it easier to read the compositions. This operator takes the value to the left and provides it as the argument to the funcion on the right to produce a new value. Here are some examples:
 */
let shout = { (s: String) -> String in s.uppercased() }

let exclaim = { s -> String in s + "!" }

"holy crap"
    |> shout
    |> exclaim

"that's too easy"
    |> shout
    |> exclaim
    |> exclaim
    |> exclaim


/*:
 ### What is Point-Free Style?
 Before introducing the next function shape, I'd like to introduce a term that you will want to remember: *point-free style* We've already been using this style in the examples above. A function used in *point-free style* is used just like a variable or constant name, without the parenthese and arguments. When composing functions, we almost always just connect them in a way that the output of the previous function becomes the input of the next and we reference the functions without all the noise of the parentheses and argument lists.

## Shape 2 — Transformation (a.k.a. Morphism) — (A) -> B
The next basic function shape is the transformation, a function that takes one type and returns another, which is known as a morphism. As I mentioned in the previous post, I'm going to avoid these kinds of terminologies because they have their place in academics but can be obtuse to those just starting out in functional programming. I have included these terms so that newer functional programmers will recognize them when they see them, but I will avoid using these terms.
 
 Transformations are very common in our code. Examples might include a validator returning a Bool:
 */

verifyUrl("http://countermind.com")

/*:
 Or a function to covert a String to an Int:
 */

func intFromString(_ string: String) -> Int {
    return Int(string) ?? 0
}

intFromString("42")

/*:
 ### What are Free Functions?
 Time to introduce another term that must become part of the vocabulary of anyone learning functional programming: *free function*. A *free function* is a function that is not part of a class or struct or enum. In Swift, you can define a function at the same level that you define other types. A function can be all alone by itself in a .swift source file and does not need to be part of any other type.
 
 In Swift, there are free functions built into the way classes, structs, and enums are implemented. You can access them apart from the type they were defined for. Even the init function can be accessed as a free function! As functional programmers, we can use these Swift-generated free functions to compose other functions. For example, if we define a struct with only one property, then Swift automatically generates an init function with one argument to initialize that struct. That init function can be accessed as a free function that takes one argument and returns an instance of that struct. Here is an example.
 */

struct Website {
    let address: String
}

Website.init(address:) // (String) -> Website

/*:
 This free function version of the init function can be composed with other functions. Here is an example of using this init with the pipe forward operator and print.
 */
"http://countermind.com"
    |> Website.init(address:)
    |> { w in print(dump(w)) }

/*:
 
 For those who use RxSwift, what might help illustrate the usefulness of the free function version of an initializer is seeing how it might be used. If you don't know RxSwift, you might want to skip this example.
 
 If your app had a UITextField used to provide the website address for a company, and you wanted to update that information for the company. You might have an Observable stream that looks like the following:
 
 ````
    saveButton.rx.tap
        .withLatestFrom(websiteAddress.rx.text)
        .filter(verifyUrl)
        .map(Website.init(address:))
        .subscribe(onNext: updateWebsiteAddress)
        .disposed(by: bag)
 ````
 
 Swift also permits instance functions to be accessed as free functions. However, I'm going to save that discussion for a future post because such functions usually require some manipulations to be useful. This topic will require more space than I have within this post.

 ### Introducing the Forward Compose operator: >>>
 In functional programming you will want to compose new functions made up of other smaller functions. For example, you may want want to compose a function that does a series of math operations on an Int and then converts the answer to a String.
 
 ````
 let x = { (i: Int) in
     return String(square(increment(i)))
 }
 ````
 
 As was discussed when introducing the pipe forward |> operator, this reads from innermost to outermost, which requires you to interpret it as increment, then square, then convert to string. Since we are creating a new function to work with any input value, we can't use the |> operator. Pipe forward requires a value. So we need a new operator to compose functions from other functions. Here we can use the forward composition or "right arrow" operator >>>. This would read as:
 */

 let x = increment >>> square >>> String.init
 x(2)

/*:
 The >>> operator allows us to read from left to right and easily understand the sequence of operations. The function x is a new function that increments an int, then squares that int, then converts the result to a String.
 
 The implementation of >>> is really very simple. Given two functions, f and g:
 ````
 f >>> g
 ````
 equates to `{ x in g(f(x)) }`. It reads as "f then g".

 ##Conclusion
 Functional programming is all about composing complex functionality from small, well defined functions. To do that, it is very useful to begin with functions that have specific shapes. So far, we have defined two closely related shapes: `(A) -> A` and `(A) -> B`. Both shapes are easily composed into new functions by connecting them with the pipe forward |> operator when we have a value to start with, or by using the forward compose >>> operator when we want an altogether new function.
 
 In the next post, I'm going to examine composition when the type provides a context or wrapper around a value. You have already been working with some examples of these wrappers such as Array and Optional. Both provide a wrapper around some value or values. Such wrappers provide powerful mechanisms for composition using their `map`, `flatMap` and concatenation capabilities.
 */
