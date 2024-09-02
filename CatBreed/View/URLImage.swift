//
//  URLImage.swift
//  CatBreed
//
//  Created by Admin on 02.09.2024.
//

import Foundation
import SwiftUI

struct URLImage: View {
    let url: URL
    @State private var image: UIImage? = nil
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                ProgressView()
                    .onAppear {
                        loadImage()
                    }
            }
        }
        .frame(width: 100, height: 100)
        .clipped()
        .cornerRadius(10)
    }
    
    private func loadImage() {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let uiImage = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                self.image = uiImage
            }
        }
        task.resume()
    }
}
