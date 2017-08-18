//
//  MazeAPI.swift
//  Maisie
//
//  Created by Jake Romer on 8/17/17.
//  Copyright © 2017 Jake Romer. All rights reserved.
//

import TakeHomeTask
import PromiseKit
import Gloss

final class MazeAPI {
  static let shared = MazeAPI()
  private init() {}

  /// The MazeManager API library. Injectable via the `mazeManager` property.
  var mazeManager = MazeManager()

  func startRoom() -> Promise<String> {
    MazeCache.shared.clear()

    return Promise { (fulfill, reject) in
      self.mazeManager.fetchStartRoom { (data, error) in
        if let error = error {
          return reject(error)
        }

        guard let data = data else {
          return reject(MazeAPIError.noData)
        }

        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
              let jsonDict = json else {
          return reject(MazeAPIError.failedDecodingJSON)
        }

        guard let roomId = jsonDict["id"] else {
          return reject(MazeAPIError.missingJSONKey(key: "id", json: jsonDict))
        }

        fulfill(roomId)
      }
    }
  }

  func fetchRoom(roomId: String, coordinates: Coordinates? = nil) -> Promise<Room> {
    return Promise { (fulfill, reject) in
      // If room has already been encountered, return its cached copy 
      // without making an API call
      if let room = MazeCache.shared.get(roomWithId: roomId) {
        fulfill(room)
        return
      }

      // Query the API for the given room ID's associated room attributes
      self.mazeManager.fetchRoom(withIdentifier: roomId) { (data, error) in
        if let error = error {
          return reject(error)
        }

        guard let data = data else {
          return reject(MazeAPIError.noData)
        }

        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let jsonDict = json else {
          return reject(MazeAPIError.failedDecodingJSON)
        }

        guard let room = Room(json: jsonDict) else {
          return reject(MazeAPIError.failedDeserializingJSON(json: jsonDict))
        }

        // If coordinates passed, set them as a property on the room object
        if let coordinates = coordinates {
          room.coordinates = coordinates
        }

        // Add newly encountered room to the maze cache
        MazeCache.shared.add(room: room)

        fulfill(room)
      }
    }
  }

  func get(roomWithCoordinates coords: Coordinates) -> Room? {
    return MazeCache.shared.get(roomWithCoordinates: coords)
  }

  func unlockRoom(lockId: String) -> Promise<String> {
    return Promise { (fulfill, _) in
      let roomId = self.mazeManager.unlockRoom(withLock: lockId)
      fulfill(roomId)
    }
  }
}

// MARK: MazeAPI Errors
extension MazeAPI {
  enum MazeAPIError: Error {
    case noData
    case failedDecodingJSON
    case failedDeserializingJSON(json: JSON)
    case missingJSONKey(key: String, json: JSON)
  }
}
