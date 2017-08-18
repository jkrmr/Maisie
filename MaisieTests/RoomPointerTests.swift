//
//  RoomPointerTests.swift
//  MaisieTests
//
//  Created by Jake Romer on 8/17/17.
//  Copyright © 2017 Jake Romer. All rights reserved.
//

import XCTest
@testable import Maisie

class RoomPointerTests: XCTestCase {
  func testFactoryMethodReturnsALockedRoomPointerForLockType() {
    let lockPtr = RoomPointer.build(direction: .north, type: "lock", targetId: "L")! as AnyObject
    assert(lockPtr.isMember(of: LockedRoomPointer.self))
    assert(!lockPtr.isMember(of: RoomPointer.self))
    assert(lockPtr.isKind(of: RoomPointer.self))
    assert(lockPtr.isKind(of: LockedRoomPointer.self))
  }

  func testFactoryMethodReturnsARoomPointerForRoomType() {
    let roomPtr = RoomPointer.build(direction: .north, type: "room", targetId: "R")! as AnyObject
    assert(!roomPtr.isMember(of: LockedRoomPointer.self))
    assert(roomPtr.isMember(of: RoomPointer.self))
    assert(!roomPtr.isKind(of: LockedRoomPointer.self))
    assert(roomPtr.isKind(of: RoomPointer.self))
  }

  func testFactoryMethodReturnsNilForUnrecognizedTypes() {
    let roomPtr = RoomPointer.build(direction: .north, type: "wall", targetId: "W")
    XCTAssertNil(roomPtr)
  }
}
