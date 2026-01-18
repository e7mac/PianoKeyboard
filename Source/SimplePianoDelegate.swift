//
//  SimplePianoDelegate.swift
//  PianoKeyboard
//
//  Created by Claude Code on 2026-01-18.
//

import Foundation

/// A simple, reusable delegate for handling piano key events with closures.
/// Use this when you just need basic key press/release handling without
/// creating a custom delegate class.
///
/// Example usage:
/// ```swift
/// let delegate = SimplePianoDelegate { keyNumber in
///     midiPlayer.playNote(keyNumber)
/// }
/// pianoViewModel.delegate = delegate
/// ```
public class SimplePianoDelegate: PianoKeyboardDelegate {
    /// Called when a key is pressed
    public var onKeyDown: ((Int) -> Void)?

    /// Called when a key is released
    public var onKeyUp: ((Int) -> Void)?

    /// Creates a delegate with optional key press/release handlers
    /// - Parameters:
    ///   - onKeyDown: Called when a key is pressed with the MIDI note number
    ///   - onKeyUp: Called when a key is released with the MIDI note number
    public init(onKeyDown: ((Int) -> Void)? = nil, onKeyUp: ((Int) -> Void)? = nil) {
        self.onKeyDown = onKeyDown
        self.onKeyUp = onKeyUp
    }

    public func pianoKeyDown(_ keyNumber: Int) {
        onKeyDown?(keyNumber)
    }

    public func pianoKeyUp(_ keyNumber: Int) {
        onKeyUp?(keyNumber)
    }
}
