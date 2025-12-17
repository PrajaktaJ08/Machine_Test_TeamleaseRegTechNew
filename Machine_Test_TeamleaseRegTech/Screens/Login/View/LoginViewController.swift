//
//  LoginViewController.swift
//  Machine_Test_TeamleaseRegTech
//
//  Created by Prajakta Prakash Jadhav on 16/12/25.
//

import UIKit

//for user role
enum UserRole: String {
    case hr
    case employee
}

class LoginViewController: UIViewController {
    
    @IBOutlet weak var viewLogin: UIView!
    @IBOutlet weak var textFieldUserName: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var buttonLogin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        setDesign()
        setupKeyboardDismiss()
        // Check if user is already logged in
        let defaults = UserDefaults.standard
        
        if defaults.bool(forKey: "isLoggedIn") {
            let role = defaults.string(forKey: "userRole")
            
            if role == UserRole.hr.rawValue {
                navigateToEmployeeList()
            } else if role == UserRole.employee.rawValue,
                      let username = defaults.string(forKey: "loggedInUser") {
                navigateToEmployeeDetail(employeeName: username)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        textFieldUserName.text = ""
        textFieldPassword.text = ""
    }
    func setDesign() {
        viewLogin.applyCornerRadius(20)
        textFieldPassword.applyCornerRadius(10)
        textFieldUserName.applyCornerRadius(10)
        textFieldUserName.applyBorder()
        textFieldPassword.applyBorder()
        buttonLogin.applyCornerRadius(10)
        viewLogin.applyBorder()
    }
    
    private func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func buttonLoginPressed(_ sender: Any) {
        
        let username = textFieldUserName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = textFieldPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let defaults = UserDefaults.standard

        // HR credentials
        if username == "HR@team" && password == "Team@123" {

            defaults.set(true, forKey: "isLoggedIn")
            defaults.set(UserRole.hr.rawValue, forKey: "userRole")

            navigateToEmployeeList()
            return
        }

        // Employee credentials
        if username == "Bradley Greer" && password == "Team@12345" {

            defaults.set(true, forKey: "isLoggedIn")
            defaults.set(UserRole.employee.rawValue, forKey: "userRole")
            defaults.set(username, forKey: "loggedInUser")

            navigateToEmployeeDetail(employeeName: username)
            return
        }

        showAlert(title: "Login Failed", message: "Invalid username or password")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let defaults = UserDefaults.standard

        guard defaults.bool(forKey: "isLoggedIn"),
              let role = defaults.string(forKey: "userRole") else {
            return
        }

        if role == UserRole.hr.rawValue {
            navigateToEmployeeList()
        } else if role == UserRole.employee.rawValue,
                  let username = defaults.string(forKey: "loggedInUser") {
            navigateToEmployeeDetail(employeeName: username)
        }
    }

    
    private func navigateToEmployeeList() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let employeeVC = storyboard.instantiateViewController(
            withIdentifier: "EmployeeListViewController"
        ) as? EmployeeListViewController {
            navigationController?.pushViewController(employeeVC, animated: true)
        }
    }
    
    private func navigateToEmployeeDetail(employeeName: String) {
        
        let employees = CoreDataManager.shared.fetchEmployees()
        
        guard let employee = employees.first(where: {
            $0.employeeName == employeeName
        }) else {
            showAlert(title: "Error", message: "Employee data not found")
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(
            withIdentifier: "EmployeeDetailViewController"
        ) as? EmployeeDetailViewController {
            
            detailVC.employeeDetail = employee
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default))
        self.present(alert, animated: true)
    }
}

