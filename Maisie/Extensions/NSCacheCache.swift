//
//  NSCacheCache.swift
//  Maisie
//
//  Created by Jake Romer on 8/17/17.
//  Copyright © 2017 Jake Romer. All rights reserved.
//

import Foundation

/// An NSCache indexable by Coordinates.
/// Provides constant-time lookup by row and column number.
class NSCacheCache<I: MatrixIndexable, T: AnyObject> {
  var cache = NSCache<NSNumber, NSCache<NSNumber, T>>()

  func object(forKey key: I) -> T? {
    guard let subcache = cache.object(forKey: .init(value: key.row))
      else { return nil }

    return subcache.object(forKey: .init(value: key.col))
  }

  func setObject(_ object: T, forKey key: I) {
    let subcache = cache.object(forKey: .init(value: key.row)) ?? NSCache<NSNumber, T>()
    subcache.setObject(object, forKey: .init(value: key.col))
    cache.setObject(subcache, forKey: .init(value: key.row))
  }

  func removeAllObjects() {
    cache.removeAllObjects()
  }
}
