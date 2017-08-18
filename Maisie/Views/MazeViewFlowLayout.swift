//
//  MazeViewFlowLayout.swift
//  Maisie
//
//  Created by Jake Romer on 8/17/17.
//  Copyright © 2017 Jake Romer. All rights reserved.
//

import UIKit

class MazeViewFlowLayout: UICollectionViewFlowLayout {
  var columns: Int = 2

  var screenWidth: CGFloat {
    return UIScreen.main.bounds.width
  }

  var tileWidth: CGFloat {
    let cols = CGFloat(columns)
    let availableScreen = screenWidth - cols
    return availableScreen / (cols + 1)
  }

  override init() {
    super.init()
    minimumLineSpacing = 0
    minimumInteritemSpacing = 0
    itemSize = CGSize(width: tileWidth, height: tileWidth)
  }

  func update(columns cols: Int) {
    columns = cols
    itemSize = CGSize(width: tileWidth, height: tileWidth)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
