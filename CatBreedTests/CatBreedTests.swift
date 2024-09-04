//
//  CatBreedTests.swift
//  CatBreedTests
//
//  Created by Admin on 31.08.2024.
//

import XCTest
import Combine
import CoreData
@testable import CatBreed

class CatBreedTests: XCTestCase {
    
    var viewModel: CatBreedViewModel!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let persistentContainer = NSPersistentContainer(name: "CatBreed")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { (description, error) in
            XCTAssertNil(error)
        }
        viewModel = CatBreedViewModel(context: persistentContainer.viewContext)
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        viewModel = nil
        cancellables.removeAll()
        
    }
    
    func testSaveBreedsToCoreData() {
        // Add a breed
        let breed = viewModel.saveBreedsToCoreData(id: "1", name: "Persian", imageURL: "http://example.com/image.jpg", referenceImageId: "123", isFavourite: false, description: "breed")

        // Verify the breed's attributes
        XCTAssertEqual(breed.id, "1")
        XCTAssertEqual(breed.name, "Persian")
        XCTAssertEqual(breed.imageURL, "http://example.com/image.jpg")
        XCTAssertEqual(breed.referenceImageId, "123")
        XCTAssertFalse(breed.isFavourite)
        XCTAssertEqual(breed.breedDescription, "breed")
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
