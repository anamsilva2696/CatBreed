//
//  NetworkService.swift
//  CatBreed
//
//  Created by Admin on 01.09.2024.
//

import Foundation
import Combine

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case tooManyRequests
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .noData:
            return "No data received from the server."
        case .decodingError:
            return "Failed to decode the response."
        case .tooManyRequests:
            return "Too many requests."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

class NetworkService {
    func fetchBreeds() -> AnyPublisher<[CatBreed], Error> {
        guard let url = URL(string: "https://api.thecatapi.com/v1/breeds") else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw NetworkError.noData
                }
                return output.data
            }
            .decode(type: [CatBreed].self, decoder: JSONDecoder())
            .mapError { error -> NetworkError in
                if error is DecodingError {
                    return .decodingError
                }
                return .unknown(error)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchImageURL(for id: String?) -> AnyPublisher<URL?, Error> {
        // Ensure the ID exists and is not empty
        guard let id = id, !id.isEmpty else {
            // If ID is nil or empty, return an empty publisher
            return Just(nil)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        guard let url = URL(string: "https://api.thecatapi.com/v1/images/\(id)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("live_KhpvbwrQm7jVh39CzUtPbTFIE3kBVnFeqRVFJ5fp9balo8civy3p1mLGt0NzVehY", forHTTPHeaderField: "x-api-key")

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }

                // Check for successful status code
                guard httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }

                return output.data
            }
            .decode(type: CatBreedDetail.self, decoder: JSONDecoder()) // Assuming the API returns the image URL as a string
            .map { URL(string: $0.imageURL ?? "https://media.istockphoto.com/id/1162198723/vector/question-mark-icon-flat-vector-illustration-design.jpg?s=612x612&w=0&k=20&c=MJbd8bw2iewJRd8sEkHxyGMgY3__j9MKA8cXvIvL79E=") }
            .eraseToAnyPublisher()
    }
    
    func fetchFavouriteBreeds() -> AnyPublisher<[FavouriteBreed], Error> {
            guard let url = URL(string: "https://api.thecatapi.com/v1/favourites") else {
                return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
            }
        
        print("url \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("live_KhpvbwrQm7jVh39CzUtPbTFlE3kBVnFeqRvFJ5f9baloB0ciyy3p1mLGToNzVehY", forHTTPHeaderField: "x-api-key")

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                if output.data.isEmpty {
                    // Return an empty array if the data is empty
                    return Data("[]".utf8)
                }
                return output.data
            }
            .decode(type: [FavouriteBreed].self, decoder: JSONDecoder())
            .mapError { error -> NetworkError in
                if error is DecodingError {
                    return .decodingError
                }
                return .unknown(error)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func addToFavorites(imageId: String) -> AnyPublisher<Bool, Error> {
            guard let url = URL(string: "https://api.thecatapi.com/v1/favourites") else {
                return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("live_KhpvbwrQm7jVh39CzUtPbTFlE3kBVnFeqRvFJ5f9baloB0ciyy3p1mLGToNzVehY", forHTTPHeaderField: "x-api-key")

            let body: [String: Any] = ["image_id": imageId, "sub_id": "my-user-1234"]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
            return URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { output in
                    guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                    }
                    return true // Return true on success
                }
                .eraseToAnyPublisher()
        }
    
    func deleteFromFavorites(favoriteId: Int) -> AnyPublisher<Bool, Error> {
            guard let url = URL(string: "https://api.thecatapi.com/v1/favourites/\(favoriteId)") else {
                return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
            }

            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("live_KhpvbwrQm7jVh39CzUtPbTFlE3kBVnFeqRvFJ5f9baloB0ciyy3p1mLGToNzVehY", forHTTPHeaderField: "x-api-key")
        
        print("request: \(request)")

            return URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { output in
                    guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                    }
                    return true // Return true on success
                }
                .eraseToAnyPublisher()
        }
    
}
