//
//  Results+Array.swift
//  RSRealmHelper
//
//  Created by Marcus Costa on 08/08/18.
//

import Foundation
import RealmSwift

extension Results {

    func toArray() -> [ElementType] {
        return Array(self)
    }

}
