//
//  Room.swift
//  Maisie
//
//  Created by Jake Romer on 8/17/17.
//  Copyright © 2017 Jake Romer. All rights reserved.
//

import Gloss
import PromiseKit

final class Room: Decodable {
  let id: String
  let tileUrl: URL
  let type: RoomType
  var coordinates = Coordinates()

  /// Pointers to adjacent rooms, as found in the JSON payload returned from
  /// the server.
  let neighbors: [RoomPointer]

  /// Pointers to adjacent rooms that have not already been encountered.
  /// Whether or not a room has been encountered is determined by checking 
  /// the maze cache. This check is needed in order to stop the graph traversal
  /// that builds the maze.
  var newNeighbors: [RoomPointer] {
    return neighbors.filter { roomPointer in
      !MazeCache.shared.contains(roomWithId: roomPointer.targetId)
    }
  }

  /// Promises returning adjacent Rooms that have not been encountered before.
  var neighboringRooms: [Promise<Room>] {
    return newNeighbors.map { roomPointer in
      roomPointer.getRoom(from: self)
    }
  }

  enum RoomType: String {
    case empty = "EMPTY"
    case door = "DOOR"
    case exit = "EXIT"
  }

  /// Initialize a Room model from the given JSON payload.
  /// Return nil if deserialization fails.
  ///
  /// Sample JSON to be deserialized:
  ///
  /// ```
  /// [
  ///   "id": R32bedb80c777ce7e,
  ///   "rooms": {
  ///     "east": { "room": 532beda81c777cf7f },
  ///     "west": { "lock": 432be38209234c979 }
  ///   },
  ///   "tileUrl": "https://example.com/images/tileset-1010.jpg",
  ///   "type": "EMPTY"
  /// ]
  /// ```
  ///
  /// - Parameter json: the JSON-parsed dict to be deserialized
  init?(json: JSON) {
    guard let id: String = "id" <~~ json,
          let tileUrl = URL(string: ("tileUrl" <~~ json) ?? "") ,
          let type: RoomType = "type" <~~ json,
          let neighbors = Decoder.decodeRoomList(json: json)
      else { return nil }

    self.id = id
    self.tileUrl = tileUrl
    self.type = type
    self.neighbors = neighbors
  }

  init(id: String, tileUrl: URL, type: RoomType, neighbors: [RoomPointer]) {
    self.id = id
    self.tileUrl = tileUrl
    self.type = type
    self.neighbors = neighbors
  }
}

// MARK: CustomStringConvertible
extension Room: CustomStringConvertible {
  var description: String {
    let shortId = RoomIdentifier.abbreviated(id: id)
    return "Room: \(coordinates), \(shortId)"
  }

  var longDescription: String {
    let adjRooms = neighbors.map({ $0.description }).joined(separator: ", ")
    let shortId = RoomIdentifier.abbreviated(id: id)
    return "Room: \(coordinates), \(shortId) -> [\(adjRooms)]"
  }
}

// MARK: Hashable
extension Room: Hashable {
  var hashValue: Int {
    return id.hashValue
  }

  static func ==(_ lhs: Room, _ rhs: Room) -> Bool {
    return lhs.id == rhs.id
  }
}
