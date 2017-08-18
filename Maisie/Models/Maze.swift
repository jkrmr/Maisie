//
//  Maze.swift
//  Maisie
//
//  Created by Jake Romer on 8/17/17.
//  Copyright © 2017 Jake Romer. All rights reserved.
//

import PromiseKit

protocol MazeDelegate: class {
  func didBeginLoadingMaze()
  func didBeginTraversal()
  func didUpdateMaze(grid: [[Room?]])
  func didEndTraversal()
  func didEndLoadingMaze()
}

final class Maze {
  static let shared = Maze()
  private init() {}

  weak var delegate: MazeDelegate?
  var isLoading = false

  var roomCoordinates = Set<Coordinates>()
  var grid = [[Room?]]()
  var gridHeight: Int?
  var gridWidth: Int?

  /// Resets the object's state.
  func reset() {
    roomCoordinates.removeAll()
    grid.removeAll()
    gridHeight = nil
    gridWidth = nil
    isLoading = false
  }

  /// Generate a new maze using the API.
  /// Resets any current state.
  /// Will no-op if a maze is currently generating.
  /// Notifies delegate via `didBeginLoadingMaze`.
  func generate() {
    guard !isLoading else { return }
    reset()
    delegate?.didBeginLoadingMaze()
    isLoading = true

    firstly { MazeAPI.shared.startRoom() }
      .then { roomId in MazeAPI.shared.fetchRoom(roomId: roomId) }
      .then { startRoom in self.fetchNeighbors(rooms: [startRoom]) }
      .catch { print("Error: \($0)") }
  }

  /// Add a room to the known maze.
  /// Stores the new room's coordinates, then regenerates the maze grid 
  /// from the set of all currently known coordinates.
  /// Notifies the delegate that the maze has been updated.
  func add(room: Room) {
    roomCoordinates.insert(room.coordinates)
    regenerateGrid()
    delegate?.didUpdateMaze(grid: grid)
  }

  func add(rooms: [Room]) {
    rooms.forEach({ self.add(room: $0 )})
  }

  /// Performs a depth-first traversal of the room graph, recursively
  /// fetching new adjacent rooms. Triggers lifecycle methods on the delegate.
  private func fetchNeighbors(rooms: [Room]) {
    if rooms.isEmpty {
      self.isLoading = false
      self.delegate?.didEndLoadingMaze()
      return
    }

    // set "maze is loading" state. Used to determine if a new maze can
    // currently be generated.
    self.isLoading = true

    // Notify delegate a traversal has begun, add any given rooms to the grid
    delegate?.didBeginTraversal()
    add(rooms: rooms)

    // recurse on each of the neighboring rooms once their 
    // promises are fulfilled.
    join(rooms.flatMap({ $0.neighboringRooms }))
      .then { rooms in self.fetchNeighbors(rooms: rooms) }
      .always { self.delegate?.didEndTraversal() }
      .catch { error in print("Error during graph traversal: \(error)") }
  }

  /// Regenerate the 2D array maze grid. Reuse the previously
  /// constructed array if possible.
  private func regenerateGrid() {
    let (rows, columns, rowOffset, colOffset) = gridDimensionsFromCoordinateList()

    if dimensionsNeedUpdating(rows: rows, cols: columns) {
      gridHeight = rows
      gridWidth = columns
      grid = createEmptyGrid(rows: rows, cols: columns)
    }

    (0..<rows).forEach { row in
      (0..<columns).forEach { column in
        let coords = Coordinates(row: rowOffset + row, col: colOffset + column)
        grid[row][column] = MazeAPI.shared.get(roomWithCoordinates: coords)
      }
    }
  }

  /// Calculate the dimensions of the grid implied by the
  /// current set of coordinates. Uses a single-pass implementation.
  private func gridDimensionsFromCoordinateList()
    -> (rows: Int, columns: Int, rowOffset: Int, colOffset: Int) {
    var (minRow, maxRow, minCol, maxCol) = (Int.max, Int.min, Int.max, Int.min)

    for coords in roomCoordinates {
      minRow = min(minRow, coords.row)
      maxRow = max(maxRow, coords.row)
      minCol = min(minCol, coords.col)
      maxCol = max(maxCol, coords.col)
    }

    let height = maxRow - (minRow - 1)
    let width = maxCol - (minCol - 1)

    return (rows: height, columns: width, rowOffset: minRow, colOffset: minCol)
  }

  /// Return true if the given dimensions differ from the current ones, or if 
  /// the current dimensions have not been set.
  private func dimensionsNeedUpdating(rows: Int, cols: Int) -> Bool {
    guard let prevRows = gridHeight,
          let prevCols = gridWidth
      else { return true }

    return !(prevRows == rows && prevCols == cols)
  }

  /// Generate an empty 2-D [[Room?]] array with the specified number of
  /// rows and columns.
  private func createEmptyGrid(rows: Int, cols: Int) -> [[Room?]] {
    return Array(repeating: Array(repeating: nil, count: cols), count: rows)
  }
}
