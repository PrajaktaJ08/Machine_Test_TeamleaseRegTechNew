//
//  APIManager.swift
//  Machine_Test_TeamleaseRegTech
//
//  Created by Prajakta Prakash Jadhav on 16/12/25.
//

import Foundation

enum DataError: Error {
    case invalidURL
    case invalidResponse(Int)
    case invalidData
    case network(Error?)
    case rateLimited
}

final class APIManager {
    static let shared = APIManager()
    
    private init() {
        
    }
    
    func fetchEmployeeData(completionHandler: @escaping (Result<EmployeeListModel, DataError>) -> Void) {

        guard let url = URL(string: APIConstants.employeeURL) else {
            completionHandler(.failure(.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in

            if let error = error {
                completionHandler(.failure(.network(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completionHandler(.failure(.invalidResponse(-1)))
                return
            }

            switch httpResponse.statusCode {
            case 200...299:
                break
            case 429:
                completionHandler(.failure(.rateLimited))
                return
            default:
                completionHandler(.failure(.invalidResponse(httpResponse.statusCode)))
                return
            }

            guard let data = data else {
                completionHandler(.failure(.invalidData))
                return
            }

            do {
                let responseData = try JSONDecoder().decode(EmployeeListModel.self, from: data)
                completionHandler(.success(responseData))
            } catch {
                completionHandler(.failure(.network(error)))
            }

        }.resume()
    }
}
