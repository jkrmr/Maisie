//
//  MazeAPITests.swift
//  MaisieTests
//
//  Created by Jake Romer on 8/17/17.
//  Copyright © 2017 Jake Romer. All rights reserved.
//

import XCTest
@testable import Maisie

import TakeHomeTask
import PromiseKit

class MazeAPITests: XCTestCase {
  var mazeManager = MockMazeManager()

  override func setUp() {
    super.setUp()
    MazeAPI.shared.mazeManager = self.mazeManager
  }

  func testSubsequentCallsForTheSameRoomAreFetchedFromCache() {
    _ = MazeAPI.shared.fetchRoom(roomId: self.mazeManager.mockRoomID)
    _ = MazeAPI.shared.fetchRoom(roomId: self.mazeManager.mockRoomID)
    XCTAssertEqual(self.mazeManager.timesCalled("fetchRoom"), 1)
  }
}

/// A simple mock for the MazeManager class
class MockMazeManager: MazeManager {
  var invocationCounts = ["fetchStartRoom": 0, "fetchRoom": 0, "unlockRoom": 0]
  var mockRoomID = "R32bedb80c777ce7e"

  func timesCalled(_ methodName: String) -> Int {
    return invocationCounts[methodName] ?? 0
  }

  private func increment(_ methodName: String) {
    invocationCounts[methodName] = timesCalled(methodName) + 1
  }

  override func fetchStartRoom(callback: @escaping (Data?, Error?) -> Void) {
    increment("fetchStartRoom")
    if let data = try? JSONSerialization.data(withJSONObject: self.mockRoomID,
                                              options: []) {
      callback(data, nil)
    }
  }

  override func fetchRoom(withIdentifier identifier: String,
                          callback: @escaping (Data?, Error?) -> Void) {
    increment("fetchRoom")

    let response = [
      "id": self.mockRoomID,
      "rooms": [ "east": [ "room": "532beda81c777cf7f" ],
                 "west": [ "lock": "432be38209234c979" ]],
      "tileUrl": "https://example.com/images/tileset-1010.jpg",
      "type": "EMPTY"
    ] as [String : Any]

    if let data = try? JSONSerialization.data(withJSONObject: response,
                                              options: []) {
      callback(data, nil)
    }
  }

  override func unlockRoom(withLock: String) -> String {
    increment("unlockRoom")
    return "lock"
  }
}
