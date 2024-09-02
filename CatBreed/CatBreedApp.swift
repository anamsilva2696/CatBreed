//
//  CatBreedApp.swift
//  CatBreed
//
//  Created by Admin on 31.08.2024.
//

import SwiftUI

@main
struct CatBreedApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView(viewContext: persistenceController.container.viewContext)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
