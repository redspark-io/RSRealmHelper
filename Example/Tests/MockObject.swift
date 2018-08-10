//
//  MockObject.swift
//  RSRealmHelper_Tests
//
//  Created by Marcus Costa on 10/08/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import RealmSwift

final class MockObject: Object {

    @objc dynamic var id = Int()
    @objc dynamic var name = String()

    override static func primaryKey() -> String? {
        return "id"
    }

}

// MARK: - Queries
extension MockObject {

    static func query(withId id: Int) -> NSPredicate {
        return NSPredicate(format: "id == %d", id)
    }

}
