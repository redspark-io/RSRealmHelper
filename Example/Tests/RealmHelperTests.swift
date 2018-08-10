//
//  RealmHelperTests.swift
//  RSRealmHelper_Tests
//
//  Created by Marcus Costa on 10/08/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import RSRealmHelper
import RealmSwift

final class RealmHelperTests: XCTestCase {

    private var realmHelper: RealmHelper!

    override func setUp() {
        super.setUp()

        realmHelper = RealmHelper(realmInstance: .inMemory)
    }
    
    override func tearDown() {
        try! realmHelper.writeInRealm { realm in
            realm.deleteAll()
        }
        super.tearDown()
    }

    func testSaveAndRetrieveObjectInRealm() {
        let mockObject = MockObject()
        mockObject.id = 10
        try! realmHelper.save(mockObject)

        let objects: [MockObject] = realmHelper.findAll()

        XCTAssert(objects.count == 1)
        XCTAssert(objects.first?.id == mockObject.id)
    }

    func testSaveWithAutoIncrement() {
        let mockObject = MockObject()
        mockObject.id = 10
        try! realmHelper.save(mockObject)

        let newMock = MockObject()
        try! realmHelper.save(newMock, incrementProperty: "id")

        let objects: [MockObject] = realmHelper.findAll()

        let maxId = objects.map({ $0.id }).max()
        XCTAssert(maxId == mockObject.id + 1)
    }

    func testSaveListOfElements() {
        let mockObject1 = MockObject()
        mockObject1.name = "Obj1"
        let mockObject2 = MockObject()
        mockObject2.name = "Obj2"
        let elements = [mockObject1, mockObject2]
        try! realmHelper.save(elements: elements, incrementProperty: "id")

        let objects: [MockObject] = realmHelper.findAll()

        XCTAssert(objects == elements)
    }

    func testFetchFirstObjectWithPredicate() {
        let mockObject = MockObject()
        mockObject.id = 10
        try! realmHelper.save(mockObject)

        var idPredicate = NSPredicate(format: "id == %d", mockObject.id)
        var objectById: MockObject? = realmHelper.findFirst(withPredicate: idPredicate)

        XCTAssert(objectById != nil)

        idPredicate = NSPredicate(format: "id == %d", 1)
        objectById = realmHelper.findFirst(withPredicate: idPredicate)

        XCTAssert(objectById == nil)
    }

    func testFetchListOfObjectsWithPredicate() {
        let mockObject = MockObject()
        mockObject.id = 10
        try! realmHelper.save(mockObject)

        var idPredicate = NSPredicate(format: "id == %d", mockObject.id)
        var objectById: [MockObject] = realmHelper.find(withPredicate: idPredicate)

        XCTAssert(objectById.count == 1)

        idPredicate = NSPredicate(format: "id == %d", 1)
        objectById = realmHelper.find(withPredicate: idPredicate)

        XCTAssert(objectById.isEmpty)
    }

    func testDeleteElement() {
        let mockObject = MockObject()
        try! realmHelper.save(mockObject)

        var objects: [MockObject] = realmHelper.findAll()

        XCTAssert(!objects.isEmpty)

        try! realmHelper.delete(mockObject)

        objects = realmHelper.findAll()

        XCTAssert(objects.isEmpty)
    }

    func testDeleteElements() {
        try! realmHelper.save(MockObject(), incrementProperty: "id")
        try! realmHelper.save(MockObject(), incrementProperty: "id")

        var objects: [MockObject] = realmHelper.findAll()

        XCTAssert(!objects.isEmpty)

        try! realmHelper.delete(elements: objects)

        objects = realmHelper.findAll()

        XCTAssert(objects.isEmpty)
    }

    func testDeleteAllElementsInTable() {
        try! realmHelper.save(MockObject(), incrementProperty: "id")
        try! realmHelper.save(MockObject(), incrementProperty: "id")

        var objects: [MockObject] = realmHelper.findAll()

        XCTAssert(!objects.isEmpty)

        try! realmHelper.deleteAll(type: MockObject.self)

        objects = realmHelper.findAll()

        XCTAssert(objects.isEmpty)
    }

    func testMultiThreadRealmConnection() {
        try! realmHelper.save(MockObject(), incrementProperty: "id")
        let exp = expectation(description: "Use connection in another thread")

        DispatchQueue.main.async {
            let objects: [MockObject] = self.realmHelper.findAll()
            XCTAssert(!objects.isEmpty)
            exp.fulfill()
        }

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

}
