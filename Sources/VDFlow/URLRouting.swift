import Foundation
import URLRouting
import CasePaths
import Parsing
import SwiftUI

extension StepBinding: Conversion {
    
    public func apply(_ input: Value) throws -> Root {
        var result = self.rootBinding.wrappedValue.wrappedValue
        result[keyPath: keyPath].wrappedValue = input
        return result
    }
    
    public func unapply(_ output: Root) throws -> Value {
        rootBinding.wrappedValue.wrappedValue[keyPath: keyPath].wrappedValue
    }
}

public struct EmptyStepBinding: Conversion {
    
    @inlinable
    public init() {
    }
    
    public func apply(_ input: Void) throws -> EmptyStep {
        EmptyStep()
    }
    
    public func unapply(_ output: EmptyStep) throws -> Void {
        ()
    }
}

extension Route {
    
    @inlinable
    public init<C: Conversion, P: Parser>(
        _ conversion: C,
        @ParserBuilder with parsers: () -> P
    )
    where
    P.Input == URLRequestData,
    Parsers == Parsing.Parsers.MapConversion<P, Parsing.Conversions.Map<EmptyStepBinding, C>>
    {
    	self.init(
        EmptyStepBinding().map(conversion),
        with: parsers
    	)
    }

    @inlinable
    public init<C: Conversion>(
        _ conversion: C
    ) where Parsers == Parsing.Parsers.MapConversion<
        Always<URLRequestData, Void>,
        Parsing.Conversions.Map<EmptyStepBinding, C>
    > {
        self.init(conversion) {
            Always<URLRequestData, Void>(())
        }
    }
}

struct SomeView: View {
    
    @StateStep var appFlow = AppFlow()
    let url: URL
    
    var body: some View {
        EmptyView()
    }
    
    func route() throws {
        appFlow = try OneOf {
            Route(_appFlow.$books) {
                Path { "books" }
            }
            
            Route(_appFlow.$book) {
                Query {
                    Field("count", default: 10) { Digits() }
                }
            }
            
            Route(_appFlow.$searchBooks) {
                Path { "books" }
                URLRouting.Body(.json(SearchBooks.self))
            }
        }
        .match(url: url)
    }
}

public extension Route {
    
    func tt() {
//    	let appRouter = OneOf {
//
//            // GET /books
//        Route(/AppRoute.book) {
//            Path { "book" }
//        }
//
//        // GET /books/:id
//        Route(/AppRoute.books) {
//            Path { "books"; Digits() }
//        }
//
//        // GET /books/search?query=:query&count=:count
//        Route(/AppRoute.searchBooks) {
//            Path { "books"; "search" }
//            Query {
//                Field("query")
//                Field("count", default: 10) { Digits() }
//            }
//        }
//    	}
    }
}

enum AppRoute {
    
    case books
    case book(id: Int)
    case searchBooks(query: String, count: Int = 10)
}

struct AppFlow {
    
    @Step() var books
    @Step var book = 0
    @Step var searchBooks = SearchBooks()
}

struct SearchBooks: Codable {
    
    var query = ""
    var count = 10
}
