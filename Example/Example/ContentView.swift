//
//  ContentView.swift
//  Example
//
//  Created by Gary Newby on 05/04/2023.
//

import SwiftUI
import PianoKeyboard

struct ContentView: View {
    @ObservedObject private var viewModel: PianoKeyboardViewModel
    @State var styleIndex: Int

    private let audioEngine: AudioEngine

    init(
        pianoKeyboardViewModel: PianoKeyboardViewModel = PianoKeyboardViewModel(), 
        audioEngine: AudioEngine = AudioEngine(),
        styleIndex: Int = 0
    ) {
        self.viewModel = pianoKeyboardViewModel
        self.styleIndex = styleIndex
        self.audioEngine = audioEngine
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(
                        LinearGradient(gradient: Gradient(stops: [
                            Gradient.Stop(color: Color(white: 0.2), location: 0),
                                Gradient.Stop(color: Color(white: 0.3), location: 0.96),
                                Gradient.Stop(color: .black, location: 1),
                            ]), startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(radius: 8)

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 10) {
                        Stepper("Keys: \(viewModel.numberOfKeys)") {
                            viewModel.numberOfKeys += 1
                        } onDecrement: {
                            viewModel.numberOfKeys -= 1
                        }
                        .font(.subheadline.bold())
                        .foregroundColor(.white)

                        Stepper("Style:", value: $styleIndex, in: 0...2)
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                            .tint(.blue)

                    }
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 0))
                    .frame(width: 200)


                    VStack {
                        Toggle("Latch:", isOn: $viewModel.latch)
                            .font(.subheadline.bold())
                            .foregroundColor(.white)

                        HStack {
                            Text("Notes:")
                                .font(.subheadline.bold())
                                .foregroundStyle(.white)
                            Spacer()
                            Text("\(viewModel.keysPressed.joined(separator: ", "))")
                                .font(.subheadline.bold())
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 0))
                    .frame(width: 200)

                    Spacer()

                    Text("PianoKeyboard")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(30)
                }
            }
            .frame(height: UIScreen.main.bounds.height * 0.45)

            if styleIndex == 0 {
                PianoKeyboardView(viewModel: viewModel, style: ClassicStyle(sfKeyWidthMultiplier: 0.55))
                    .frame(height: UIScreen.main.bounds.height * 0.55)
            } else if styleIndex == 1 {
                PianoKeyboardView(viewModel: viewModel, style: ModernStyle())
                    .frame(height: UIScreen.main.bounds.height * 0.55)
            } else if styleIndex == 2{
                PianoKeyboardView(viewModel: viewModel, style: CustomStyle(showLabels: true))
                    .frame(height: UIScreen.main.bounds.height * 0.55)
            }
        }
        .background(.black)
        .onAppear() {
            viewModel.delegate = audioEngine
            audioEngine.start()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView()
        }
        .navigationViewStyle(.stack)
        .previewInterfaceOrientation(.landscapeLeft)
    }
}
