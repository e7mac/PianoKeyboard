//
//  ClassicStyle.swift
//  PianoKeyboard
//
//  Created by Gary Newby on 25/03/2023.
//

import SwiftUI

public struct ClassicStyle: KeyboardStyle {
    let sfKeyWidthMultiplier: CGFloat
    let sfKeyHeightMultiplier: CGFloat
    let sfKeyInsetMultiplier: CGFloat
    let cornerRadiusMultiplier: CGFloat
    let labelFont: Font
    let labelColor: Color

    public let showLabels: Bool
    public let naturalKeySpace: CGFloat

    public init(
        sfKeyWidthMultiplier: CGFloat = 0.65,
        sfKeyHeightMultiplier: CGFloat = 0.60,
        sfKeyInsetMultiplier: CGFloat = 0.15,
        cornerRadiusMultiplier: CGFloat = 0.008,
        naturalKeySpace: CGFloat = 3,
        labelFont: Font = .title3.bold(),
        labelColor: Color = .gray,
        showLabels: Bool = true
    ) {
        self.sfKeyWidthMultiplier = sfKeyWidthMultiplier
        self.sfKeyHeightMultiplier = sfKeyHeightMultiplier
        self.sfKeyInsetMultiplier = sfKeyInsetMultiplier
        self.cornerRadiusMultiplier = cornerRadiusMultiplier
        self.naturalKeySpace = naturalKeySpace
        self.labelFont = labelFont
        self.labelColor = labelColor
        self.showLabels = showLabels
    }

    public func naturalColor(_ down: Bool) -> Color {
        down ? Color(red: 0.6, green: 0.6, blue: 0.6) : Color(red: 0.9, green: 0.9, blue: 0.9)
    }

    public func sharpFlatColor(_ down: Bool) -> Color {
        down ? Color(red: 0.4, green: 0.4, blue: 0.4) : Color(red: 0.5, green: 0.5, blue: 0.5)
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

            // Natural keys
            let cornerRadius = width * cornerRadiusMultiplier
            let naturalWidth = naturalKeyWidth(width, naturalKeyCount: viewModel.naturalKeyCount, space: naturalKeySpace)
            let naturalXIncr = naturalWidth + naturalKeySpace
            var xpos: CGFloat = 0.0

            for (index, key) in viewModel.keys.enumerated() {
                guard key.isNatural else { continue }

                let rect = CGRect(
                    origin: CGPoint(x: xpos, y: 0),
                    size: CGSize(width: naturalWidth, height: height)
                )

                let path = RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: cornerRadius)
                    .path(in: rect)

                let gradient = Gradient(colors: [
                    naturalColor(key.touchDown),
                    Color(red: 1, green: 1, blue: 1),
                ])

                context.fill(path, with: .linearGradient(
                    gradient,
                    startPoint: CGPoint(x: rect.width / 2.0, y: 0),
                    endPoint: CGPoint(x: rect.width / 2.0, y: rect.height)
                ))
                
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
                        at: CGPoint(x: rect.origin.x + rect.width / 2.0, y: rect.origin.y + rect.height * 0.85)
                    )
                } else if showLabels {
                    let color = key.name.prefix(1) == "C" ? labelColor : .clear
                    context.draw(
                        Text(key.name).font(labelFont).foregroundColor(color),
                        at: CGPoint(x: rect.origin.x + rect.width / 2.0, y: rect.origin.y + rect.height * 0.88)
                    )
                }

                xpos += naturalXIncr

                viewModel.keyRects[index] = rect.offsetBy(dx: xg, dy: yg)
            }

            // Sharps/Flat keys
            let sfKeyWidth = naturalWidth * sfKeyWidthMultiplier
            let sfKeyHeight = height * sfKeyHeightMultiplier
            xpos = 0.0

            for (index, key) in viewModel.keys.enumerated() {
                if key.isNatural {
                    xpos += naturalXIncr
                    continue
                }

                let rect = CGRect(
                    origin: CGPoint(x: xpos - (sfKeyWidth / 2.0), y: 0),
                    size: CGSize(width: sfKeyWidth, height: sfKeyHeight)
                )

                let path = RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: cornerRadius)
                    .path(in: rect)

                context.fill(path, with: .color(Color(red: 0.1, green: 0.1, blue: 0.1)))

                let inset = sfKeyWidth * sfKeyInsetMultiplier
                let insetRect = rect
                    .insetBy(dx: inset, dy: inset)
                    .offsetBy(dx: 0, dy: key.touchDown ? -(inset) : -(inset * 1.5))

                let pathInset = RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: cornerRadius / 2.0)
                    .path(in: insetRect)

                let gradientInset = Gradient(colors: [
                    Color(red: 0.3, green: 0.3, blue: 0.3),
                    sharpFlatColor(key.touchDown),
                ])
                
                context.fill(pathInset, with: .linearGradient(
                    gradientInset,
                    startPoint: CGPoint(x: rect.width / 2.0, y: 0),
                    endPoint: CGPoint(x: rect.width / 2.0, y: rect.height)
                ))
                
                // Draw highlight overlay if key is highlighted
                if let highlightColor = viewModel.highlightedKeys[key.noteNumber] {
                    let highlightPath = RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: cornerRadius / 2.0)
                        .path(in: insetRect)
                    context.fill(highlightPath, with: .color(highlightColor))
                }
                
                // Draw note names on black keys
                if let noteName = viewModel.noteName(for: key.noteNumber) {
                    context.draw(
                        Text(noteName),
                        at: CGPoint(x: rect.origin.x + rect.width / 2.0, y: rect.origin.y + rect.height * 0.75)
                    )
                }

                viewModel.keyRects[index] = rect.offsetBy(dx: xg, dy: yg)
            }
        }
    }
}
