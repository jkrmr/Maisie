//
//  MazeCache.swift
//  Maisie
//
//  Created by Jake Romer on 8/17/17.
//  Copyright © 2017 Jake Romer. All rights reserved.
//

import Foundation

final class MazeCache {
  static let shared = MazeCache()
  private init() {}

  var roomsById = NSCache<NSString, Room>()
  var roomsByCoordinate = NSCacheCache<Coordinates, Room>()

  func add(room: Room) {
    roomsById.setObject(room, forKey: NSString(string: room.id))
    roomsByCoordinate.setObject(room, forKey: room.coordinates)
  }

  func get(roomWithId roomId: String) -> Room? {
    return roomsById.object(forKey: NSString(string: roomId))
  }

  func get(roomWithCoordinates coords: Coordinates) -> Room? {
    return roomsByCoordinate.object(forKey: coords)
  }

  func clear() {
    roomsById.removeAllObjects()
    roomsByCoordinate.removeAllObjects()
  }

  func contains(roomWithId roomId: String) -> Bool {
    return get(roomWithId: roomId) != nil
  }
}
