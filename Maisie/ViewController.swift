//
//  ViewController.swift
//  Maisie
//
//  Created by Jake Romer on 8/1/17.
//  Copyright © 2017 Jake Romer. All rights reserved.
//

import UIKit
import TakeHomeTask

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    MazeManager()
      .fetchRoom(withIdentifier: "R4b7f8b8bd464e959") { (data, error) in
        print(data!)
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

}
