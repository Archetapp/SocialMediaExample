//
//  MediaView.swift
//  SocialMediaApp
//
//  Created by Jared on 4/7/20.
//  Copyright © 2020 Davidson Family. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit
import Photos

struct QConstants {
  static let showDesigner = false
  static let columnsMax = 8
  static let vSpacingMaxToGeometryRatio: CGFloat = 0.5 // 50%
  static let vPaddingMaxToGeometryRatio: CGFloat = 0.3 // 30%
  static let hPaddingMaxToGeometryRatio: CGFloat = 0.3 // 30%
}

struct MediaView : View {
    var images: PHFetchResult<PHAsset>!
    let options = PHFetchOptions()
    @State var columns: CGFloat = 3.0
    @State var vSpacing: CGFloat = 0.0
    @State var hSpacing: CGFloat = 0.0
    @State var vPadding: CGFloat = 0.0
    @State var hPadding: CGFloat = 0.0
    
    init() {
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        images = PHAsset.fetchAssets(with: .image, options: options)
    }
    
    var body: some View {
      GeometryReader { geometry in
        ZStack {
          VStack {
            Text("Pick An Image").font(Font.system(size: 30, weight: .bold, design: .rounded))
            Spacer()
            self.gridView(geometry).frame(height: 500, alignment: .bottom).cornerRadius(10).shadow(color: .gray, radius: 5, x: 0, y: 0)
            }
        }
      }
    }

    var Storage = ImageStorage()
    var imageManager = PHCachingImageManager()
    
    private func gridView(_ geometry: GeometryProxy) -> some View {
        
        QGrid(Storage.images,
              columns: Int(self.columns),
              columnsInLandscape: Int(self.columns),
              vSpacing: min(self.vSpacing, self.vSpacingMax(geometry)),
              hSpacing: max(min(self.hSpacing, self.hSpacingMax(geometry)), 0.0),
              vPadding: min(self.vPadding, self.vPaddingMax(geometry)),
              hPadding: max(min(self.hPadding, self.hPaddingMax(geometry)), 0.0)) { image in
                GridCell(imageTemp: image.image).aspectRatio(1.0, contentMode: .fill).clipped()

        }
    }
    
    
    private func vSpacingMax(_ geometry: GeometryProxy) -> CGFloat {
      return geometry.size.height * QConstants.vSpacingMaxToGeometryRatio
    }
    
    private func hSpacingMax(_ geometry: GeometryProxy) -> CGFloat {
      return max(geometry.size.width/self.columns - 2 * hPadding, 1.0)
    }
    
    private func vPaddingMax(_ geometry: GeometryProxy) -> CGFloat {
      return geometry.size.height * QConstants.vPaddingMaxToGeometryRatio
    }
    
    private func hPaddingMax(_ geometry: GeometryProxy) -> CGFloat {
      return geometry.size.width * QConstants.hPaddingMaxToGeometryRatio
    }
    
    private var backgroundGradient: LinearGradient {
      let gradient = Gradient(colors: [
        Color(red: 192/255.0, green: 192/255.0, blue: 192/255.0),
        Color(red: 50/255.0, green: 50/255.0, blue: 50/255.0)
      ])
      return LinearGradient(gradient: gradient,
                            startPoint: .top,
                            endPoint: .bottom)
    }

}

struct ImageStorage {
    var imageManager = PHImageManager.default()
    
    let requestOptions = PHImageRequestOptions()
    
    var images = [imageIdentifiable]()
    init() {
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .fastFormat
        
        let fetchOptions = PHFetchOptions()
        
        let fetchResult : PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        if fetchResult.count > 0 {
            for i in 0 ..< fetchResult.count {
                let image = fetchResult.object(at: i)
                let identifier = imageIdentifiable(id: UUID(), image: image)
                images.append(identifier)
            }
        } else {
            
        }
    }
}


struct imageIdentifiable : Identifiable {
    var id = UUID()
    var image = PHAsset()
}

struct GridCell: View {
    var image : PHAsset
    var imageManager = PHImageManager()
    @State var imageLoaded : Bool = false
    init(imageTemp : PHAsset) {
        image = imageTemp
    }
    var imageVIEW2 = UIImageView()
    
    @State var uiImage : UIImage?
    func loadImageBasedOnPHAsset(completion : @escaping(_ resultado : UIImage?) -> ()){
        self.imageManager.requestImage(for: image, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: nil) {
               result, info in
           completion(result)
        }
    }
    @State var imageView = Image(uiImage: #imageLiteral(resourceName: "AddBtn.png"))
    var body: some View {
        GeometryReader { proxy in
            VStack {
                self.imageView.resizable().scaledToFill().frame(width: proxy.size.width, height: proxy.size.height, alignment: .center).onAppear {
                    self.loadImageBasedOnPHAsset(completion: {
                        result in
                        self.imageView = Image(uiImage: result ?? #imageLiteral(resourceName: "AddBtn.png"))
                    })
                }
            }
        }
    }
}

extension PHAsset {
    
}
