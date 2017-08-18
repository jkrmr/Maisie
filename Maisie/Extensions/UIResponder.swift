//
//  UIResponder.swift
//  Maisie
//
//  Created by Jake Romer on 8/17/17.
//  Copyright © 2017 Jake Romer. All rights reserved.
//

import UIKit

extension UIResponder {
  /// Return the string representation of the given type name.
  /// For types that inherit from UIResponder.
  /// Used to consistify reuse identifiers.
  ///
  /// - Returns: String
  ///
  static var reuseID: String {
    return String(describing: self)
  }
}
