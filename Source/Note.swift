//
//  Notes.swift
//  PianoKeyboard
//
//  Created by Gary Newby on 20/03/2023.
//

import Foundation

public struct Note {
    static let sharps = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    static let flats  = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]

    /// Major scale intervals in semitones from root
    public static let majorScaleIntervals = [0, 2, 4, 5, 7, 9, 11]

    /// Convert a key name (e.g., "C", "F#", "Bb") to its semitone value (0-11)
    public static func value(for keyName: String) -> Int {
        let noteValues: [String: Int] = [
            "C": 0, "C#": 1, "Db": 1, "D": 2, "D#": 3, "Eb": 3,
            "E": 4, "F": 5, "F#": 6, "Gb": 6, "G": 7, "G#": 8,
            "Ab": 8, "A": 9, "A#": 10, "Bb": 10, "B": 11
        ]
        return noteValues[keyName] ?? 0
    }

    /// Get the scale degree (1-7) for a MIDI note in a given key, or nil if not in major scale
    public static func scaleDegree(for midiNote: Int, inKey keyName: String) -> Int? {
        let rootNote = value(for: keyName)
        let noteInScale = ((midiNote - rootNote) % 12 + 12) % 12
        if let index = majorScaleIntervals.firstIndex(of: noteInScale) {
            return index + 1
        }
        return nil
    }

    public static func midiNumber(for name: String) -> Int {
        let note: Substring
        let octave: Int
        if name.contains("-") {
            note = name.dropLast(2)
            octave = name.count > 3 ? Int(name.dropFirst(2)) ?? 0 : Int(name.dropFirst(1)) ?? 0
        } else {
            note = name.dropLast()
            octave = name.count > 2 ? Int(name.dropFirst(2)) ?? 0 : Int(name.dropFirst(1)) ?? 0
        }
        let offset = [sharps.firstIndex(of: String(note)),flats.firstIndex(of: String(note))].compactMap { $0 }.first
        return (12 + (octave * 12)) + (offset ?? 0)
    }

    public static func name(for midiNumber: Int, preferSharps: Bool = false) -> String {
        let offset = midiNumber % 12
        let octave = ((midiNumber - offset) / 12) - 1
        let note = preferSharps ? sharps[offset] : flats[offset]
        return note + String(octave)
    }
    
    public static func name(for midiNumber: Int, useFlats: Bool = false, showOctaveNumber: Bool = true) -> String {
        let offset = midiNumber % 12
        let octave = ((midiNumber - offset) / 12) - 1
        let note = useFlats ? flats[offset] : sharps[offset]
        return showOctaveNumber ? note + String(octave) : note
    }
}
