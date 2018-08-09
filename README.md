# RSRealmHelper

[![CI Status](https://img.shields.io/travis/marcusvc.costa@gmail.com/RSRealmHelper.svg?style=flat)](https://travis-ci.org/marcusvc.costa@gmail.com/RSRealmHelper)
[![Version](https://img.shields.io/cocoapods/v/RSRealmHelper.svg?style=flat)](https://cocoapods.org/pods/RSRealmHelper)
[![License](https://img.shields.io/cocoapods/l/RSRealmHelper.svg?style=flat)](https://cocoapods.org/pods/RSRealmHelper)
[![Platform](https://img.shields.io/cocoapods/p/RSRealmHelper.svg?style=flat)](https://cocoapods.org/pods/RSRealmHelper)

## Description

The RSRealmHelper library is a class helper to work with [Realm](https://realm.io/docs/swift/latest/) database removing all boilerplate on setup of database.
This library configure all Realm database to works with crypto, saving a crypto key on keychain access using a [KeyChainAccess](https://github.com/kishikawakatsumi/KeychainAccess) library), allows to use multiples realm files to isolate data by user, for example and create a clone connection to perform a thread safe execution.

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

You can use the library directly, without initial setup.

### Entities
Create your own entities conform a instructions on [Realm Documentation](https://realm.io/docs/swift/latest/#getting-started) like `EmployeeRealm`
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
The RealmHelper Instances allow you to create a instance of realm to a specific purposes, you can create a default, custom or inMemory instance, but only default and custom instances uses a crypto.

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

### Save / Update objetcs

You can save or update your entity using a realm helper simply calling a save or update function with entity as a parameter, but to update your entity needs to implement a primary key and not attached to realm yet

```swift
let employee = EmployeeRealm()
try! realmHelper.save(employee)
try! realmHelper.update(employee)
```

If you need to increment your identifier, normally the primary key property, you need to call a function with the name of  the parameter you need to increase.

```swift
let employee = EmployeeRealm()
try! realmHelper.save(employee, incrementProperty: "id")
```

To update a attached realm object, you need to open a write block and update the properties. 
Write block send a instance of realm if you need to create something in particular.

```swift
let employee = EmployeeRealm()
try! realmHelper.save(employee)
try! realmHelper.writeInRealm { realm in
    employee.name = "new name"
}
```
### Fetch / Count objects

Realm Helper provides some functions to performs a more redable code, and works with generics and type inference.

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

Realm Helper provides to ways to delete objects, a simple delete and a cascade delete that deletes elements and your childs.

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

If you need to delete entities using a cascade method, you need to implement the `CascadeDeletable` protocol in your entity to mapper the properties needs to be deleted when  the entity be deleted, like this:
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

And when you delete your object you need to call the function `cascadingDelete` instead the `delete` function.
```swift
try! realmHelper.cascadingDelete(company)
```
And finally, if you need to delete all database you can call 

```swift
try! realmHelper.clearDatabase()
```

### Thread safe

To call realm helper's functions in diferent threads using the same helper you need to clone the helper instance before call your functions.

```swift
DispatchQueue.main.async {
    let threadSafeRealmHelper = self.realmHelper.clone()
    let companyList: [CompanyRealm] = threadSafeRealmHelper.findAll()
    print("Thread safe sample: \(companyList)")
}
```

### Debug

Sets the `RealmFactory.enableDebug` to enable / disable the debug messages

```swift
RealmFactory.enableDebug = true
```

### Migration

To performs a Realm migration in you database we need to add a key in a project info.plist with name `DATABASE_SCHEMA_VERSION` and a numeric valur of your database schema version.

Create a class that implements a   `RealmMigrator` protocol:
```swift
class MyRealmMigrator: RealmMigrator {

    func execute(migration: Migration, realmInstance: RealmFactory.Instance, oldVersion: UInt64, currentVersion: UInt64) {

    }

}

```

And set you newer class, that implements a `RealmMigrator` protocol on `RealmFactory` class.

```swift
RealmFactory.realmMigrator = MyRealmMigrator()
```

## Credits

RSRealmHelper is owned and maintained by the [redspark](http://redspark.io/)

### contributors
Marcus Costa - marcus.costa@redspark.io

## License

RSRealmHelper is available under the MIT license. See the LICENSE file for more info.
