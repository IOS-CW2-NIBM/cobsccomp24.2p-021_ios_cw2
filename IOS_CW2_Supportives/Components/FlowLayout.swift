// FlowLayout.swift
// IOS_CW2_Supportives
// Generic wrapping flow layout — used for service/category chip rows.

import SwiftUI
import Combine


/// Wraps items left-to-right, breaking to the next line when the row is full.
struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    let items: Data
    let spacing: CGFloat
    let content: (Data.Element) -> Content

    init(items: Data,
         spacing: CGFloat = 8,
         @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.items   = items
        self.spacing = spacing
        self.content = content
    }

    @State private var totalHeight: CGFloat = 0

    var body: some View {
        var width:  CGFloat = 0
        var row:    Int     = 0
        var rowH:   CGFloat = 0
        var totalH: CGFloat = 0

        return GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                ForEach(items) { item in
                    content(item)
                        .fixedSize()
                        .alignmentGuide(.leading) { d in
                            if abs(width - d.width) > geo.size.width {
                                width = 0
                                row  += 1
                                totalH += rowH
                                rowH  = 0
                            }
                            let result = width
                            if item.id as AnyObject === items.last?.id as AnyObject {
                                width = 0; row = 0
                            } else {
                                width -= d.width + spacing
                            }
                            rowH = max(rowH, d.height)
                            return result
                        }
                        .alignmentGuide(.top) { _ in
                            let result = -CGFloat(row) * (rowH + spacing)
                            if item.id as AnyObject === items.last?.id as AnyObject {
                                totalH += rowH
                                self.totalHeight = totalH
                                totalH = 0; rowH = 0
                            }
                            return result
                        }
                }
            }
        }
        .frame(height: totalHeight)
    }
}
