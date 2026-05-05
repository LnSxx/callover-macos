//
//  NetworkClient.swift
//  CalloverDesktop
//
//  Created by Leonid  on 04.05.26.
//

import Foundation

struct NetworkClient {
    func send<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unexpectedResponse(nil)
        }
        
        if (200...299).contains(httpResponse.statusCode) {
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw NetworkError.unexpectedResponse(error)
            }
        } else {
            do {
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                throw NetworkError.errorResponse(errorResponse)
            } catch let error as NetworkError {
                throw error
            } catch {
                throw NetworkError.unexpectedResponse(error)
            }
        }
    }
    
    func sendEmpty(_ request: URLRequest) async throws {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unexpectedResponse(nil)
        }
        
        if (200...299).contains(httpResponse.statusCode) {
            return
        } else {
            do {
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                throw NetworkError.errorResponse(errorResponse)
            } catch let error as NetworkError {
                throw error
            } catch {
                throw NetworkError.unexpectedResponse(error)
            }
        }
    }
}
