//
//  Grid.swift
//  SocialMediaApp
//
//  Created by Jared on 4/8/20.
//  Copyright © 2020 Davidson Family. All rights reserved.
//

import Foundation
import SwiftUI


@available(iOS 13.0, OSX 10.15, *)
public struct QGrid<Data, Content>: View
  where Data : RandomAccessCollection, Content : View, Data.Element : Identifiable {
  private struct QGridIndex : Identifiable { var id: Int }
  
  private let columns: Int
  private let columnsInLandscape: Int
  private let vSpacing: CGFloat
  private let hSpacing: CGFloat
  private let vPadding: CGFloat
  private let hPadding: CGFloat
  private let isScrollable: Bool
  private let showScrollIndicators: Bool
  
  private let data: [Data.Element]
  private let content: (Data.Element) -> Content
  public init(_ data: Data,
              columns: Int,
              columnsInLandscape: Int? = nil,
              vSpacing: CGFloat = 10,
              hSpacing: CGFloat = 10,
              vPadding: CGFloat = 10,
              hPadding: CGFloat = 10,
              isScrollable: Bool = true,
              showScrollIndicators: Bool = false,
              content: @escaping (Data.Element) -> Content) {
    self.data = data.map { $0 }
    self.content = content
    self.columns = max(1, columns)
    self.columnsInLandscape = columnsInLandscape ?? max(1, columns)
    self.vSpacing = vSpacing
    self.hSpacing = hSpacing
    self.vPadding = vPadding
    self.hPadding = hPadding
    self.isScrollable = isScrollable
    self.showScrollIndicators = showScrollIndicators
  }
    
  private var rows: Int {
    data.count / self.cols
  }
  
  private var cols: Int {
    #if os(tvOS)
    return columnsInLandscape
    #elseif os(macOS)
    return columnsInLandscape
    #else
    return UIDevice.current.orientation.isLandscape ? columnsInLandscape : columns
    #endif
  }
  
  public var body : some View {
    GeometryReader { geometry in
      Group {
        if self.isScrollable {
          ScrollView(showsIndicators: self.showScrollIndicators) {
            self.content(using: geometry)
          }
        } else {
          self.content(using: geometry)
        }
      }
      .padding(.horizontal, self.hPadding)
      .padding(.vertical, self.vPadding)
    }
  }
    
  private func rowAtIndex(_ index: Int,
                          geometry: GeometryProxy,
                          isLastRow: Bool = false) -> some View {
    HStack(spacing: self.hSpacing) {
      ForEach((0..<(isLastRow ? data.count % cols : cols))
      .map { QGridIndex(id: $0) }) { column in
        self.content(self.data[index + column.id])
        .frame(width: self.contentWidthFor(geometry))
      }
      if isLastRow { Spacer() }
    }
  }
    
  private func content(using geometry: GeometryProxy) -> some View {
   VStack(spacing: self.vSpacing) {
     ForEach((0..<self.rows).map { QGridIndex(id: $0) }) { row in
       self.rowAtIndex(row.id * self.cols,
                       geometry: geometry)
     }
     // Handle last row
     if (self.data.count % self.cols > 0) {
       self.rowAtIndex(self.cols * self.rows,
                       geometry: geometry,
                       isLastRow: true)
     }
   }
 }
    
  private func contentWidthFor(_ geometry: GeometryProxy) -> CGFloat {
    let hSpacings = hSpacing * (CGFloat(self.cols) - 1)
    let width = geometry.size.width - hSpacings - hPadding * 2
    return width / CGFloat(self.cols)
  }
}
