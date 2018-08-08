//
//  CompanyRealm.swift
//  RSRealmHelper_Example
//
//  Created by Marcus Costa on 08/08/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import RealmSwift
import RSRealmHelper

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

