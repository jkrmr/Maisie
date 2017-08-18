//
//  MazeCell.swift
//  Maisie
//
//  Created by Jake Romer on 8/17/17.
//  Copyright © 2017 Jake Romer. All rights reserved.
//

import UIKit
import Kingfisher

class MazeCell: UICollectionViewCell {
  @IBOutlet weak var tileImage: UIImageView!

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  func configure(room: Room) {
    let size = CGSize(width: 10, height: 10)
    let processor = ResizingImageProcessor(referenceSize: size)
    tileImage.kf.setImage(with: room.tileUrl, options: [.processor(processor)])
  }
}
