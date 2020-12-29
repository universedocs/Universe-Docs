//  MIT License
//
//  Copyright (c) 2017
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

//
//  Parser.swift
//  SwiftPath
//
//  Created by Steven Grosmark on 8/25/17.
//  Copyright © 2017 Steven Grosmark. All rights reserved.
//

import Foundation

struct Parser<T> {
    let parse: (PathScanner) -> (T, PathScanner)?
}

extension Parser {
    func run(_ string: String) -> (T, String)? {
        guard let (result, remainder) = parse(PathScanner(string: string)) else { return nil }
        return (result, remainder.contextString)
    }
    
    func followed(by rparser:Parser) -> Parser<[T]> {
        return Parser<[T]>(parse: { scanner in
            guard let (lvalue, lscanner) = self.parse(scanner) else { return nil }
            guard let (rvalue, rscanner) = rparser.parse(lscanner) else { return nil }
            return ([lvalue, rvalue], rscanner)
        })
    }
    func followed(by rparsers:[Parser]) -> Parser<[T]> {
        return Parser<[T]>(parse: { scanner in
            guard let (lvalue, lscanner) = self.parse(scanner) else { return nil }
            var scanner = lscanner
            var collected = [lvalue]
            for rparser in rparsers {
                guard let (rvalue, rscanner) = rparser.parse(scanner) else { return nil }
                collected.append(rvalue)
                scanner = rscanner
            }
            return (collected, scanner)
        })
    }
    
    func or(_ rparser: Parser) -> Parser<T> {
        return Parser<T>(parse: { scanner in
            return self.parse(scanner) ?? rparser.parse(scanner)
        })
    }
    
    func repeated() -> Parser<[T]> {
        return Parser<[T]>(parse: { scanner in
            guard let (lvalue, lscanner) = self.parse(scanner) else { return nil }
            var scanner = lscanner
            var collected = [lvalue]
            while let (rvalue, rscanner) = self.parse(scanner) {
                collected.append(rvalue)
                scanner = rscanner
            }
            return (collected, scanner)
        })
    }
    
    func repeated<A>(delimiter: Parser<A>) -> Parser<[T]> {
        return Parser<[T]>(parse: { scanner in
            guard let (lvalue, lscanner) = self.parse(scanner) else { return nil }
            var scanner = lscanner
            var collected = [lvalue]
            while let (_, rscanner) = delimiter.parse(scanner) {
                guard let (rvalue, rscanner) = self.parse(rscanner) else { return nil }
                collected.append(rvalue)
                scanner = rscanner
            }
            return (collected, scanner)
        })
    }
    
    func zeroOrMore() -> Parser<[T]> {
        return Parser<[T]>(parse: { scanner in
            guard let (lvalue, lscanner) = self.parse(scanner) else { return ([], scanner) }
            var scanner = lscanner
            var collected = [lvalue]
            while let (rvalue, rscanner) = self.parse(scanner) {
                collected.append(rvalue)
                scanner = rscanner
            }
            return (collected, scanner)
        })
    }
    
    func map<TResult>(_ transform: @escaping (T) -> TResult) -> Parser<TResult> {
        return Parser<TResult> { scanner in
            guard let (result, remainder) = self.parse(scanner) else { return nil }
            return (transform(result), remainder)
        }
    }
    
    
}


func literal(string: String) -> Parser<String> {
    return Parser<String>(parse: { scanner in
        guard scanner.mustBe(string: string) else {
            return nil
        }
        return (string, scanner)
    })
}


func pattern(string: String) -> Parser<String> {
    return Parser<String>(parse: { scanner in
        guard let match = scanner.mustMatch(pattern: string) else {
            return nil
        }
        return (match, scanner)
    })
}
