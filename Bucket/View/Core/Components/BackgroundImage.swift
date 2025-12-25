//
//  BackgroundImage.swift
//  Bucket
//
//  Created by Sergio Sánchez Sánchez on 9/11/24.
//

import SwiftUI

struct BackgroundImage: View {
    let imageName: String

    var body: some View {
        GeometryReader { reader in
            ZStack {
                if UIImage(named: imageName) != nil {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                } else {
                    LinearGradient(
                        colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .edgesIgnoringSafeArea(.all)
                }
                Color.black
                    .opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
            }.frame(width: reader.size.width, height: reader.size.height, alignment: .center)
        }
    }
}
