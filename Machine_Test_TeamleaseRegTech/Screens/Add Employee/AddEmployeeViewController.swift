//
//  AddEmployeeViewController.swift
//  Machine_Test_TeamleaseRegTech
//
//  Created by Prajakta Prakash Jadhav on 16/12/25.
//

import UIKit

protocol AddEmployeeDelegate: AnyObject {
    func didAddEmployee()
}


class AddEmployeeViewController: UIViewController {
    
    @IBOutlet weak var textFieldId: UITextField!
    @IBOutlet weak var textFieldEmployeeName: UITextField!
    @IBOutlet weak var textFieldEmployeeAge: UITextField!
    @IBOutlet weak var textFieldEmployeeSalary: UITextField!
    @IBOutlet weak var buttonSave: UIButton!
    
    weak var delegate: AddEmployeeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDesign()
    }
    
    func setDesign() {
        buttonSave.applyCornerRadius(10)
        textFieldId.applyCornerRadius(10)
        textFieldEmployeeName.applyCornerRadius(10)
        textFieldEmployeeAge.applyCornerRadius(10)
        textFieldEmployeeSalary.applyCornerRadius(10)
        textFieldEmployeeName.applyBorder()
        textFieldEmployeeAge.applyBorder()
        textFieldEmployeeSalary.applyBorder()
        textFieldId.applyBorder()
    }
    
    @IBAction func buttonSavePressed(_ sender: Any) {
        guard
            let name = textFieldEmployeeName.text, !name.isEmpty,
            let ageText = textFieldEmployeeAge.text, let age = Int(ageText),
            let salaryText = textFieldEmployeeSalary.text, let salary = Int(salaryText),
            let idText = textFieldId.text, let id = Int(idText)
        else {
            showAlert(message: "Please enter all fields correctly")
            return
        }
        
        // Check duplicate
            if CoreDataManager.shared.employeeExists(id: id) {
                showAlert(message: "Employee with this ID already exists")
                return
            }

        //Prevent adding employees older than 50
        if age > 50 {
                showAlert(message: "Employees older than 50 cannot be added")
                return
            }
        
        // Save to Core Data
        CoreDataManager.shared.saveEmployee(
            id: id,
            name: name,
            age: age,
            salary: salary,
            profileImage: ""
        )
        
        delegate?.didAddEmployee()
        dismiss(animated: true)
    }
    
    @IBAction func buttonCancelPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

