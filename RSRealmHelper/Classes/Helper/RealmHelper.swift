//
//  RealmHelper.swift
//  RSRealmHelper
//
//  Created by Marcus Costa on 08/08/18.
//

import Foundation
import RealmSwift

public class RealmHelper {

    private let instance: RealmFactory.Instance

    public init(realmInstance: RealmFactory.Instance = .default) {
        instance = realmInstance
    }

    private lazy var connection: Realm? = {
        return try? RealmFactory.make(for: self.instance)
    }()

    /// Clone the realm helper instance to use a connection on another thread
    ///
    /// - returns: A new instance of a realm connection
    public func clone() -> RealmHelper {
        return RealmHelper(realmInstance: instance)
    }

    /// Update realm and managed objects to point to the most recent data
    public func refreshRealm() {
        _ = connection?.refresh()
    }

}

// MARK: - Read functions
extension RealmHelper {

    /// Find first object of type
    ///
    /// - returns: The first object of requested type or nil
    public func findFirst<T: Object>() -> T? {
        return connection?.objects(T.self).first
    }

    /// Find all objects of type
    ///
    /// - returns: A list of all objects of requested type
    public func findAll<T: Object>() -> [T] {
        return connection?.objects(T.self).toArray() ?? []
    }

    /// Find all objects of type that matchs a predicate
    ///
    /// - returns: A list of all objects of requested type
    public func find<T: Object>(withPredicate predicate: NSPredicate) -> [T] {
        return connection?.objects(T.self).filter(predicate).toArray() ?? []
    }

    /// Find first object of type that matchs a predicate
    ///
    /// - returns: A object of requested type that match a predicate or nil
    public func findFirst<T: Object>(withPredicate predicate: NSPredicate) -> T? {
        return connection?.objects(T.self).first(where: predicate.evaluate(with:))
    }

    /// Count saved elements of a specific type saved in database
    ///
    /// - returns: A number of elements saved in database of a specific type
    public func count<T: Object>(ofType type: T.Type) -> Int {
        return connection?.objects(T.self).count ?? 0
    }

    /// Count saved elements of a specific type saved in database that matches a predicate
    ///
    /// - returns: A number of elements saved in database of a specific type
    public func count<T: Object>(withPredicate predicate: NSPredicate, ofType type: T.Type) -> Int {
        return connection?.objects(T.self).filter(predicate).count ?? 0
    }

}

// MARK: - Write functions
extension RealmHelper {

    /// Open a closure to write objects in realm database
    ///
    /// - Parameter block: Closure to write objects in realm. This closures receive a realm connection that use if needed.
    /// - Throws: `RealmError.canNotAccessFile` if any error occurs when open a realm file.
    /// - Throws: `RealmError.canNotWriteOnDisk` if any error occurs when write on disk.
    public func writeInRealm(_ block: ((_ realm: Realm) -> Void)) throws {
        guard let connection = connection else {
            throw RealmError.canNotAccessFile
        }

        do {
            try connection.write {
                block(connection)
            }
        } catch {
            throw RealmError.canNotWriteOnDisk
        }
    }

    /// Save new object send as a parameter on database.
    ///
    /// - Parameter element: Object to save
    /// - Parameter incrementProperty: Name of numeric parameter that need to increment - Autoincrement
    /// - Throws: `RealmError.canNotWriteOnDisk` if any error occurs.
    public func save<T: Object>(_ element: T, incrementProperty propertyName: String? = nil) throws {
        let elements: [T] = [element]
        try save(elements: elements, incrementProperty: propertyName)
    }

    /// Save new objects send as a parameter on database.
    ///
    /// - Parameter element: Objects to save
    /// - Parameter incrementProperty: Name of numeric parameter that need to increment - Autoincrement
    /// - Throws: `RealmError.canNotWriteOnDisk` if any error occurs.
    public func save<T: Object>(elements: [T], incrementProperty propertyName: String? = nil) throws {
        if let property = propertyName {
            var propertyValue = connection?.objects(T.self).max(ofProperty: property) ?? 0
            for element in elements {
                propertyValue += 1
                element.setValue(propertyValue, forKey: property)
                do {
                    try writeInRealm { realm in
                        realm.add(element)
                    }
                } catch {
                    throw RealmError.canNotWriteOnDisk
                }
            }
            if RealmFactory.enableDebug {
                debugPrint("Inserted elements: \(elements)")
            }
        } else {
            try writeInRealm { realm in
                realm.add(elements)
                if RealmFactory.enableDebug {
                    debugPrint("Inserted elements: \(elements)")
                }
            }
        }
    }

    /// Update object send as a parameter on database.
    ///
    /// - Parameter element: Object to update
    /// - Throws: `RealmError.canNotWriteOnDisk` if any error occurs.
    public func update<T: Object>(_ element: T) throws {
        try update(elements: [element])
    }

    /// Update objects of type send as a parameter on database.
    ///
    /// - Parameter element: Objects to update
    /// - Throws: `RealmError.canNotWriteOnDisk` if any error occurs.
    public func update<T: Object>(elements: [T]) throws {
        do {
            try writeInRealm { realm in
                realm.add(elements, update: .all)
                if RealmFactory.enableDebug {
                    debugPrint("Updated elements: \(elements)")
                }
            }
        } catch {
            throw RealmError.canNotWriteOnDisk
        }
    }

}

// MARK: - Delete functions
extension RealmHelper {

    /// Deletes the object send as a parameter but do not delete its children objects (cascade delete).
    ///
    /// - Parameter element: Object to delete
    /// - Throws: `RealmError.canNotDeleteFiles` if any error occurs.
    public func delete<T: Object>(_ element: T) throws {
        try delete(elements: [element])
    }

    /// Deletes the objects send as a parameter but do not delete its children objects (cascade delete).
    ///
    /// - Parameter element: Objects to delete
    /// - Throws: `RealmError.canNotDeleteFiles` if any error occurs.
    public func delete<T: Object>(elements: [T]) throws {
        do {
            let deletedElements = elements.map{ "\($0)" }
            try writeInRealm { realm in
                realm.delete(elements)
                if RealmFactory.enableDebug {
                    debugPrint("Deleted elements: \(deletedElements)")
                }
            }
        } catch {
            throw RealmError.canNotDeleteFiles
        }
    }

    /// Deletes all objects of type send as a parameter but do not delete its children objects (cascade delete).
    ///
    /// - Parameter type: Class type that you need delete
    /// - Throws: `RealmError.canNotDeleteFiles` if any error occurs.
    public func deleteAll<T: Object>(type: T.Type) throws {
        do {
            try writeInRealm { realm in
                let objects = realm.objects(type)
                realm.delete(objects)
                if RealmFactory.enableDebug {
                    debugPrint("Deleted all elements of type \(type)")
                }
            }
        } catch {
            throw RealmError.canNotDeleteFiles
        }
    }

    /// Deletes the object send as a parameter, and its children objects (cascade delete).
    ///
    /// - Parameter element: Object to delete
    /// - Throws: `RealmError.canNotDeleteFiles` if any error occurs.
    public func cascadingDelete<T: Object & CascadeDeletableInstances>(_ element: T) throws {
        do {
            try writeInRealm { realm in
                cascadingDelete(element, inRealm: realm)
            }
        } catch {
            throw RealmError.canNotDeleteFiles
        }
    }

    /// Deletes the objects send as a parameter, and its children objects (cascade delete).
    ///
    /// - Parameter element: Objects to delete
    /// - Throws: `RealmError.canNotDeleteFiles` if any error occurs.
    public func cascadingDelete<T: Object & CascadeDeletableInstances>(elements: [T]) throws {
        do {
            try writeInRealm { realm in
                for element in elements {
                    cascadingDelete(element, inRealm: realm)
                }
            }
        } catch {
            throw RealmError.canNotDeleteFiles
        }
    }

    private func cascadingDelete<T: Object>(_ element: T, inRealm realm: Realm) {
        if let cascadeDeletableElement = element as? CascadeDeletableInstances {
            for childObjectToDelete in cascadeDeletableElement.objectsForCascadeDelete {
                cascadingDelete(childObjectToDelete, inRealm: realm)
            }
        }
        let deletedElement = "\(element)"
        realm.delete(element)
        if RealmFactory.enableDebug {
            debugPrint("Deleted element: \(deletedElement)")
        }
    }

    /// Deletes all objects of a certain type, and their children types (cascade delete).
    ///
    /// - Parameter type: The type of objects to delete
    /// - Throws: `RealmError.canNotDeleteFiles` if any error occurs.
    public func cascadingDeleteAll<T: Object & CascadeDeletableTypes>(type: T.Type) throws {
        do {
            try writeInRealm { realm in
                cascadingDeleteAll(type, inRealm: realm)
            }
        } catch {
            throw RealmError.canNotDeleteFiles
        }
    }

    private func cascadingDeleteAll<T: Object>(_ type: T.Type, inRealm realm: Realm) {
        if let cascadeDeletableType = type as? CascadeDeletableTypes.Type {
            for childTypeToDelete in cascadeDeletableType.typesForCascadeDelete {
                cascadingDeleteAll(childTypeToDelete, inRealm: realm)
            }
        }
        let objects = realm.objects(type)
        realm.delete(objects)
        if RealmFactory.enableDebug {
            debugPrint("Deleted all elements of type \(type)")
        }
    }

    /// Clear all database
    ///
    /// - Throws: `RealmError.canNotDeleteFiles` if any error occurs.
    public func clearDatabase() throws {
        do {
            try writeInRealm { realm in
                realm.deleteAll()
                if RealmFactory.enableDebug {
                    debugPrint("Database cleared")
                }
            }
        } catch {
            throw RealmError.canNotDeleteFiles
        }
    }

}
