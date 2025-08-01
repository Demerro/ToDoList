//
//  NetworkService.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 1.08.25.
//

import Foundation
import os.log

struct NetworkService {
    
    let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
}

extension NetworkService {
    
    func data(for request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        session.dataTask(with: request) { data, response, error in
            if let error {
                if let urlError = error as? URLError {
                    Logger.network.error("Encountered URL error: \(urlError)")
                    completion(.failure(.clientOrTransportSpecific(urlError)))
                } else {
                    Logger.network.error("Encountered error: \(error)")
                    completion(.failure(.clientOrTransport(error)))
                }
                return
            }
            guard let response = response as? HTTPURLResponse else {
                Logger.network.error("Encountered unknown error: response is not HTTPURLResponse")
                completion(.failure(.unknown))
                return
            }
            guard 200...299 ~= response.statusCode else {
                Logger.network.error("Encountered server error with status code: \(response.statusCode)")
                completion(.failure(.server(response)))
                return
            }
            guard let data else {
                Logger.network.error("No data received from server")
                completion(.failure(.noData))
                return
            }
            Logger.network.info("Network request succeeded with status code: \(response.statusCode)")
            completion(.success(data))
        }
    }
}

extension NetworkService {
    
    enum Error: Swift.Error {
        case clientOrTransportSpecific(URLError)
        case clientOrTransport(Swift.Error)
        case server(HTTPURLResponse)
        case noData
        case unknown
    }
}
