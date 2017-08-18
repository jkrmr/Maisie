//
//  RoomIdentifierTests.swift
//  MaisieTests
//
//  Created by Jake Romer on 8/17/17.
//  Copyright © 2017 Jake Romer. All rights reserved.
//

import XCTest
@testable import Maisie

class RoomIdentifierTests: XCTestCase {
  func testDisplaysOnlyStartAndEndOfGivenString() {
    let longId = "ID123456789ABCDEFGH"
    let shortId = RoomIdentifier.abbreviated(id: longId)
    XCTAssertEqual(shortId, "ID123...DEFGH")
  }

  func testIgnoresStringsTooShortToProfitablyAbbreviate() {
    let longId = "1234567890123"
    let shortId = RoomIdentifier.abbreviated(id: longId)
    XCTAssertEqual(shortId, longId)
  }

  func testDoesNotIgnoreStringsThatCanBeShortened() {
    let longId = "12345678901234"
    let shortId = RoomIdentifier.abbreviated(id: longId)
    XCTAssertEqual(shortId, "12345...01234")
  }
}
