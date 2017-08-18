//
//  MazeVC.swift
//  Maisie
//
//  Created by Jake Romer on 8/17/17.
//  Copyright © 2017 Jake Romer. All rights reserved.
//

import UIKit

class MazeVC: UIViewController {
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var generateButton: UIButton!

  // keep track of how long the maze generation takes to complete
  let mazeTimer = Timer()

  // update the layout's number of columns as the maze is built
  var mazeViewFlowLayout = MazeViewFlowLayout()

  let maze = Maze.shared
  var rooms = [[Room?]]() {
    didSet { collectionView.reloadData() }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    maze.delegate = self
    loadingIndicator.isHidden = true

    collectionView.dataSource = self
    automaticallyAdjustsScrollViewInsets = false
    collectionView.collectionViewLayout = mazeViewFlowLayout
    collectionView.delegate = self
    collectionView.register(UINib(nibName: MazeCell.reuseID, bundle: nil),
                            forCellWithReuseIdentifier: MazeCell.reuseID)
    collectionView.register(UINib(nibName: EmptyMazeCell.reuseID, bundle: nil),
                            forCellWithReuseIdentifier: EmptyMazeCell.reuseID)
  }

  @IBAction func generateButtonWasPressed(_ sender: UIButton) {
    self.maze.generate()
  }
}

// MARK: MazeDelegate
extension MazeVC: MazeDelegate {
  func didBeginLoadingMaze() {
    mazeTimer.startTiming()
    loadingIndicator.startAnimating()
    generateButton.isEnabled = false
    loadingIndicator.isHidden = false
    timeLabel.isHidden = false
  }

  func didBeginTraversal() {
    timeLabel.text = mazeTimer.durationString
  }

  func didUpdateMaze(grid: [[Room?]]) {
    rooms = grid
    guard let columns = grid.first?.count else { return }
    // update flow layout with the number of columns now present
    mazeViewFlowLayout.update(columns: columns)
    collectionView.collectionViewLayout = mazeViewFlowLayout
  }

  func didEndTraversal() {
    timeLabel.text = mazeTimer.durationString
  }

  func didEndLoadingMaze() {
    loadingIndicator.stopAnimating()
    loadingIndicator.isHidden = true
    generateButton.isEnabled = true
  }
}

extension MazeVC: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
  }
}

// MARK: Collection View Data Source
extension MazeVC: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return rooms.count
  }

  func collectionView(_ collectionView: UICollectionView,
                      numberOfItemsInSection section: Int) -> Int {
    return rooms[section].count
  }

  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let room = rooms[indexPath.section][indexPath.row]

    if let room = room {
      let cell = collectionView
        .dequeueReusableCell(withReuseIdentifier: MazeCell.reuseID,
                             for: indexPath) as! MazeCell
      cell.configure(room: room)
      return cell
    } else {
      let emptyCell = collectionView
        .dequeueReusableCell(withReuseIdentifier: EmptyMazeCell.reuseID,
                             for: indexPath) as! EmptyMazeCell
      return emptyCell
    }
  }
}
