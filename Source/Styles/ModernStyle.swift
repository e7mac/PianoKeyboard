//
//  ModernStyle.swift
//  PianoKeyboard
//
//  Created by Gary Newby on 25/03/2023.
//

import SwiftUI

public struct ModernStyle: KeyboardStyle {
    public let showLabels: Bool
    public let naturalKeySpace: CGFloat = 2

    public init(showLabels: Bool = false) {
        self.showLabels = showLabels
    }

    public func naturalColor(_ down: Bool) -> Color {
        down ? Color(red: 0.6, green: 0.6, blue: 0.6) : Color(red: 0.9, green: 0.9, blue: 0.9)
    }

    public func sharpFlatColor(_ down: Bool) -> Color {
        down ? Color(red: 0.4, green: 0.4, blue: 0.4) : Color(red: 0.2, green: 0.2, blue: 0.2)
    }

    public func labelColor(_ noteNumber: Int) -> Color {
        Color(hue: Double(noteNumber) / 127.0, saturation: 1, brightness: 0.6)
    }

    public func naturalKeyWidth(_ width: CGFloat, naturalKeyCount: Int, space: CGFloat) -> CGFloat {
        (width - (space * CGFloat(naturalKeyCount - 1))) / CGFloat(naturalKeyCount)
    }

    public func layout(viewModel: PianoKeyboardViewModel, geometry: GeometryProxy) -> some View {
        Canvas { context, size in
            let width = size.width
            let height = size.height
            let xg = geometry.frame(in: .global).origin.x
            let yg = geometry.frame(in: .global).origin.y

            // Natural + sharp/flat keys
            let cornerRadius = width * 0.007
            let naturalWidth = naturalKeyWidth(width, naturalKeyCount: viewModel.naturalKeyCount, space: naturalKeySpace)
            let naturalXIncr = naturalWidth + naturalKeySpace
            var xpos: CGFloat = 0.0

            for (index, key) in viewModel.keys.enumerated() {
                let rect = CGRect(
                    origin: CGPoint(x: xpos, y: 0),
                    size: CGSize(width: naturalWidth, height: height)
                )

                let path = RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: cornerRadius)
                    .path(in: rect)

                let backColor = key.isNatural ? naturalColor(key.touchDown) : sharpFlatColor(key.touchDown)
                context.fill(path, with: .color(backColor))
                
                // Draw highlight overlay if key is highlighted
                if let highlightColor = viewModel.highlightedKeys[key.noteNumber] {
                    let highlightPath = RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: cornerRadius)
                        .path(in: rect)
                    context.fill(highlightPath, with: .color(highlightColor))
                }

                // Handle note names
                if let noteName = viewModel.noteName(for: key.noteNumber) {
                    context.draw(
                        Text(noteName),
                        at: CGPoint(x: rect.origin.x + rect.width / 2.0, y: rect.origin.y + rect.height - 25)
                    )
                } else if showLabels {
                    context.draw(
                        Text(key.name),
                        at: CGPoint(x: rect.origin.x + rect.width / 2.0, y: rect.origin.y + rect.height - 25)
                    )
                }

                xpos += naturalXIncr
                viewModel.keyRects[index] = rect.offsetBy(dx: xg, dy: yg)
            }
        }
    }
}
