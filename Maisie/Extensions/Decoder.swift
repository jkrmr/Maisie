//
//  Decoder.swift
//  Maisie
//
//  Created by Jake Romer on 8/17/17.
//  Copyright © 2017 Jake Romer. All rights reserved.
//

import Gloss

extension Decoder {
  /// Decode a dict of the form:
  ///
  /// ```
  ///   "rooms": {
  ///     "east": { "room": 532beda81c777cf7f },
  ///     "west": { "lock": 432be38209234c979 }
  ///   }
  /// ```
  ///
  /// into a list of RoomPointer items as in:
  ///
  /// ```
  /// [
  ///   UnlockedRoom(direction: "north", type: "room", targetId: "R34533jd23", source: ...),
  ///   LockedRoom(direction: "west", type: "lock", targetId: "L3lkad3ja3", source: ...),
  /// ]
  /// ```
  ///
  /// - Parameters:
  ///   - json: The JSON to be deserialized
  ///
  /// - Returns: An optional list of RoomPointer objects
  ///
  static func decodeRoomList(json: JSON) -> [RoomPointer]? {
    guard let roomList: [String : Any] = "rooms" <~~ json
      else { return nil }

    var rooms = [RoomPointer]()

    for (dir, roomAttrs) in roomList {
      guard let room = roomAttrs as? [String: String],
            let type = room.keys.first,
            let targetId = room[type]
        else { return nil }

      if let direction = RoomPointer.Direction(rawValue: dir),
         let neighbor = RoomPointer.build(direction: direction,
                                          type: type,
                                          targetId: targetId) {
        rooms.append(neighbor)
      }
    }

    return rooms
  }
}
