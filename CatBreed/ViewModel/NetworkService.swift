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
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .noData:
            return "No data received from the server."
        case .decodingError:
            return "Failed to decode the response."
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
    
    func fetchImageURL(for id: String) -> AnyPublisher<URL?, Error> {
            guard let url = URL(string: "https://api.thecatapi.com/v1/images/\(id)") else {
                return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
            }
        
        print("url \(url)")

            return URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { output in
                    guard let httpResponse = output.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                    }
                    return output.data
                }
                .decode(type: CatBreedDetail.self, decoder: JSONDecoder()) // Assuming the API returns the image URL as a string
                .map { URL(string: $0.imageURL ?? "https://media.istockphoto.com/id/1162198273/vector/question-mark-icon-flat-vector-illustration-design.jpg?s=612x612&w=0&k=20&c=MJbd8bw2iewJRd8sEkHxyGMgY3__j9MKA8cXvIvLT9E=") }
                .eraseToAnyPublisher()
        }
}
