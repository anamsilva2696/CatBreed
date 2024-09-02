//
//  CatBreed.swift
//  CatBreed
//
//  Created by Admin on 01.09.2024.
//

import Foundation

struct CatBreed: Codable, Identifiable {
    let id: String
    let name: String
    let referenceImageId: String?
    
    enum CodingKeys: String, CodingKey {
            case id
            case name
            case referenceImageId = "reference_image_id"
    }
}

struct CatBreedDetail: Codable {
    let id: String
    let imageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case imageURL = "url"
    }
}
