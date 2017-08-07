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

    MazeManager().fetchStartRoom { (data, error) in
      if let error = error { return print(error) }
      guard let data = data else { return print("no data") }

      if let json = try? JSONSerialization
        .jsonObject(with: data, options: .mutableContainers)
        as? [String: String] {

        print(json!["id"]!)
      }
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

}
