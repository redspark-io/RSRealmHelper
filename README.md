# RSRealmHelper

[![CI Status](https://img.shields.io/travis/marcusvc.costa@gmail.com/RSRealmHelper.svg?style=flat)](https://travis-ci.org/marcusvc.costa@gmail.com/RSRealmHelper)
[![Version](https://img.shields.io/cocoapods/v/RSRealmHelper.svg?style=flat)](https://cocoapods.org/pods/RSRealmHelper)
[![License](https://img.shields.io/cocoapods/l/RSRealmHelper.svg?style=flat)](https://cocoapods.org/pods/RSRealmHelper)
[![Platform](https://img.shields.io/cocoapods/p/RSRealmHelper.svg?style=flat)](https://cocoapods.org/pods/RSRealmHelper)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

RSRealmHelper is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RSRealmHelper'
```

## Usage

You can usage the library directly, without initial setup.

### Entities
Create your own entities like `EmployeeRealm`
```swift
import RealmSwift

final class EmployeeRealm: Object {

    @objc dynamic var id = Int()
    @objc dynamic var name = String()

    override static func primaryKey() -> String? {
        return "id"
    }

}
```

### RealmHelper Instances 
Create a RealmHelper on your local data manager class to manage objects on database.

```swift
let realmHelper = RealmHelper(realmInstance: .default)
```

You can create a default instance of database or a custom type.
With custom type you can separate the user data on a specific file, isolated from others.

```swift
let instanceName = "user_123"
let realmInstance = RealmFactory.Instance.custom(name: instanceName)
let realmHelper = RealmHelper(realmInstance: realmInstance)
```

Or you can create your database inMemory for tests purposes.
```swift
let realmHelper = RealmHelper(realmInstance: .inMemory)
```


## Credits

RSRealmHelper is owned and maintained by the [redspark](http://redspark.io/)

### contributors
Marcus Costa - marcus.costa@redspark.io

## License

RSRealmHelper is available under the MIT license. See the LICENSE file for more info.
