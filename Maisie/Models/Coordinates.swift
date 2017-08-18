//
//  RoomIdentifier.swift
//  Maisie
//
//  Created by Jake Romer on 8/17/17.
//  Copyright © 2017 Jake Romer. All rights reserved.
//

protocol MatrixIndexable {
  var row: Int { get }
  var col: Int { get }
}

struct Coordinates: MatrixIndexable {
  var row: Int = 0
  var col: Int = 0

  static func inDirection(_ dir: RoomPointer.Direction,
                          fromOrigin origin: Coordinates) -> Coordinates {
    let (row0, col0) = (origin.row, origin.col)

    switch dir {
    case .north:
      return Coordinates(row: row0 + 1, col: col0)
    case .south:
      return Coordinates(row: row0 - 1, col: col0)
    case .east:
      return Coordinates(row: row0, col: col0 + 1)
    case .west:
      return Coordinates(row: row0, col: col0 - 1)
    }
  }
}

// MARK: CustomStringConvertible
extension Coordinates: CustomStringConvertible {
  var description: String {
    return "(\(row), \(col))"
  }
}

// MARK: Hashable
extension Coordinates: Hashable {
  var hashValue: Int {
    return row.hashValue | col.hashValue
  }

  static func ==(_ lhs: Coordinates, _ rhs: Coordinates) -> Bool {
    return lhs.row == rhs.row && lhs.col == rhs.col
  }
}
