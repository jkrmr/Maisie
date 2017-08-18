//
//  DurationString.swift
//  Maisie
//
//  Created by Jake Romer on 8/17/17.
//  Copyright © 2017 Jake Romer. All rights reserved.
//

struct DurationString {
  static func from(interval seconds: Double) -> String {
    let mins = Int(seconds / 60)
    let secs = Int(seconds - Double(mins * 60))
    let minStr = String(format: "%02d", mins)
    let secStr = String(format: "%02d", secs)
    return "\(minStr):\(secStr)"
  }
}
