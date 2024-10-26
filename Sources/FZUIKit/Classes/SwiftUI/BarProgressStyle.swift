//
//  BarProgressStyle.swift
//
//
//  Created by Florian Zand on 18.07.23.
//

import FZSwiftUtils
import SwiftUI

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public struct BarProgressStyle: ProgressViewStyle {
    let color: Color
    let backgroundColor: Color
    let cornerRadius: CGFloat

    public init(color: Color = .accentColor, backgroundColor: Color = .gray, cornerRadius: CGFloat = 10.0) {
        self.color = color
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
    }

    public func makeBody(configuration: Configuration) -> some View {
        let progress = configuration.fractionCompleted ?? 0.0
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundColor)
                .frame(height: geometry.size.height)
                .frame(width: geometry.size.width)
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(color)
                        .frame(width: geometry.size.width * progress)
                }
        }
    }
}

public struct BarProgressLabelStyle: ProgressViewStyle {
    let backgroundColor: Color
    let color: Color
    let font: Font
    let textColor: Color
    let unit: String
    let range: ClosedRange<Double>
    let alignment: Alignment
    let cornerRadius: CGFloat
    let padding: CGFloat

    public init(color: Color = .accentColor, backgroundColor: Color = .gray, font: Font = .headline, textColor: Color = .white, alignment: Alignment = .leading, unit: String = "%", range: ClosedRange<Double> = 0 ... 100, padding: CGFloat = 6.0, cornerRadius: CGFloat = 6.0) {
        self.color = color
        self.backgroundColor = backgroundColor
        self.font = font
        self.textColor = textColor
        self.alignment = alignment
        self.unit = unit
        self.range = range
        self.padding = padding
        self.cornerRadius = cornerRadius
    }

    var numberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter
    }

    public func makeBody(configuration: Configuration) -> some View {
        let progress = configuration.fractionCompleted ?? 0.0
        let progressValue = range.lowerBound + ((range.upperBound - range.lowerBound) * progress).rounded(toPlaces: 2)
        let progressString = numberFormatter.string(from: progressValue) ?? String(format: "%.2f", progressValue)
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundColor)
                .frame(height: geometry.size.height)
                .frame(width: geometry.size.width)
                .overlay(
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(color)
                            .frame(width: geometry.size.width * progress)
                        Text("\(progressString) \(unit) ")
                            .font(font)
                            .foregroundColor(textColor)
                            .frame(maxWidth: .infinity, alignment: alignment)
                            .padding(.init(top: 0, leading: padding, bottom: 0, trailing: padding))
                    }
                )
        }
    }
}
