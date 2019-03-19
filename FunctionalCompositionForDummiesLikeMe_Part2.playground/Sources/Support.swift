/*
 ## Copyright Notice and MIT License from [https://opensource.org/licenses/MIT](https://opensource.org/licenses/MIT)
 
 Copyright 2019 Chuck Krutsinger
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */
import Foundation
import UIKit

/*
 The |> and >>> operator implementations below are Copyright 2018 Pointfree.co.
 */
precedencegroup ForwardApplication {
    associativity: left
    lowerThan: AdditionPrecedence
}

infix operator |>: ForwardApplication

public func |> <A, B>(x: A, f: (A) -> B) -> B {
    return f(x)
}

precedencegroup ForwardComposition {
    associativity: left
}

infix operator >>>: ForwardComposition

public func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
    return { g(f($0)) }
}

/*
 Example functions.
 */

public func verifyUrl(_ urlString: String?) -> Bool {
    //Check for nil
    if let urlString = urlString {
        // create NSURL instance
        if let url = URL(string: urlString) {
            // check if your application can open the NSURL instance
            return UIApplication.shared.canOpenURL(url)
        }
    }
    return false
}

public func increment(_ x: Int) -> Int {
    return x + 1
}

public func square(_ x: Int) -> Int {
    return x * x
}
