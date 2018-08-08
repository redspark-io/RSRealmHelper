//
//  RealmError.swift
//  RSRealmHelper
//
//  Created by Marcus Costa on 08/08/18.
//

import Foundation

public enum RealmError: Error {
    case canNotAccessFile
    case canNotWriteOnDisk
    case canNotDeleteFiles
    case objectNotFound
    case unknown
}
