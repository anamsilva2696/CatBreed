//
//  ContentView.swift
//  CatBreed
//
//  Created by Admin on 31.08.2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: CatBreedViewModel
    @State private var searchText: String = ""

    init(viewContext: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: CatBreedViewModel(context: viewContext))
    }
    
    let columns: [GridItem] = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    
    var filteredBreeds: [Item] {
            if searchText.isEmpty {
                return viewModel.items
            } else {
                return viewModel.items.filter { breed in
                    breed.name?.lowercased().contains(searchText.lowercased()) ?? false
                }
            }
        }
    
        var body: some View {
            NavigationView {
                VStack {
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Search Breeds", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.vertical)
                    }
                    .padding(.horizontal)
                    
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(filteredBreeds, id: \.self) { item in
                                NavigationLink(destination: BreedDetailView(viewModel: viewModel, breed: item)) {
                                    VStack {
                                        if let imageURLString = item.imageURL, let imageURL = URL(string: imageURLString) {
                                            URLImage(url: imageURL)
                                                .frame(width: 100, height: 100)
                                                .clipped()
                                                .cornerRadius(10)
                                        }
                                        HStack {
                                            Text(item.name ?? "Unknown Name")
                                                .font(.caption)
                                                .lineLimit(1)
                                            
                                            Button(action: {
                                                viewModel.toggleFavorite(for: item)
                                            }) {
                                                Image(systemName: item.isFavourite ? "star.fill" : "star")
                                                .foregroundColor(item.isFavourite ? .yellow : .gray)
                                                .padding(5)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .navigationTitle("Cats Breed")
            }
        }
    }
