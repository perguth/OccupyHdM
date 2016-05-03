# App Challenge

    Build an iOS and an Android app.


## Requirements

- [ ] Delivers App **description** with implemented categories (non-optional, mandatory)
- [ ] App builds and **runs out of the box** (soft-build requirement for Android, add apk) (3)
- [ ] Comprehensive Coding Style (Naming, Comments, Conventions) (2)
- [ ] Good Software Architecture (DRY, Abstraction, Modularization, Separation of Concerns, ...) (6)
- [ ] Function Range Category 1 (from List) (10)
- [ ] Function Range Category 2 (from List) (10)
- [ ] Overall App Complexity (5)
- [ ] Usability and Design (5)
- [ ] Automated Testing (3)


### Categories

    Pick two!

- [ ] Advanced User Interface
- [ ] Animation and Graphics
- [ ] Media and Camera
- [x] Location and Sensors
- [ ] Connectivity: Bluetooth, Wifi, etc.
- [ ] Data Storage
- [x] Networking: JSON parse, API consume


## The App

Our app is called `OccupyHdM`. We as the app operators preconfigure various points of interest (POI) on the HdM campus. The players can then claim those spots by moving into close proximity.

When starting the app the users will set a username which will be used as an identifier in our backend. The backend is reachable for the app via a REST API. The app will regularly pull the current set of POIs from the API. When players claim a spot, an API call will be made to update the dataset on the server. They will also gain a certain amount of points which will be only stored locally.
