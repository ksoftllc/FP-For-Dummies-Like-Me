/*:
 # Functional Composition in Swift for Dummies Like Me - Part 1
 
 This will be the first in a series of posts hoping to help Swift programmers who are less experienced in functional programming be able to apply functional techniques to write better software. I will do so with a minimum of jargon, especially jargon from category theory which can be very hard to penetrate.
 
 ## Background - Patterns
 
 In 1994, *Design Patterns: Elements of Reusable Software* was published by Gamma, et. al. (the "gang of four") and it catalogued patterns for object-oriented software design and became very influential for developers. It helped create a vocabulary for designing OO software (e.g. factory, facade, composite, etc.) Many were already using these patterns, but the book helped propagate their use and best practices. More importantly, the book provided a straightforward vocabulary (e.g. Factory Pattern, etc.) for these patterns so that programmers could better communicate. Their book defined and articulated patterns helped me grow as an OO programmer.
 
 So when I dove into functional programming, I wanted to understand the patterns
 for functional programming that would open my eyes to the patterns that people
 were using to make their software more composable and more reliable. Searches
 for functional design patterns led me to a presentation by Scott Wlaschin called
 [Functional Design Patterns](https://www.youtube.com/watch?v=srQt1NAHYC0)
 that directly addressed the topic of patterns,
 [slides found here](https://www.slideshare.net/ScottWlaschin/fp-patterns-buildstufflt).
 There is a ton of great material in there, but when comparing OO design patterns
 to FP, he provided this slide:
 ![From Scott Wlaschin's Functional Programming Patterns slides](OO_Patterns_v_FP_Patterns.png)
 
 Needless to say, this comparison did not answer my questions. There is great advice in the presentation, but it didn't catalog and name the kinds of patterns I was hoping to find that would guide me to designing better and more composable software. In the time since that search, I've studied from numerous additional sources, including my favorites at https://www.objc.io and https://www.objc.io.
 
From my studies, I have identified some patterns that I'd like to put forth as "functional composition patterns". As Scott Wlaschin says, "Functions. Yes, functions. Oh my, functions again." It is all about the functions. But as I studied, I began to notice patterns to those functions and I began to see how to design functions that would make composition possible and powerful. This seems to be what the FP experts are already doing, but they weren't necessarily calling them out in the way I'm going to put forth here by studying their shapes. This will be the first of a series of posts that will put forth a set of patterns based on function "shapes" and how you can compose functions with those shapes to form useful new functions in your software projects.
 
 ![](puzzlePieces.png)
 ## Functions Have a Shape
 
One key to understanding how to compose any functions is understanding their shape. Like the puzzle pieces drawn above, a function expects a certain shape to plug into it and must have a certain shape to plug into an adjoining piece in order to form a more complete whole.
 
 To understand "shape" in terms of functions, you have to start with the concept of type. For starters, type is not the same as class. Having spent so many years programming in Java and Objective C, that was my incorrect perspective. Type is anything that can be placed in a variable or constant. This includes:
 
 * Built-in types like Int, Double, Bool, or String
 * class
 * struct
 * func
 * enum
 * protocol
 * Optional
 * and maybe more
 
Functions have a type. The type of a function defines the inputs and the outputs in terms of their specific types. An easy way to gain insight into the type of a function is to capture it in a variable. In fact, you can see this in code using the type(of:T) function. Take a look at the type of a function in this example:
 
 */
import Foundation

print(type(of: String.uppercased))

/*:
 This illustrates the fact that in Swift, member functions are implemented as static functions that are applied to self. The example above shows that the String.uppercased function takes a string as an argument and returns a function that takes no arguments then returns another string, which will be the uppercased version of the first string. When invoked on a String instance, the first string argument will be self.
 */

let upper = String.uppercased

let shoutedHello = "Hello".uppercased

print(shoutedHello())
/*:
 Here you can see that when uppercased is used with the String literal "Hello", it returns a function that takes no arguments and returns a String. "Hello" has been already applied to the String.uppercased function. And you can see that when I invoke shoutedHello with shoutedHello(), I get the uppercased String as a result.
 
 For the discussions of patterns, I'm going to focus on generic shapes. So a function with a type of (String) -> String would be of the shape (A) -> A because the input is the same type as the output. In contrast, a function that turns an Int into a String would have a shape of (A) -> B because the input and output types are different.
 
 ![From Scott Wlaschin's Functional Programming Patterns slides](apple_to_apple.png)
 ## Shape 1 - Type Variation (a.k.a. Endofunctor) - (A) -> A
 
 One of the most frequent shapes for functions is a function whose single input and single output are of the same type. These are officially classified as endofunctors. However, I want to focus on what it does rather than use technically correct terminology. So I'm going to refer to it simply as a type specific function because it takes a type and returns the same type. Let's dive into some simple examples.
 
 Here are two simple functions that take a String and return a string based on that String. Since the output of either is a String and the input of either is a String, then they can be composed one after the other as well as used independently.
 
 */

let shout = { (s: String) -> String in s.uppercased() }

let exclaim = { s -> String in s + "!" }

print(shout("Hello"))

print(exclaim("Wow"))

let shoutExclamation = { s in
    exclaim(shout(s))
}

print(shoutExclamation("Hi there"))

/*:
 Functions that have the "type specific" shape, can be composed one with the other easily to form new functions. This is the first and most basic type of function composition.
 
 ## Introducing The Pipe Forward Operator: |>
 As you have seen above, exclaim(shout(s)) is the native  way to compose two functions in Swift. It can be pronounced, "exclaim after shout" or "shout then exclaim". Visually, the exclaim function appears before the shout function, but the shout function executes first because composed functions execute inside out. But our brain wants to say "shout, then add the exclamation". So let's introduce a common way of representing composition in FP that is a bit more readable by introducing an infix operator commonly called the "pipe forward" operator. If you are familiar with the | (pronounced "pipe") operator in Unix/Linux and other OS's, then you'll easily understand this operator. It takes the value to the left and provides it as input to the function on the right.
 */

precedencegroup ForwardApplication {
    associativity: left
}

infix operator |>: ForwardApplication

public func |> <A, B>(x: A, f: (A) -> B) -> B {
    return f(x)
}

"holy crap" |> shout |> exclaim

/*:
 There is precedent for this operator in other functional languages, so it is useful and practical to use the same operator here.
 
 For me, the idea of creating infix operators was intimidating. I won't go into any detail on the syntax here because there are tutorials already out there. Using this operator with our "type specific" functions is as easy as using a + sign for integer math. Just pipe your starting value into the first function, followed by the next function, and so on, in the order you want them to be performed.
 */

"holy crap" |> shout |> exclaim

"that's too easy"
    |> shout
    |> exclaim
    |> exclaim
    |> exclaim

/*:
 Compare that latter operation with this version without the pipe forward infix operator:
 */
exclaim(exclaim(exclaim(shout("that's hard to read"))))
/*:
 Here is a more practical code example from pointfree.co's site:
 ![](URLRequest_configured.png)
 
 This is a very practical example of using pipe forward to compose a URLRequest configured with simple setter functions for different portions of the request. It is easily read and understood.
 
 Although infix operators are controversial to some and many teams are not ready to adopt them, I am going to use them in the tutorials because they make the examples more readable. For the same reason, I am adopting many of them in my code bases. If your team is not ready and you still want the advantages of readable compositions without introducing infix operators, Pointfree also has an open source library called [swift-overture](https://github.com/pointfreeco/swift-overture) that provides compositions without using infix operators. Check it out.
 
 ![From Scott Wlaschin's Functional Programming Patterns slides](apple_to_banana.png)
 ## Shape 2 - Transformation - (A) -> B
 In my next post, I will discuss the next most common shape, the transformation. Functions whose input is one type and whose output is a different type. I will discuss how these can compose and also discuss how such composition is commonly used in RxSwift and other functional reactive programming (FRP) libraries to powerfully compose functionality. I will also relate this shape to the map function and how that might help us compose.
 
 You can follow me on medium at [https://medium.com/@chuck.krutsinger](https://medium.com/@chuck.krutsinger)
 */
