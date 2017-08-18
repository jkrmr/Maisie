Maisie
======

[![BuddyBuild][bb-svg]][bb-link]

Dependencies
------------

* TakeHomeTask framework, for querying the Maze tiles API
* PromiseKit, for cleaner async code
* Gloss, for succinct JSON parsing
* Kingfisher, for image caching


Local development
-----------------

The latter three dependencies are managed by CocoaPods.
To run the app locally, issue the following from the project root:

```
$ pod install
```

Then open `Maisie.xcworkspace`.

Simulator
---------

The app was developed against the iPhone 7 simulator and has been tested on the
iPhone 7 Plus simulator as well.


Automated tests
---------------

A (nearly) complete suite of tests is included. The specific test requested is
in `MazeAPITests.swift`.

Demo
----

[![maze generation][maze-gif]][maze-gif]

[maze-gif]: https://user-images.githubusercontent.com/4433943/29474303-2e4c94d2-8429-11e7-90c1-a33d71fc91d9.gif
[bb-svg]: https://dashboard.buddybuild.com/api/statusImage?appID=599743ae6981ef0001d3bbe5&branch=master&build=latest
[bb-link]: https://dashboard.buddybuild.com/apps/599743ae6981ef0001d3bbe5/build/latest?branch=master

