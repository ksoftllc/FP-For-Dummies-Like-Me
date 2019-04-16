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
 The |> and >>> operators and Result enum implementations below are
 Copyright 2018 Pointfree.co licensed under MIT License above.
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

enum Result<A, E> {
    case success(A)
    case failure(E)
    
    func map<B>(_ f: @escaping (A) -> B) -> Result<B, E> {
        switch self {
        case let .success(a):
            return .success(f(a))
        case let .failure(e):
            return .failure(e)
        }
    }
    
    public func flatMap<B>(_ transform: (A) -> Result<B, E>) -> Result<B, E> {
        switch self {
        case let .success(value):
            return transform(value)
        case let .failure(error):
            return .failure(error)
        }
    }
}
