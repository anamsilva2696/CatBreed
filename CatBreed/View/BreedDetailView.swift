//
//  BreedDetailView.swift
//  CatBreed
//
//  Created by Admin on 03.09.2024.
//

import SwiftUI
import CoreData

struct BreedDetailView: View {
    @ObservedObject var viewModel: CatBreedViewModel
    var breed: Item
    
    var body: some View {
        VStack {
            if let imageURLString = breed.imageURL, let imageURL = URL(string: imageURLString) {
                URLImage(url: imageURL)
                    .scaledToFit()
                    .frame(width: 100, height: 100) // Sets the frame size
                    .cornerRadius(10) // Optional: Adds rounded corners
            }
            HStack {
                Text(breed.name ?? "Unknown Name")
                    .font(.caption)
                    .lineLimit(1)
                
                Button(action: {
                    viewModel.toggleFavorite(for: breed)
                }) {
                    Image(systemName: breed.isFavourite ? "star.fill" : "star")
                    .foregroundColor(breed.isFavourite ? .yellow : .gray)
                    .padding(5)
                }.accessibilityIdentifier("favoriteButton")

            }
            Text(breed.breedDescription ?? "No Breed Description")
                .font(.body)
                .padding()
        
        }
        .navigationTitle(breed.name ?? "Unknown Breed")
    }
}
