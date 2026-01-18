//
//  PianoKeyboardViewModel.swift
//  PianoKeyboard
//
//  Created by Gary Newby on 20/03/2023.
//

import SwiftUI

public protocol PianoKeyboardDelegate: AnyObject {
    func pianoKeyUp(_ keyNumber: Int)
    func pianoKeyDown(_ keyNumber: Int)
}

public class PianoKeyboardViewModel: ObservableObject {

    @Published public var keys: [PianoKeyViewModel] = []
    @Published public var keysPressed: [String] = []
    @Published public var highlightedKeys: [Int: Color] = [:]
    @Published public var labelColors: [Int: Color] = [:]
    @Published public var showNoteNames: Bool = false
    @Published public var useFlats: Bool = false
    @Published public var showOctaveNumbers: Bool = false
    @Published public var showLabelsOnHighlight: Bool = false
    @Published public var customNoteNames: [Int: String] = [:]
    @Published public var latch = false {
        didSet { reset() }
    }

    /// Optional closure that provides a highlight color for touched keys.
    /// When set, keys will automatically highlight with the returned color on touch.
    /// Return nil for keys that should use default touch behavior.
    public var touchHighlightColorProvider: ((Int) -> Color?)? = nil

    /// Optional closure that provides a label color for keys.
    /// Used to restore label color when touch ends.
    public var labelColorProvider: ((Int) -> Color?)? = nil

    public var noteOffset: Int {
        didSet { configureKeys() }
    }
    public var keyRects: [CGRect] = []
    public weak var delegate: PianoKeyboardDelegate?
    public var numberOfKeys = 18 {
        didSet { configureKeys() }
    }
    public var naturalKeyCount: Int {
        keys.filter { $0.isNatural }.count
    }

    var touches: [CGPoint] = [] {
        didSet { updateKeys() }
    }

    public init(noteOffset: Int = 60) {
        self.noteOffset = noteOffset
        configureKeys()
    }

    func naturalKeyWidth(_ width: CGFloat, space: CGFloat) -> CGFloat {
        (width - (space * CGFloat(naturalKeyCount - 1))) / CGFloat(naturalKeyCount)
    }

    private func configureKeys() {
        keys = Array(repeating: PianoKeyViewModel(keyIndex: 0, noteOffset: noteOffset), count: numberOfKeys)
        keyRects = Array(repeating: .zero, count: numberOfKeys)

        for i in 0..<numberOfKeys {
            keys[i] = PianoKeyViewModel(keyIndex: i, noteOffset: noteOffset)
        }
    }

    private func updateKeys() {
        var keyDownAt = Array(repeating: false, count: numberOfKeys)

        for touch in touches {
            if let index = getKeyContaining(touch) {
                keyDownAt[index] = true
            }
        }

        for index in 0..<numberOfKeys {
            let noteNumber = keys[index].noteNumber

            if keys[index].touchDown != keyDownAt[index] {
                if latch {
                    if keyDownAt[index] {
                        let keyLatched = keys[index].latched
                        if keyLatched {
                            keyUp(noteNumber)
                            keys[index].latched = false
                            keys[index].touchDown = false
                        } else {
                            keyDown(noteNumber)
                            keys[index].latched = true
                            keys[index].touchDown = true
                        }
                    }

                } else {
                    if keyDownAt[index] {
                        keyDown(noteNumber)
                    } else {
                        keyUp(noteNumber)
                    }
                    keys[index].touchDown = keyDownAt[index]
                }
            } else {
                if keys[index].touchDown && keyDownAt[index] && keys[index].latched {
                    keyUp(noteNumber)
                    keys[index].latched = false
                    keys[index].touchDown = false
                }
            }
        }
    }

    private func keyDown(_ number: Int) {
        // Apply touch highlight if provider exists
        if let provider = touchHighlightColorProvider, let color = provider(number) {
            highlightedKeys[number] = color
            labelColors[number] = .white
        }
        keysPressed.append(Note.name(for: number))
        delegate?.pianoKeyDown(number)
    }

    private func keyUp(_ number: Int) {
        // Remove touch highlight and restore label color
        if touchHighlightColorProvider != nil {
            highlightedKeys.removeValue(forKey: number)
            if let provider = labelColorProvider, let color = provider(number) {
                labelColors[number] = color
            }
        }
        let note = Note.name(for: number)
        guard let index = keysPressed.firstIndex(of: note) else {
            return
        }
        keysPressed.remove(at: index)
        delegate?.pianoKeyUp(number)
    }

    private func getKeyContaining(_ point: CGPoint) -> Int? {
        var keyNum: Int?
        for index in 0..<numberOfKeys {
            if keyRects[index].contains(point) {
                keyNum = index
                if !keys[index].isNatural {
                    break
                }
            }
        }
        return keyNum
    }

    private func reset() {
        for i in 0..<numberOfKeys {
            keys[i].touchDown = false
            keys[i].latched = false
            keyUp(keys[i].noteNumber)
        }
    }
    
    public func noteName(for noteNumber: Int) -> String? {
        // Check if we should show labels only on highlighted keys
        if showLabelsOnHighlight && highlightedKeys[noteNumber] == nil {
            return nil
        }

        // Priority: custom names > note names > none
        if let customName = customNoteNames[noteNumber] {
            return customName
        } else if showNoteNames {
            return Note.name(for: noteNumber, useFlats: useFlats, showOctaveNumber: showOctaveNumbers)
        }
        return nil
    }

    /// Sets scale degree labels and colors across visible octaves
    /// - Parameters:
    ///   - key: The musical key (e.g., "C", "F#", "Bb")
    ///   - degrees: Which scale degrees to label (default: all 1-7)
    ///   - octaves: Range of octaves to apply labels to (default: 4...6)
    ///   - colorProvider: Optional closure to provide color for each degree
    public func setScaleDegreeLabels(
        key: String,
        degrees: [Int] = [1, 2, 3, 4, 5, 6, 7],
        octaves: ClosedRange<Int> = 4...6,
        colorProvider: ((Int) -> Color)? = nil
    ) {
        let rootNote = Note.value(for: key)
        var labels: [Int: String] = [:]
        var colors: [Int: Color] = [:]

        for octave in octaves {
            for degree in degrees where degree >= 1 && degree <= 7 {
                let interval = Note.majorScaleIntervals[degree - 1]
                let midiNote = (rootNote + interval) % 12 + (octave * 12)
                labels[midiNote] = "\(degree)"
                if let color = colorProvider?(degree) {
                    colors[midiNote] = color
                }
            }
        }

        customNoteNames = labels
        if !colors.isEmpty {
            labelColors = colors
        }
    }

    /// Sets key highlighting for scale degrees across visible octaves
    /// - Parameters:
    ///   - key: The musical key (e.g., "C", "F#", "Bb")
    ///   - degrees: Which scale degrees to highlight (default: all 1-7)
    ///   - octaves: Range of octaves to apply highlights to (default: 4...6)
    ///   - colorProvider: Closure providing color for each degree (1-7)
    public func setScaleHighlighting(
        key: String,
        degrees: [Int] = [1, 2, 3, 4, 5, 6, 7],
        octaves: ClosedRange<Int> = 4...6,
        colorProvider: @escaping (Int) -> Color
    ) {
        let rootNote = Note.value(for: key)
        var highlights: [Int: Color] = [:]

        for octave in octaves {
            for degree in degrees where degree >= 1 && degree <= 7 {
                let interval = Note.majorScaleIntervals[degree - 1]
                let midiNote = (rootNote + interval) % 12 + (octave * 12)
                highlights[midiNote] = colorProvider(degree)
            }
        }

        highlightedKeys = highlights
    }

    /// Configures the piano for scale display with both highlighting and labels
    /// - Parameters:
    ///   - key: The musical key (e.g., "C", "F#", "Bb")
    ///   - degrees: Which scale degrees to show (default: all 1-7)
    ///   - octaves: Range of octaves to apply to (default: 4...6)
    ///   - highlightColorProvider: Optional closure for key highlight colors
    ///   - labelColorProvider: Optional closure for label colors
    ///   - showDegreeLabels: Whether to show degree numbers as labels (default: true)
    public func configureForScale(
        key: String,
        degrees: [Int] = [1, 2, 3, 4, 5, 6, 7],
        octaves: ClosedRange<Int> = 4...6,
        highlightColorProvider: ((Int) -> Color)? = nil,
        labelColorProvider: ((Int) -> Color)? = nil,
        showDegreeLabels: Bool = true
    ) {
        if let highlightProvider = highlightColorProvider {
            setScaleHighlighting(key: key, degrees: degrees, octaves: octaves, colorProvider: highlightProvider)
        }
        if showDegreeLabels {
            setScaleDegreeLabels(key: key, degrees: degrees, octaves: octaves, colorProvider: labelColorProvider)
        }
    }
}
