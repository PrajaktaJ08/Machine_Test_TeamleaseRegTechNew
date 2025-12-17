//
//  EmployeeListViewController.swift
//  Machine_Test_TeamleaseRegTech
//
//  Created by Prajakta Prakash Jadhav on 16/12/25.
//

import UIKit

class EmployeeListViewController: UIViewController {
    
    @IBOutlet weak var tableViewEmployeeList: UITableView!
    @IBOutlet weak var searchBarEmployee: UISearchBar!
    @IBOutlet weak var buttonMoreOptions: UIBarButtonItem!
    @IBOutlet weak var buttonAdd: UIButton!
    
    let employeeViewModel = EmployeeViewModel()
    var employeeResponse : EmployeeListModel?
    var employeesFromDB: [EmployeeEntity] = []
    var filteredEmployees: [EmployeeEntity] = []
    var isSearching = false
    private var loader: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupKeyboardDismiss()
        print(UIDevice.current.systemVersion)

        buttonAdd.applyCornerRadius(10)
        self.navigationItem.hidesBackButton = true
        setupMenu()
        registerXib()
        setupLoader()
        
        searchBarEmployee.delegate = self
        
        observerEvent()
        
        //load from coredata
        employeesFromDB = CoreDataManager.shared.fetchEmployees()
        filteredEmployees = employeesFromDB
        tableViewEmployeeList.reloadData()
        
        // Calls api if Core Data is empty
        if employeesFromDB.isEmpty {
            getEmployeeData()
        }
        
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
    
    func getEmployeeData() {
        // No internet
        NetworkHelper.performIfConnected(self){
            self.employeeViewModel.getEmployeeData()
        }
    }
    
    func observerEvent() {
        employeeViewModel.event = { [weak self] event in
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch event {
                    
                case .loading:
                    self.loader.startAnimating()
                    
                case .loaded:
                    self.loader.stopAnimating()
                    
                    self.employeeResponse = self.employeeViewModel.employeeResponse
                    
                    //Save employee data to coredata
                    if let employees = self.employeeResponse?.data {
                        CoreDataManager.shared.saveEmployees(employees)
                    }
                    
                    //Fetch employee from coredata
                    self.employeesFromDB = CoreDataManager.shared.fetchEmployees()
                    self.filteredEmployees = self.employeesFromDB
                    self.isSearching = false
                    
                    self.tableViewEmployeeList.reloadData()
                    
                case .error(let err):
                    self.loader.stopAnimating()
                    print("Error loading employee data: \(err?.localizedDescription ?? "Error")")
                    
                    // Keep existing data
                    self.employeesFromDB = CoreDataManager.shared.fetchEmployees()
                    self.filteredEmployees = self.employeesFromDB
                    self.tableViewEmployeeList.reloadData()
                    
                    // Show alert ONLY if no local data
                    if self.employeesFromDB.isEmpty {
                        self.showAlert(message: "Unable to load employees. Please try again later.")
                    }
                }
            }
        }
    }
    
    func setupLoader() {
        loader = UIActivityIndicatorView(style: .large)
        loader.center = view.center
        loader.hidesWhenStopped = true
        view.addSubview(loader)
    }
    
    
    @IBAction func buttonSearchPressed(_ sender: Any) {
    }
    
    @IBAction func buttonAddEmployeePressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let addVC = storyboard.instantiateViewController(
            withIdentifier: "AddEmployeeViewController"
        ) as? AddEmployeeViewController {
            
            addVC.delegate = self
            
            if #available(iOS 15.0, *) {
                if let sheet = addVC.sheetPresentationController {
                    sheet.detents = [.medium(), .large()]
                    sheet.prefersGrabberVisible = true
                }
            } else {
                addVC.modalPresentationStyle = .fullScreen
            }

            
            present(addVC, animated: true)
        }
    }
    
    func registerXib() {
        tableViewEmployeeList.register(UINib(nibName: "EmployeeTableViewCell", bundle: nil), forCellReuseIdentifier: "EmployeeTableViewCell")
        self.tableViewEmployeeList.delegate = self
        self.tableViewEmployeeList.dataSource = self
        self.tableViewEmployeeList.reloadData()
    }
    
    func setupMenu() {
        
        let refreshAction = UIAction(
            title: "Refresh",
            image: UIImage(systemName: "arrow.clockwise")
        ) { [weak self] _ in
            self?.refreshTapped()
        }
        
        let logoutAction = UIAction(
            title: "Logout",
            image: UIImage(systemName: "power"),
            attributes: .destructive
        ) { [weak self] _ in
            self?.logoutTapped()
        }
        
        buttonMoreOptions.menu = UIMenu(children: [refreshAction, logoutAction])
        buttonMoreOptions.primaryAction = nil   // important for menu display
    }
    
    func refreshTapped() {
        print("Refresh tapped")
        getEmployeeData()
    }
    
    func logoutTapped() {
        print("Logout tapped")
        
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "isLoggedIn")
        defaults.removeObject(forKey: "userRole")
        defaults.removeObject(forKey: "loggedInUser")
        defaults.synchronize()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(
            withIdentifier: "LoginViewController"
        ) as? LoginViewController {
            
            let nav = UINavigationController(rootViewController: loginVC)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? SceneDelegate,
               let window = sceneDelegate.window {
                
                window.rootViewController = nav
                window.makeKeyAndVisible()
            }
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}

//MARK: - UITableView Methods

extension EmployeeListViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredEmployees.count : employeesFromDB.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let employeeCell = tableViewEmployeeList.dequeueReusableCell(withIdentifier: "EmployeeTableViewCell", for: indexPath) as! EmployeeTableViewCell
        
        let employee = isSearching
        ? filteredEmployees[indexPath.row]
        : employeesFromDB[indexPath.row]
        
        employeeCell.labelEmployeeName.text = employee.employeeName
        employeeCell.labelSerialNumber.text = "\(indexPath.row + 1)"
        employeeCell.selectionStyle = .none
        
        
        employeeCell.selectionStyle = .none
        return employeeCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("Row selected at index:", indexPath.row)
        
        let selectedEmployee = isSearching
        ? filteredEmployees[indexPath.row]
        : employeesFromDB[indexPath.row]
        
        guard let employeeDetailVC = storyboard?
            .instantiateViewController(withIdentifier: "EmployeeDetailViewController")
                as? EmployeeDetailViewController else { return }
        
        employeeDetailVC.employeeDetail = selectedEmployee
        navigationController?.pushViewController(employeeDetailVC, animated: true)
    }
    
    // Swipe to delete
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // Determine the employee
            let employee = isSearching ? filteredEmployees[indexPath.row] : employeesFromDB[indexPath.row]
            
            // Check age condition
            if let ageString = employee.employeeAge,
               let age = Int(ageString),  // Convert String to Int
               age > 50 {
                
                // 1. Delete from Core Data
                CoreDataManager.shared.deleteEmployee(id: Int(employee.id))
                
                // 2. Update data source
                if isSearching {
                    if let index = employeesFromDB.firstIndex(where: { $0.id == employee.id }) {
                        employeesFromDB.remove(at: index)
                    }
                    filteredEmployees.remove(at: indexPath.row)
                } else {
                    employeesFromDB.remove(at: indexPath.row)
                }
                
                // 3. Refresh table
                tableView.deleteRows(at: [indexPath], with: .automatic)
                
            } else {
                // Show alert if age <= 50
                showAlert(message: "Only employees older than age 50 can be deleted")
            }
        }
    }
}

extension EmployeeListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            isSearching = false
            filteredEmployees = employeesFromDB
        } else {
            isSearching = true
            filteredEmployees = employeesFromDB.filter {
                $0.employeeName?.lowercased().contains(searchText.lowercased()) == true
            }
        }
        
        tableViewEmployeeList.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        tableViewEmployeeList.reloadData()
    }
}

extension EmployeeListViewController:  AddEmployeeDelegate {
    func didAddEmployee() {
        employeesFromDB = CoreDataManager.shared.fetchEmployees()
        filteredEmployees = employeesFromDB
        tableViewEmployeeList.reloadData()
    }
}
