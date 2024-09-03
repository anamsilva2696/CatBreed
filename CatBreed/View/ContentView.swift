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
    @State private var showFavoritesOnly: Bool = false

    init(viewContext: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: CatBreedViewModel(context: viewContext))
    }
    
    let columns: [GridItem] = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    
    var filteredBreeds: [Item] {
        let breeds = showFavoritesOnly ? viewModel.items.filter { $0.isFavourite } : viewModel.items
        if searchText.isEmpty {
            return breeds
        } else {
            return breeds.filter { breed in
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
                    
                    HStack {
                        Button(action: {
                            showFavoritesOnly = false
                        }) {
                            Text("Show All")
                                .padding()
                                .background(showFavoritesOnly ? Color.gray : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                                        
                        Button(action: {
                            showFavoritesOnly = true
                        }) {
                            Text("Show Favorites")
                                .padding()
                                .background(showFavoritesOnly ? Color.blue : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
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
