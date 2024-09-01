//
//  CatBreedViewModel.swift
//  CatBreed
//
//  Created by Admin on 01.09.2024.
//

import Foundation
import SwiftUI
import CoreData
import Combine

class ItemViewModel: ObservableObject {
   
    private var cancellables: Set<AnyCancellable> = []
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }
}
