<p align="center">
    <img src="https://github.com/redspark-io/RSRealmHelper/blob/master/logo.png" alt="RSRealmHelper"/>
</p>

[![CI Status](https://img.shields.io/travis/redspark-io/RSRealmHelper.svg?style=flat)](https://travis-ci.org/redspark-io/RSRealmHelper)
[![Platform](https://img.shields.io/cocoapods/p/RSRealmHelper.svg?style=flat)](https://cocoapods.org/pods/RSRealmHelper)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/RSRealmHelper.svg?style=flat)](https://img.shields.io/cocoapods/v/RSRealmHelper.svg)
![Swift 4.0.x](https://img.shields.io/badge/Swift-4.0-orange.svg)
[![License](https://img.shields.io/cocoapods/l/RSRealmHelper.svg?style=flat)](https://cocoapods.org/pods/RSRealmHelper)

## Description

The RSRealmHelper library is a class helper to work with [Realm](https://realm.io/docs/swift/latest/) database removing all boilerplate when setting your database.
This library configures all Realm database to work with crypto, saving a crypto key on keychain access using a [KeyChainAccess](https://github.com/kishikawakatsumi/KeychainAccess) library. It allows you to use multiple realm files to isolate data by user and create a clone connection to perform a thread safe execution.

## Example

To run the example project, first clone the repo and run `pod install` from the Example directory.

## Requirements

## Installation

RSRealmHelper is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RSRealmHelper'
```

## Usage

You can use the library directly, without initial setup.

### Entities

Create your own entities following the instructions on [Realm Documentation](https://realm.io/docs/swift/latest/#getting-started) like `EmployeeRealm`

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
The RealmHelper Instances allows you to create an instance of realm to specific purposes. You can create a default, custom or inMemory instance, but only default and custom instances use crypto.

Create a RealmHelper on your local data manager class to manage objects on database.    
You can create a default instance of database.
```swift
let realmHelper = RealmHelper()
let realmHelper = RealmHelper(realmInstance: .default)
```


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

### Save / Update objects

You can save or update your entity using a RealmHelper by simply calling `save` or `update` functions with the entity as a parameter. But to update your entity, it needs to implement a primary key and not be attached to realm yet

```swift
let employee = EmployeeRealm()
try! realmHelper.save(employee)
try! realmHelper.update(employee)
```

If you need to increment your identifier, which usually is the primary key property, you need to call a function with the name of  the parameter you need to increase.

```swift
let employee = EmployeeRealm()
try! realmHelper.save(employee, incrementProperty: "id")
```

To update an attached realm object, you need to open a write block and update the properties.     
Write block sends an instance of realm in case you need to create something in particular.

```swift
let employee = EmployeeRealm()
try! realmHelper.save(employee)
try! realmHelper.writeInRealm { realm in
    employee.name = "new name"
}
```
### Fetch / Count objects

RealmHelper provides some functions to help you write a more redable code, because it works with generics and type inference.

```swift
// Count employees in database  
let count = realmHelper.count(ofType: EmployeeRealm.self)

// get all employees saved on database
let employeeList: [EmployeeRealm] = realmHelper.findAll()

// Get first employee saved on database
let employee: EmployeeRealm? = realmHelper.findFirst()

// Create a query
let predicate = NSPredicate(format: "id == %d", id)

// Count all employees that matches with your query
let count = realmHelper.count(withPredicate: predicate, ofType: EmployeeRealm.self)

// get all employees that matches with your query
let employeeList: [EmployeeRealm] = realmHelper.findAll(withPredicate: predicate)

// Get first employee that matches with your query
let employee: EmployeeRealm? = realmHelper.findFirst(withPredicate: predicate)
```

### Delete objects

RealmHelper provides two ways to delete objects, a simple delete and a cascade delete that deletes elements and their children.

To simple delete you can call the delete function.
```swift
// Delete a single element
let employee = EmployeeRealm()
try! realmHelper.delete(employee)

// Delete a list of elements
let employeeList: [EmployeeRealm] = [EmployeeRealm(), EmployeeRealm()]
realmHelper.delete(elements: employeeList)

// Delete all elements in table
try! realmHelper.deleteAll(type: EmployeeRealm.self)
```

If you need to delete entities using a cascade method, you need to implement the `CascadeDeletable` protocol in your entity to map the properties that need to be deleted together:

```swift
final class CompanyRealm: Object {

    @objc dynamic var id = Int()
    @objc dynamic var name = String()
    var employeeList = List<EmployeeRealm>()

}

// MARK: - CascadeDeletable
extension CompanyRealm: CascadeDeletable {

    var objectsForCascadeDelete: [Object] {
        var objects: [Object] = []
        objects.append(contentsOf: employeeList.toArray())
        return objects
    }

    static var typesForCascadeDelete: [Object.Type] {
        return [EmployeeRealm.self]
    }
}
```

Then you need to call the function `cascadingDelete` instead the `delete` function.
```swift
try! realmHelper.cascadingDelete(company)
```

If you need to delete all database you can call 

```swift
try! realmHelper.clearDatabase()
```

### Thread safe

To call RealmHelper's functions in diferent threads using the same helper you need to clone the helper instance before your function calls.

```swift
DispatchQueue.main.async {
    let threadSafeRealmHelper = self.realmHelper.clone()
    let companyList: [CompanyRealm] = threadSafeRealmHelper.findAll()
    print("Thread safe sample: \(companyList)")
}
```

### Debug

Set the property `RealmFactory.enableDebug` to enable / disable the debug messages

```swift
RealmFactory.enableDebug = true
```

### Migration

To perform a Realm migration in your database you need to add a key in a project info.plist with name `DATABASE_SCHEMA_VERSION` and the numeric value of your database schema version.

Create a class that implements the `RealmMigrator` protocol:
```swift
class MyRealmMigrator: RealmMigrator {

    func execute(migration: Migration, realmInstance: RealmFactory.Instance, oldVersion: UInt64, currentVersion: UInt64) {

    }

}

```

You must set your new class, which implements a `RealmMigrator` protocol, on `RealmFactory` class.

```swift
RealmFactory.realmMigrator = MyRealmMigrator()
```

## Credits

RSRealmHelper is owned and maintained by the [redspark](http://redspark.io/)

### Contributors
Marcus Costa - marcus.costa@redspark.io
Andre M. Della Torre - andre.dellatorre@redspark.io

## License

RSRealmHelper is available under the MIT license. See the LICENSE file for more info.
