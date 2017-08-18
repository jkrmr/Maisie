//
//  RoomIdentifier.swift
//  Maisie
//
//  Created by Jake Romer on 8/17/17.
//  Copyright © 2017 Jake Romer. All rights reserved.
//

struct RoomIdentifier {
  static func abbreviated(id: String) -> String {
    if id.characters.count <= 13 { return id }

    let five = id.index(id.startIndex, offsetBy: 5)
    let negFive = id.index(id.endIndex, offsetBy: -5)
    return "\(id.substring(to: five))...\(id.substring(from: negFive))"
  }
}
