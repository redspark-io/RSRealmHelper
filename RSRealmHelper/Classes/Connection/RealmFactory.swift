//
//  RealmFactory.swift
//  RSRealmHelper
//
//  Created by Marcus Costa on 08/08/18.
//

import Foundation
import RealmSwift
import KeychainAccess

final public class RealmFactory {

    public static var realmMigrator: RealmMigrator?
    public static var enableDebug = false

    public enum Instance: Equatable {
        case inMemory
        case `default`
        case custom(name: String)

        public var name: String {
            switch self {
            case .inMemory:
                return String()
            case .default:
                return "\(self)"
            case .custom(let name):
                return name
            }
        }

        fileprivate var fileUrl: URL? {
            let realmPath = Realm.Configuration().fileURL?
                .deletingLastPathComponent()

            switch self {
            case .inMemory:
                return nil
            case .default:
                return realmPath?.appendingPathComponent("\(self).realm")
            case .custom(let name):
                return realmPath?.appendingPathComponent("\(name).realm")
            }
        }

        fileprivate var inMemoryIdentifier: String? {
            return self == .inMemory ? "\(self)" : nil
        }

        fileprivate var schemaVersion: UInt64 {
            switch self {
            case .inMemory:
                return 1
            default:
                let schemaKey = Constants.databaseSchemaVersion
                guard let schema = Bundle.main.object(forInfoDictionaryKey: schemaKey) as? String,
                    let schemaVersion = UInt64(schema) else {
                        #if DEBUG
                        if enableDebug {
                            debugPrint("Realm Helper -> Fail to load schema version number from info.plist file, implement \(schemaKey) key on info.plist")
                        }
                        #endif
                        return 1
                }

                return schemaVersion
            }
        }

        public static func ==(lhs: Instance, rhs: Instance) -> Bool {
            switch (lhs, rhs) {
            case (.inMemory, .inMemory),
                 (.default, .default):
                return true
            case (.custom(let lhsName), .custom(let rhsName)):
                return lhsName == rhsName
            default:
                return false
            }
        }
    }

    public static func make(for instance: Instance) throws -> Realm {
        let fileUrl = instance.fileUrl
        let encryptKey = encryptionKey(for: instance)
        let schemaVersion = instance.schemaVersion

        let config = Realm.Configuration(fileURL: instance.fileUrl,
                                         inMemoryIdentifier: instance.inMemoryIdentifier,
                                         encryptionKey: encryptKey,
                                         schemaVersion: schemaVersion,
                                         migrationBlock: { (migration, oldVersion) in
                                            realmMigrator?.execute(migration: migration, realmInstance: instance, oldVersion: oldVersion, currentVersion: instance.schemaVersion)
        })

        #if DEBUG
        if enableDebug {
            debugPrint("Realm Helper -> Open realm file: \(fileUrl?.absoluteString ?? String())")
            debugPrint("Realm Helper -> EncryptionKey: \(encryptKey.base64EncodedString())")
            debugPrint("Realm Helper -> Scheme Version: \(schemaVersion)")
        }
        #endif

        return try Realm(configuration: config)
    }

}

// MARK: - Encryption
extension RealmFactory {

    private enum Constants {
        private static let bundleIdentifier = Bundle.main.bundleIdentifier ?? String()
        static let databaseSchemaVersion = "DATABASE_SCHEMA_VERSION"
        static let keychainDatabaseService = "\(Constants.bundleIdentifier).database"
        static let keychainDatabaseEncryptionKey = "\(Constants.bundleIdentifier).encrypt.key"
        static let encryptionKeyLength = 64
    }

    private static func encryptionKey(for instance: Instance) -> Data {
        let keychain = Keychain(service: Constants.keychainDatabaseService)
        let keychainKey = Constants.keychainDatabaseEncryptionKey.appending(".\(instance.name)")

        if let key = keychain[data: keychainKey] {
            return key
        }

        let key = generateEncryptionKey()
        keychain[data: keychainKey] = key

        return key
    }

    private static func generateEncryptionKey() -> Data {
        var key = Data(count: Constants.encryptionKeyLength)
        _ = key.withUnsafeMutableBytes { bytes in
            _ = SecRandomCopyBytes(kSecRandomDefault, Constants.encryptionKeyLength, bytes)
        }

        return key
    }

}
