//
//  FZSWLabel+ContentView.swift
//  
//
//  Created by Florian Zand on 11.10.22.
//

#if os(macOS)
import SwiftUI

@available(macOS 12.0, *)
extension FZSWLabel {
    struct ContentView: View {
        let properties: Configuration
        @ViewBuilder
        var textItem: some View {
            if let text = properties.text {
                Text(text)
                    .foregroundColor(Color(properties.foregroundColor))
                    .font(properties.textStyle.font.weight(properties.weight.swiftUI))
            }
        }

        @ViewBuilder
        var imageItem: some View {
            if let systemImage = properties.systemImage {
                Image(systemName: systemImage)
                    .font(properties.textStyle.font.weight(properties.weight.swiftUI))
                    .foregroundColor(Color(properties.foregroundColor))
                    .imageScale(properties.imageScale.swiftUI)
            }
        }

        @ViewBuilder
        var background: some View {
            switch properties.background {
            case let .visualEffect(material):
                EffectView(material: material ?? .hudWindow).clipShape(properties.shape.shape)
            case let .blur(material):
                properties.shape.shape.fill(material.swiftUI)
            case let .color(color):
                properties.shape.shape.fill(Color(color))
            case .clear:
                properties.shape.shape.fill(.clear)
            }
        }

        @ViewBuilder
        var items: some View {
            switch properties.iconPlacement {
            case .left, .top:
                imageItem
                textItem
            case .right, .bottom:
                textItem
                imageItem
            }
        }

        @ViewBuilder
        var itemsStack: some View {
            switch properties.iconPlacement {
            case .left, .right:
                HStack(alignment: .center, spacing: properties.iconToTextPadding) {
                    items
                }
            case .top, .bottom:
                VStack(alignment: .center, spacing: properties.iconToTextPadding) {
                    items
                }
            }
        }

        var body: some View {
            itemsStack
                .scaledToFit()
                .padding(EdgeInsets(top: properties.margin, leading: properties.shape == .capsule ? (properties.margin + (properties.margin * 0.25)) : properties.margin, bottom: properties.margin, trailing: properties.shape == .capsule ? (properties.margin + (properties.margin * 0.3)) : properties.margin))
                .background(
                    self.background
                        .shadow(properties.shadow.color?.swiftUI, opacity: properties.shadow.opacity, radius: properties.shadow.radius, x: properties.shadow.x, y: properties.shadow.y)
                )
                .overlay(
                    properties.shape.shape
                        .strokeBorder(Color(properties.foregroundColor), lineWidth: properties.borderWidth)
                )
        }
    }
}

@available(macOS 12.0, *)
struct CircleImage_Previews: PreviewProvider {
    static var previews: some View {
        FZSWLabel.ContentView(properties: .init())
            .padding(.all, 10)
        FZSWLabel.ContentView(properties: .white(.systemBlue))
            .padding(.all, 10)
        FZSWLabel.ContentView(properties: .init().capsule())
            .padding(.all, 10)
        FZSWLabel.ContentView(properties: .tinted(.red))
            .padding(.all, 10)
        FZSWLabel.ContentView(properties: .plain(.systemRed))
            .padding(.all, 10)
    }
}

extension View {
    @ViewBuilder
    func shadow(_ color: Color?, opacity: CGFloat, radius: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        if let color = color?.opacity(opacity) {
            shadow(color: color, radius: radius, x: x, y: y)
        } else {
            self
        }
    }
}
#endif
