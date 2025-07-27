//
//  PianoKeyboardView.swift
//  PianoKeyboard
//
//  Created by Gary Newby on 20/03/2023.
//

import SwiftUI

public struct PianoKeyboardView<T: KeyboardStyle>: View {
    @ObservedObject private var viewModel: PianoKeyboardViewModel
    var style: T

    public init(
        viewModel: PianoKeyboardViewModel = PianoKeyboardViewModel(),
        style: T
    ) {
        self.viewModel = viewModel
        self.style = style
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                style.layout(viewModel: viewModel, geometry: geometry)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.highlightedKeys)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.showNoteNames)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.useFlats)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.showOctaveNumbers)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.showLabelsOnHighlight)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.customNoteNames)
                TouchesView(viewModel: viewModel)
            }
            .background(.black)
        }
    }
}

#Preview {
    let viewModel = PianoKeyboardViewModel()
    viewModel.highlightedKeys = [
        60: .blue,    // C (white key)
        61: .purple,  // C# (black key)
        64: .green,   // E (white key)
        66: .orange,  // F# (black key)
        67: .red      // G (white key)
    ]
    viewModel.showNoteNames = true
    
    return VStack {
        PianoKeyboardView(viewModel: viewModel, style: ClassicStyle())
            .font(.title3.bold())
            .foregroundColor(.blue)
        PianoKeyboardView(viewModel: viewModel, style: ModernStyle())
            .font(.caption2)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background(.black)
}

