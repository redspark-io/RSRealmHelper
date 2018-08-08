//
//  RealmMigrator.swift
//  RSRealmHelper
//
//  Created by Marcus Costa on 08/08/18.
//

import Foundation
import RealmSwift

public protocol RealmMigrator {

    func execute(migration: Migration, realmInstance: RealmFactory.Instance, oldVersion: UInt64, currentVersion: UInt64)

}
