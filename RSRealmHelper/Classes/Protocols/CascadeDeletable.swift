//
//  CascadeDeletable.swift
//  RSRealmHelper
//
//  Created by Marcus Costa on 08/08/18.
//

import Foundation
import RealmSwift

public protocol CascadeDeletableInstances {

    var objectsForCascadeDelete: [Object] { get }

}

public protocol CascadeDeletableTypes {

    static var typesForCascadeDelete: [Object.Type] { get }

}

public typealias CascadeDeletable = CascadeDeletableInstances & CascadeDeletableTypes
