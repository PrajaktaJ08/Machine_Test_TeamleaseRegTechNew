//
//  EmployeeListModel.swift
//  Machine_Test_TeamleaseRegTech
//
//  Created by Prajakta Prakash Jadhav on 16/12/25.
//

import Foundation

// MARK: - EmployeeListModel
struct EmployeeListModel: Codable {
    let status: String
    let data: [EmployeeList]
    let message: String
}

struct EmployeeList: Codable {
    let id: Int
    let employeeName, employeeSalary, employeeAge, profileImage: String

    enum CodingKeys: String, CodingKey {
        case id
        case employeeName = "employee_name"
        case employeeSalary = "employee_salary"
        case employeeAge = "employee_age"
        case profileImage = "profile_image"
    }
}
