//
//  NSCacheCacheTests.swift
//  MaisieTests
//
//  Created by Jake Romer on 8/17/17.
//  Copyright © 2017 Jake Romer. All rights reserved.
//

import XCTest
@testable import Maisie

class NSCacheCacheTests: XCTestCase {
  func testCacheIsMatrixStyleIndexable() {
    let cache = NSCacheCache<Coordinates, NSNumber>()
    let coords = Coordinates(row: 1, col: 2)
    cache.setObject(.init(integerLiteral: 554), forKey: coords)

    let value = cache.object(forKey: coords)

    XCTAssertEqual(value, 554)
  }

  func testReturnsNilWhenRowIndexNotFound() {
    let cache = NSCacheCache<Coordinates, NSNumber>()
    let coords = Coordinates(row: 1, col: 2)
    let notFoundCoords = Coordinates(row: 4, col: 2)
    cache.setObject(.init(integerLiteral: 554), forKey: coords)

    let value = cache.object(forKey: notFoundCoords)

    XCTAssertNil(value)
  }

  func testReturnsNilWhenColIndexNotFound() {
    let cache = NSCacheCache<Coordinates, NSNumber>()
    let coords = Coordinates(row: 1, col: 2)
    let notFoundCoords = Coordinates(row: 1, col: 5)
    cache.setObject(.init(integerLiteral: 554), forKey: coords)

    let value = cache.object(forKey: notFoundCoords)

    XCTAssertNil(value)
  }

  func testDoesNotOverwriteDuplicateRowEntries() {
    let cache = NSCacheCache<Coordinates, NSNumber>()
    let coords1 = Coordinates(row: 1, col: 2)
    let coords2 = Coordinates(row: 1, col: 3)
    cache.setObject(.init(integerLiteral: 554), forKey: coords1)
    cache.setObject(.init(integerLiteral: 555), forKey: coords2)

    let value1 = cache.object(forKey: coords1)
    let value2 = cache.object(forKey: coords2)

    XCTAssertEqual(value1, 554)
    XCTAssertEqual(value2, 555)
  }

  func testOverwritesDuplicateColumnEntries() {
    let cache = NSCacheCache<Coordinates, NSNumber>()
    let coords = Coordinates(row: 1, col: 2)

    cache.setObject(.init(integerLiteral: 554), forKey: coords)
    cache.setObject(.init(integerLiteral: 555), forKey: coords)
    let value = cache.object(forKey: coords)

    XCTAssertEqual(value, 555)
  }
}
