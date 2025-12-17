//
//  CoreDataManager.swift
//  Machine_Test_TeamleaseRegTech
//
//  Created by Prajakta Prakash Jadhav on 16/12/25.
//

import Foundation
import CoreData
import UIKit

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    private init() {}
    
    private var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    // Save API employees
    func saveEmployees(_ employees: [EmployeeList]) {
        for emp in employees {
            if employeeExists(id: emp.id) {
                continue   // skip duplicate
            }
            
            let entity = EmployeeEntity(context: context)
            entity.id = Int64(emp.id)
            entity.employeeName = emp.employeeName
            entity.employeeAge = String(emp.employeeAge)
            entity.employeeSalary = String(emp.employeeSalary)
            entity.profileImage = emp.profileImage
        }
        
        saveContext()
    }
    
    // Save manually added employee
    func saveEmployee(id: Int,
                      name: String,
                      age: Int,
                      salary: Int,
                      profileImage: String) {
        
        // Prevent duplicate
        if employeeExists(id: id) {
            print("Employee with id \(id) already exists")
            return
        }
        
        let employee = EmployeeEntity(context: context)
        employee.id = Int64(id)
        employee.employeeName = name
        employee.employeeAge = String(age)
        employee.employeeSalary = String(salary)
        employee.profileImage = profileImage
        
        saveContext()
    }
    
    //delete employee from core data on swipe left
    func deleteEmployee(id: Int) {
        let fetchRequest: NSFetchRequest<EmployeeEntity> = EmployeeEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let results = try context.fetch(fetchRequest)
            for obj in results {
                context.delete(obj)
            }
            saveContext()
        } catch {
            print("Failed to delete employee: \(error)")
        }
    }
    
    
    func fetchEmployees() -> [EmployeeEntity] {
        let request: NSFetchRequest<EmployeeEntity> = EmployeeEntity.fetchRequest()
        return (try? context.fetch(request)) ?? []
    }
    
    func deleteAllEmployees() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = EmployeeEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try? context.execute(deleteRequest)
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save Core Data context:", error.localizedDescription)
            }
        }
    }
    
    //To check employee already exist or not
    func employeeExists(id: Int) -> Bool {
        let fetchRequest: NSFetchRequest<EmployeeEntity> = EmployeeEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        fetchRequest.fetchLimit = 1
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking employee existence:", error)
            return false
        }
    }
    
}

