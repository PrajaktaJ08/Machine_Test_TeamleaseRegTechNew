//
//  EmployeeDetailViewController.swift
//  Machine_Test_TeamleaseRegTech
//
//  Created by Prajakta Prakash Jadhav on 16/12/25.
//

import UIKit

class EmployeeDetailViewController: UIViewController {
    
    @IBOutlet weak var viewEmployeeDetail: UIView!
    @IBOutlet weak var imageViewEmployeeImage: UIImageView!
    @IBOutlet weak var textFieldEmployeeName: UITextField!
    @IBOutlet weak var textFieldEmployeeAge: UITextField!
    @IBOutlet weak var textFieldEmployeeSalary: UITextField!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var buttonLogOut: UIButton!
    @IBOutlet weak var buttonBack: UIButton!
    
    var employeeDetail : EmployeeEntity?
    
    private var userRole: UserRole? {
        let role = UserDefaults.standard.string(forKey: "userRole")
        return UserRole(rawValue: role ?? "")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupKeyboardDismiss()
        self.navigationItem.hidesBackButton = true
        setDesign()
        setData()
        configureUIForRole()
    }
    
    private func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }

    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setData() {
        self.textFieldEmployeeName.text = self.employeeDetail?.employeeName
        self.textFieldEmployeeAge.text = self.employeeDetail?.employeeAge ?? "0"
        self.textFieldEmployeeSalary.text = self.employeeDetail?.employeeSalary
    }
    
    func setDesign() {
        viewEmployeeDetail.applyCornerRadius(20)
        imageViewEmployeeImage.applyCornerRadius(10)
        textFieldEmployeeName.applyCornerRadius(10)
        textFieldEmployeeAge.applyCornerRadius(10)
        textFieldEmployeeSalary.applyCornerRadius(10)
        buttonSave.applyCornerRadius(10)
        buttonLogOut.applyCornerRadius(10)
        textFieldEmployeeName.applyBorder()
        textFieldEmployeeAge.applyBorder()
        textFieldEmployeeSalary.applyBorder()
    }
    
    func configureUIForRole() {
        
        guard let role = userRole else { return }
        
        switch role {
            
        case .hr:
            // HR can only view
            textFieldEmployeeName.isEnabled = false
            textFieldEmployeeAge.isEnabled = false
            textFieldEmployeeSalary.isEnabled = false
            buttonSave.isHidden = true
            buttonLogOut.isHidden = true
            buttonBack.isHidden = false
            
        case .employee:
            // Employee can edit age
            buttonBack.isHidden = true
            textFieldEmployeeName.isEnabled = false
            textFieldEmployeeAge.isEnabled = true
            textFieldEmployeeSalary.isEnabled = false
            buttonSave.isHidden = false
            buttonLogOut.isHidden = false
            
        }
    }
    
    
    @IBAction func buttonBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buttonSavePressed(_ sender: Any) {
        guard
                let name = textFieldEmployeeName.text, !name.isEmpty,
                let ageText = textFieldEmployeeAge.text, !ageText.isEmpty,
                let salary = textFieldEmployeeSalary.text, !salary.isEmpty,
                let age = Int(ageText)
            else {
                showAlert(message: "Please enter valid details")
                return
            }
            
            // Check if age is greater than 50
            if age > 50 {
                showAlert(message: "Age cannot be greater than 50")
                return
            }
            
            employeeDetail?.employeeName = name
            employeeDetail?.employeeAge = ageText
            employeeDetail?.employeeSalary = salary
            
            CoreDataManager.shared.saveContext()
            
            showAlert(message: "Employee details updated successfully")
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Success",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func buttonLogOutPressed(_ sender: Any) {
        view.endEditing(true)
        
        print("Logout tapped")
        
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "isLoggedIn")
        defaults.removeObject(forKey: "userRole")
        defaults.removeObject(forKey: "loggedInUser")
        defaults.synchronize()
        
        
        self.navigationController?.popToRootViewController(animated: true)
        
    }
}

extension EmployeeDetailViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIControl {
            return false
        }
        return true
    }

}
