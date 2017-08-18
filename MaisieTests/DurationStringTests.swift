//
//  DurationStringTests.swift
//  MaisieTests
//
//  Created by Jake Romer on 8/17/17.
//  Copyright © 2017 Jake Romer. All rights reserved.
//

import XCTest
@testable import Maisie

class DurationStringTests: XCTestCase {
  func testReturnsAFormattedDurationStringWithZeroPaddedMinutes() {
    let seconds = 130.0
    let durationString = DurationString.from(interval: seconds)
    XCTAssertEqual(durationString, "02:10")
  }

  func testReturnsAFormattedDurationStringWithZeroPaddedSeconds() {
    let seconds = 8.0
    let durationString = DurationString.from(interval: seconds)
    XCTAssertEqual(durationString, "00:08")
  }

  func testDoesNotBotherWithAnHoursPosition() {
    let seconds = (60.0 * 63.0) + 45
    let durationString = DurationString.from(interval: seconds)
    XCTAssertEqual(durationString, "63:45")
  }
}
