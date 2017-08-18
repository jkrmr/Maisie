//
//  RoomPointer.swift
//  Maisie
//
//  Created by Jake Romer on 8/17/17.
//  Copyright © 2017 Jake Romer. All rights reserved.
//

import Foundation
import PromiseKit

class RoomPointer {
  let targetId: String
  let direction: Direction

  var abbreviatedId: String {
    return RoomIdentifier.abbreviated(id: targetId)
  }

  /// Based on the provided `type`, initialize and return a RoomPointer
  /// or LockedRoomPointer. Recognized types are "room" and "lock".
  ///
  /// - Parameters:
  ///   - direction: The relative cardinal direction the RoomPointer points in
  ///   - type: Whether the pointer points to a "room" or a "lock"
  ///   - targetId: The id of the room or lock
  ///
  static func build(direction: Direction, type: String, targetId: String)
      -> RoomPointer? {
    switch type {
    case "room":
      return RoomPointer(direction: direction, targetId: targetId)
    case "lock":
      return LockedRoomPointer(direction: direction, targetId: targetId)
    default:
      return nil
    }
  }

  init(direction: Direction, targetId: String) {
    self.targetId = targetId
    self.direction = direction
  }

  /// Return a Promise to the Room pointed to by this RoomPointer.
  func getRoom(from origin: Room) -> Promise<Room> {
    return fetchRoom(roomId: targetId, originCoordinates: origin.coordinates)
  }

  fileprivate func fetchRoom(roomId: String, originCoordinates coords: Coordinates)
    -> Promise<Room> {
    let target = Coordinates.inDirection(self.direction, fromOrigin: coords)
    return MazeAPI.shared.fetchRoom(roomId: roomId, coordinates: target)
  }
}

class LockedRoomPointer: RoomPointer {
  /// A specialization of `getRoom` that first unlocks the given room to get
  /// the room ID, then returns a promise that resolves to that Room.
  ///
  /// - Parameters:
  ///   - origin: The origin Room from which to understand the pointer's
  ///             direction.
  ///
  override func getRoom(from origin: Room) -> Promise<Room> {
    return firstly {
      return MazeAPI.shared.unlockRoom(lockId: targetId)
    }.then { roomId in
      return self.fetchRoom(roomId: roomId, originCoordinates: origin.coordinates)
    }.catch { error in
      print("Error: \(error)")
    }
  }
}

// MARK: RoomPointer.Direction Enum
extension RoomPointer {
  enum Direction: String {
    case north = "north"
    case south = "south"
    case east = "east"
    case west = "west"
  }
}

// MARK: CustomStringConvertible
extension RoomPointer: CustomStringConvertible {
  var description: String {
    let typename = String(describing: type(of: self))
    return "<\(direction): \(typename) \(abbreviatedId)>"
  }
}
