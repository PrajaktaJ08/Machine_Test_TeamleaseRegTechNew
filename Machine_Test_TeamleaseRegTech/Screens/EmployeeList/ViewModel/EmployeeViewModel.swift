//
//  EmployeeViewModel.swift
//  Machine_Test_TeamleaseRegTech
//
//  Created by Prajakta Prakash Jadhav on 16/12/25.
//

import Foundation

extension EmployeeViewModel {
    enum Event {
        case loading
        case loaded
        case error(Error?)
    }
}


class EmployeeViewModel {
    
    var employeeResponse : EmployeeListModel? = nil
    var event: ((Event) -> Void)? = nil
    
    func getEmployeeData() {
        
        event?(.loading)
        
        APIManager.shared.fetchEmployeeData { [weak self] result in
            switch result {
            case .success(let employeeData):
                print(employeeData)
                self?.employeeResponse = employeeData
                self?.event?(.loaded)
                
            case .failure(let error):
                print(error.localizedDescription)
                self?.event?(.error(error))
            }
        }
    }
}
