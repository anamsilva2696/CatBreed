//
//  FavouriteBreed.swift
//  CatBreed
//
//  Created by Admin on 02.09.2024.
//

import Foundation
struct FavouriteBreed: Codable {
    let id: Int
    let userId: String
    let imageId: String
    let subId: String
    
    enum CodingKeys: String, CodingKey {
            case id
            case userId = "user_id"
            case imageId = "image_id"
            case subId = "sub_id"
    }
}
