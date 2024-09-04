//
//  CatBreedViewModel.swift
//  CatBreed
//
//  Created by Admin on 01.09.2024.
//

import SwiftUI
import CoreData
import Combine

class CatBreedViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var errorMessage: String?

    private var cancellables: Set<AnyCancellable> = []
    private let networkService = NetworkService()
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchBreeds()  // Load initial data from Core Data

    }
    
    func fetchBreeds() {
        networkService.fetchBreeds()
            .flatMap { items -> AnyPublisher<Item, Error> in
                return self.networkService.fetchFavouriteBreeds()
                    .flatMap { favouriteBreeds -> AnyPublisher<Item, Error> in
                        let publishers = items.map { breed -> AnyPublisher<Item, Error> in
                            self.networkService.fetchImageURL(for: breed.referenceImageId ?? "")
                                .map { detail in
                                    // Check if the breed already exists in Core Data
                                    if let existingBreed = self.fetchBreedFromCoreData(by: breed.id) {
                                        // Update the existing breed
                                        let isFavouriteBreed = favouriteBreeds.contains { $0.imageId == breed.referenceImageId }
                                        
                                        self.updateBreed(existingBreed, with: detail, isFavourite: isFavouriteBreed)
                                        return existingBreed
                                    } else {
                                        // Save new breed if it doesn't exist
                                        let isFavouriteBreed = favouriteBreeds.contains { $0.imageId == breed.referenceImageId }
                                        return self.saveBreedsToCoreData(id: breed.id, name: breed.name, imageURL: detail?.absoluteString, referenceImageId: breed.referenceImageId ?? "", isFavourite: isFavouriteBreed, description: breed.description)
                                    }
                                }
                                .eraseToAnyPublisher()
                        }
                        return Publishers.MergeMany(publishers).eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
                self?.fetchBreedsFromCoreData() // Refresh data from Core Data
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }

   
    func saveBreedsToCoreData(id: String, name: String, imageURL: String?, referenceImageId: String, isFavourite: Bool = false, description: String) -> Item {
            let item = Item(context: context)
            item.id = id
            item.name = name
            item.imageURL = imageURL
            item.referenceImageId = referenceImageId
            item.isFavourite = isFavourite
            item.breedDescription = description

        do {
            try context.save()
        } catch {
            errorMessage = "Failed to save data to Core Data: \(error.localizedDescription)"
        }
        
        return item
    }
    
    private func fetchBreedFromCoreData(by id: String) -> Item? {
            let request: NSFetchRequest<Item> = Item.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            request.fetchLimit = 1
            do {
                return try context.fetch(request).first
            } catch {
                errorMessage = "Failed to fetch breed from Core Data: \(error.localizedDescription)"
                return nil
            }
        }
    
    private func fetchBreedsFromCoreData() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.id, ascending: true)]
        
        do {
            items = try context.fetch(request)
        } catch {
            errorMessage = "Failed to fetch data from Core Data: \(error.localizedDescription)"
        }
    }
    private func updateBreed(_ breed: Item, with url: URL?, isFavourite: Bool = false) {
        breed.imageURL = url?.absoluteString
        breed.isFavourite = isFavourite
           
           do {
               try context.save()
           } catch {
               errorMessage = "Failed to update item: \(error.localizedDescription)"
           }
       }
    func toggleFavorite(for breed: Item) {
        if breed.isFavourite {
            // Remove from favorites
            networkService.fetchFavouriteBreeds()
                .flatMap { [weak self] favouriteBreeds -> AnyPublisher<Bool, Error> in
                    guard let self = self else {
                        return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
                    }
                    
                    if let matchingFavourite = favouriteBreeds.first(where: { $0.imageId == breed.referenceImageId }) {
                        return self.networkService.deleteFromFavorites(favoriteId: matchingFavourite.id)
                    } else {
                        return Fail(error: URLError(.fileDoesNotExist)).eraseToAnyPublisher()
                    }
                }
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                }, receiveValue: { [weak self] success in
                    if success {
                        breed.isFavourite.toggle()
                        do {
                            try self?.context.save()
                        } catch {
                            self?.errorMessage = "Failed to update favorite status: \(error.localizedDescription)"
                        }
                        self?.fetchBreedsFromCoreData()  // Refresh the data to reflect changes
                    }
                })
                .store(in: &cancellables)

        } else {
            // Add to favorites
            networkService.addToFavorites(imageId: breed.referenceImageId ?? "")
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                }, receiveValue: { [weak self] success in
                    if success {
                        breed.isFavourite.toggle()
                        do {
                            try self?.context.save()
                        } catch {
                            self?.errorMessage = "Failed to update favorite status: \(error.localizedDescription)"
                        }
                        self?.fetchBreedsFromCoreData()  // Refresh the data to reflect changes
                    }
                })
                .store(in: &cancellables)
        }
    }
}
