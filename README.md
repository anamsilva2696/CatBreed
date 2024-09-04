# Cat Breeds App

This app allows users to explore various cat breeds, view details, and mark their favorite breeds, it also has a searchbar where you can search for a specific breed. 

## Features

- Display a list of cat breeds.
- Show breed details with image and breed description.
- Mark breeds as favorites.
- Fetch and display breed data from a remote API.

## Strategies and Decisions

### 1. **Architecture**

- **MVVM (Model-View-ViewModel)**: The app uses the MVVM architecture to separate business logic from the UI.
  
- **Core Data Integration**: Core Data is used to store and manage favorite breeds locally.

### 2. **Networking**

- **URLSession**: For networking, the app uses `URLSession` to make API requests.

### 3. **State Management**

- **@Published and ObservableObject**: The app uses SwiftUI’s `@Published` and `ObservableObject` to ensure that the UI updates reactively when the state of the app (like breeds list or favorites) changes.

### 4. **UI Components**

- **LazyVGrid**: The breeds are displayed using `LazyVGrid`.

- **Navigation and Detail View**: Users can tap on any breed to navigate to a detailed view, where additional information and the favorite toggle button are presented.

### 5. **Unit Testing and UI Testing**

- **Unit Testing**: Unit tests focus on the ViewModel and Core Data logic to ensure that breed data is fetched and stored correctly. I only add one example for unit testing.

### 6. **Error Handling**

- **Network Error Handling**: If a network request fails, an error message is displayed to the user.
