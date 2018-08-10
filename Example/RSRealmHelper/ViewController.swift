//
//  ViewController.swift
//  RSRealmHelper
//
//  Created by marcusvc.costa@gmail.com on 08/08/2018.
//  Copyright (c) 2018 marcusvc.costa@gmail.com. All rights reserved.
//

import UIKit
import RSRealmHelper

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        RealmFactory.enableDebug = true
        
        // Instantiate RealmHelper
        let realmHelper = RealmHelper()

        // Save
        let employee = EmployeeRealm()
        employee.name = "EmployeeName"
        try! realmHelper.save(employee, incrementProperty: "id")

        try! realmHelper.save(EmployeeRealm(), incrementProperty: "id")
        try! realmHelper.save(EmployeeRealm(), incrementProperty: "id")

        // Count
        let count = realmHelper.count(ofType: EmployeeRealm.self)
        print(count)

        // Update
        let employee2 = EmployeeRealm(value: employee)
        employee2.name = "UpdatedName"
        try! realmHelper.update(employee2)

        // Find first
        if let savedEmployee: EmployeeRealm = realmHelper.findFirst() {
            print(savedEmployee.name)
        }

        // Find first with predicate
        if let employeeWithId: EmployeeRealm = realmHelper.findFirst(withPredicate: EmployeeRealm.query(withId: employee2.id)) {
            print(employeeWithId.name)
        }

        // Delete
        try! realmHelper.delete(employee2)
        try! realmHelper.deleteAll(type: EmployeeRealm.self)

        // Save / Delete Cascade
        let newEmployee = EmployeeRealm()
        newEmployee.id = 123
        newEmployee.name = "EmployeeName"

        let company = CompanyRealm()
        company.id = 123
        company.name = "companyName"
        company.employeeList.append(newEmployee)

        try! realmHelper.save(company)

        var companyList: [CompanyRealm] = realmHelper.findAll()
        print(companyList)

        try! realmHelper.cascadingDelete(company)
        companyList = realmHelper.findAll()
        print(companyList)

        // Thread safe
        DispatchQueue.main.async {
            let threadSafeRealmHelper = realmHelper.clone()
            let companyList: [CompanyRealm] = threadSafeRealmHelper.findAll()
            print("Thread safe sample: \(companyList)")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

