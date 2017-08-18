Maisie
======

[![BuddyBuild][bb-svg]][bb-link]

[bb-svg]: https://dashboard.buddybuild.com/api/statusImage?appID=599743ae6981ef0001d3bbe5&branch=master&build=latest
[bb-link]: https://dashboard.buddybuild.com/apps/599743ae6981ef0001d3bbe5/build/latest?branch=master

Dependencies
------------

* [TakeHomeTask framework][takehometask], for querying the Maze tiles API
* [PromiseKit][promisekit], for cleaner async code
* [Gloss][gloss], for succinct JSON parsing
* [Kingfisher][kingfisher], for image caching

[promisekit]: https://github.com/mxcl/PromiseKit
[gloss]: https://github.com/hkellaway/Gloss
[kingfisher]: https://github.com/onevcat/Kingfisher
[takehometask]: https://github.com/jkrmr/Maisie/blob/master/TakeHomeTask.framework/Headers/MazeManager.h

Local development
-----------------

The latter three dependencies are managed by [CocoaPods][cocoapods].
To run the app locally, issue the following from the project root:

```
$ pod install
```

Then open `Maisie.xcworkspace`.

[cocoapods]: https://cocoapods.org

Automated tests
---------------

A [test suite][test-suite] is included using [XCTest][xctest].

```swift
// MaisieTests/MazeAPITests.swift L15-L28 (235cf32b)

class MazeAPITests: XCTestCase {
  var mazeManager = MockMazeManager()

  override func setUp() {
    super.setUp()
    MazeAPI.shared.mazeManager = self.mazeManager
  }

  func testSubsequentCallsForTheSameRoomAreFetchedFromCache() {
    _ = MazeAPI.shared.fetchRoom(roomId: self.mazeManager.mockRoomID)
    _ = MazeAPI.shared.fetchRoom(roomId: self.mazeManager.mockRoomID)
    XCTAssertEqual(self.mazeManager.timesCalled("fetchRoom"), 1)
  }
}
```
<sup>
  <a href="https://github.com/jkrmr/Maisie/blob/235cf32b/MaisieTests/MazeAPITests.swift#L15-L28">
    MaisieTests/MazeAPITests.swift#L15-L28 (235cf32b)
  </a>
</sup>


[xctest]: https://developer.apple.com/documentation/xctest "XCTest documentation"
[test-suite]: https://github.com/jkrmr/Maisie/tree/master/MaisieTests

Demo
----

[![maze generation][maze-gif]][maze-gif]

[maze-gif]: https://user-images.githubusercontent.com/4433943/29474303-2e4c94d2-8429-11e7-90c1-a33d71fc91d9.gif

Implementation walkthrough
--------------------------


```swift
// Maisie/Controllers/MazeVC.swift L11-L26 (235cf32b)

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
```
<sup>
  <a href="https://github.com/jkrmr/Maisie/blob/235cf32b/Maisie/Controllers/MazeVC.swift#L11-L26">
    Maisie/Controllers/MazeVC.swift#L11-L26 (235cf32b)
  </a>
</sup>


```swift
// Maisie/Controllers/MazeVC.swift L43-L45 (235cf32b)

  @IBAction func generateButtonWasPressed(_ sender: UIButton) {
    self.maze.generate()
  }
```
<sup>
  <a href="https://github.com/jkrmr/Maisie/blob/235cf32b/Maisie/Controllers/MazeVC.swift#L43-L45">
    Maisie/Controllers/MazeVC.swift#L43-L45 (235cf32b)
  </a>
</sup>


```swift
// Maisie/Models/Maze.swift L40-L54 (235cf32b)

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
```
<sup>
  <a href="https://github.com/jkrmr/Maisie/blob/235cf32b/Maisie/Models/Maze.swift#L40-L54">
    Maisie/Models/Maze.swift#L40-L54 (235cf32b)
  </a>
</sup>

```swift
// Maisie/Models/MazeAPI.swift L47-L60 (235cf32b)

  func fetchRoom(roomId: String, coordinates: Coordinates? = nil) -> Promise<Room> {
    return Promise { (fulfill, reject) in
      // If room has already been encountered, return its cached copy
      // without making an API call
      if let room = MazeCache.shared.get(roomWithId: roomId) {
        fulfill(room)
        return
      }

      // Query the API for the given room ID's associated room attributes
      self.mazeManager.fetchRoom(withIdentifier: roomId) { (data, error) in
        if let error = error {
          return reject(error)
        }
```
<sup>
  <a href="https://github.com/jkrmr/Maisie/blob/235cf32b/Maisie/Models/MazeAPI.swift#L47-L60">
    Maisie/Models/MazeAPI.swift#L47-L60 (235cf32b)
  </a>
</sup>

```swift
// Maisie/Models/MazeCache.swift L11-L16 (235cf32b)

final class MazeCache {
  static let shared = MazeCache()
  private init() {}

  var roomsById = NSCache<NSString, Room>()
  var roomsByCoordinate = NSCacheCache<Coordinates, Room>()
```
<sup>
  <a href="https://github.com/jkrmr/Maisie/blob/235cf32b/Maisie/Models/MazeCache.swift#L11-L16">
    Maisie/Models/MazeCache.swift#L11-L16 (235cf32b)
  </a>
</sup>

```swift
// Maisie/Models/Maze.swift L70-L93 (235cf32b)

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
```
<sup>
  <a href="https://github.com/jkrmr/Maisie/blob/235cf32b/Maisie/Models/Maze.swift#L70-L93">
    Maisie/Models/Maze.swift#L70-L93 (235cf32b)
  </a>
</sup>

```swift
// Maisie/Models/Room.swift L22-L37 (d2cb1090)

  /// Pointers to adjacent rooms that have not already been encountered.
  /// Whether or not a room has been encountered is determined by checking
  /// the maze cache. This check is needed in order to stop the graph traversal
  /// that builds the maze.
  var newNeighbors: [RoomPointer] {
    return neighbors.filter { roomPointer in
      !MazeCache.shared.contains(roomWithId: roomPointer.targetId)
    }
  }

  /// Promises returning adjacent Rooms that have not been encountered before.
  var neighboringRooms: [Promise<Room>] {
    return newNeighbors.map { roomPointer in
      roomPointer.getRoom(from: self)
    }
  }
```
<sup>
  <a href="https://github.com/jkrmr/Maisie/blob/d2cb1090/Maisie/Models/Room.swift#L22-L37">
    Maisie/Models/Room.swift#L22-L37 (d2cb1090)
  </a>
</sup>

```swift
// Maisie/Models/RoomPointer.swift L45-L54 (d2cb1090)

  /// Return a Promise to the Room pointed to by this RoomPointer.
  func getRoom(from origin: Room) -> Promise<Room> {
    return fetchRoom(roomId: targetId, originCoordinates: origin.coordinates)
  }

  fileprivate func fetchRoom(roomId: String, originCoordinates coords: Coordinates)
    -> Promise<Room> {
    let target = Coordinates.inDirection(self.direction, fromOrigin: coords)
    return MazeAPI.shared.fetchRoom(roomId: roomId, coordinates: target)
  }
```
<sup>
  <a href="https://github.com/jkrmr/Maisie/blob/d2cb1090/Maisie/Models/RoomPointer.swift#L45-L54">
    Maisie/Models/RoomPointer.swift#L45-L54 (d2cb1090)
  </a>
</sup>

```swift
// Maisie/Models/RoomPointer.swift L57-L74 (d2cb1090)

class LockedRoomPointer: RoomPointer {
  /// A specialization of `getRoom` that first unlocks the given room to get
  /// the room ID, then returns a promise that resolves to that Room.
  ///
  /// - Parameters:
  ///   - origin: The origin Room from which to understand the pointer's
  ///             direction.
  ///
  override func getRoom(from origin: Room) -> Promise<Room> {
    return firstly {
      return MazeAPI.shared.unlockRoom(lockId: targetId)
    }.then { roomId in
      return self.fetchRoom(roomId: roomId, originCoordinates: origin.coordinates)
    }.catch { error in
      print("Error: \(error)")
    }
  }
}
```
<sup>
  <a href="https://github.com/jkrmr/Maisie/blob/d2cb1090/Maisie/Models/RoomPointer.swift#L57-L74">
    Maisie/Models/RoomPointer.swift#L57-L74 (d2cb1090)
  </a>
</sup>


```swift
// Maisie/Controllers/MazeVC.swift L48-L79 (235cf32b)

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
```
<sup>
  <a href="https://github.com/jkrmr/Maisie/blob/235cf32b/Maisie/Controllers/MazeVC.swift#L48-L79">
    Maisie/Controllers/MazeVC.swift#L48-L79 (235cf32b)
  </a>
</sup>

```swift
// Maisie/Controllers/MazeVC.swift L101-L116 (d2cb1090)

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
```
<sup>
  <a href="https://github.com/jkrmr/Maisie/blob/d2cb1090/Maisie/Controllers/MazeVC.swift#L101-L116">
    Maisie/Controllers/MazeVC.swift#L101-L116 (d2cb1090)
  </a>
</sup>

```swift
// Maisie/Models/Maze.swift L56-L64 (64bad87c)

  /// Add a room to the known maze.
  /// Stores the new room's coordinates, then regenerates the maze grid
  /// from the set of all currently known coordinates.
  /// Notifies the delegate that the maze has been updated.
  func add(room: Room) {
    roomCoordinates.insert(room.coordinates)
    regenerateGrid()
    delegate?.didUpdateMaze(grid: grid)
  }
```
<sup>
  <a href="https://github.com/jkrmr/Maisie/blob/64bad87c/Maisie/Models/Maze.swift#L56-L64">
    Maisie/Models/Maze.swift#L56-L64 (64bad87c)
  </a>
</sup>
