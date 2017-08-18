//
//  CoordinatesTests.swift
//  MaisieTests
//
//  Created by Jake Romer on 8/17/17.
//  Copyright © 2017 Jake Romer. All rights reserved.
//

import XCTest
@testable import Maisie

class CoordinatesTests: XCTestCase {
  func testInNorthDirectionIncrementsRowForSomeReason() {
    let origin = Coordinates(row: 0, col: 0)
    let relCoords = Coordinates.inDirection(.north, fromOrigin: origin)
    XCTAssertEqual(relCoords.row, 1)
    XCTAssertEqual(relCoords.col, 0)
  }

  func testInSouthDirectionDecrementsRowForSomeReason() {
    let origin = Coordinates(row: 0, col: 0)
    let relCoords = Coordinates.inDirection(.south, fromOrigin: origin)
    XCTAssertEqual(relCoords.row, -1)
    XCTAssertEqual(relCoords.col, 0)
  }

  func testInEastDirectionIncrementsColumnAsExpected() {
    let origin = Coordinates(row: 0, col: 0)
    let relCoords = Coordinates.inDirection(.east, fromOrigin: origin)
    XCTAssertEqual(relCoords.row, 0)
    XCTAssertEqual(relCoords.col, 1)
  }

  func testInWestDirectionDecrementsColumnAsExpected() {
    let origin = Coordinates(row: 0, col: 0)
    let relCoords = Coordinates.inDirection(.west, fromOrigin: origin)
    XCTAssertEqual(relCoords.row, 0)
    XCTAssertEqual(relCoords.col, -1)
  }
}
