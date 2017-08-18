//
//  Timer.swift
//  Maisie
//
//  Created by Jake Romer on 8/18/17.
//  Copyright © 2017 Jake Romer. All rights reserved.
//

import Foundation

final class Timer {
  var startTime = 0.0

  var currentTime: Double {
    return Date().timeIntervalSince1970
  }

  var duration: Double {
    return currentTime - startTime
  }

  var durationString: String {
    return DurationString.from(interval: duration)
  }

  func startTiming() {
    startTime = currentTime
  }
}
