//
//  Notes.swift
//  PianoKeyboard
//
//  Created by Gary Newby on 20/03/2023.
//

import Foundation
import MusicTheory

/// String/MIDI conversion helpers for note names. The public API is
/// preserved verbatim from the original implementation so existing
/// call sites (across RET, including ChordToMidiNotes and quiz
/// generation) keep compiling unchanged.
///
/// Internally each function delegates to MusicCore's typed `Pitch`
/// for the actual semitone math. Two consequences worth noting:
/// - Spelling round-trips (`name → midi → name`) preserve sharp/flat
///   choice via `preferSharps`. The legacy default for the no-arg
///   `name(for:)` was sharps; `name(for:preferSharps:)` defaulted to
///   flats. Both have been preserved.
/// - The `value(for:)` table accepts a small set of one- and
///   two-character key names (e.g. "C", "F#", "Bb"). MusicCore's
///   accidental encoding maps `b/#` to `flat/sharp`, so the same
///   inputs work.
public struct Note {
    /// Sharps spelling for each chromatic semitone.
    static let sharps = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

    /// Flats spelling for each chromatic semitone.
    static let flats  = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]

    /// Major scale intervals in semitones from root.
    public static let majorScaleIntervals = [0, 2, 4, 5, 7, 9, 11]

    /// Convert a key name (e.g., "C", "F#", "Bb") to its semitone value (0-11).
    public static func value(for keyName: String) -> Int {
        guard let pitch = parseKeyName(keyName) else { return 0 }
        return pitch.chromaticIndex
    }

    /// Get the scale degree (1-7) for a MIDI note in a given key, or
    /// nil if the note is not in the major scale.
    public static func scaleDegree(for midiNote: Int, inKey keyName: String) -> Int? {
        let rootNote = value(for: keyName)
        let noteInScale = ((midiNote - rootNote) % 12 + 12) % 12
        if let index = majorScaleIntervals.firstIndex(of: noteInScale) {
            return index + 1
        }
        return nil
    }

    /// Parse a name like "C4", "F#3", "Bb-1" to a MIDI number.
    public static func midiNumber(for name: String) -> Int {
        // Split into note-portion and octave-portion. Octave can be
        // negative (a leading "-"), so "Bb-1" must split as "Bb"/"-1".
        guard let split = splitNoteAndOctave(name) else { return 0 }
        let (noteName, octave) = split
        let offset = sharps.firstIndex(of: noteName)
                  ?? flats.firstIndex(of: noteName)
                  ?? 0
        return (12 + (octave * 12)) + offset
    }

    /// MIDI → name with octave. Sharp spelling by default.
    public static func name(for midiNumber: Int, preferSharps: Bool = false) -> String {
        let p = Pitch(midi: midiNumber, preferSharps: preferSharps)
        let nameOnly = p.accidental == .flat
            ? "\(p.pitchClass.letterName)b"
            : (p.accidental == .sharp
                ? "\(p.pitchClass.letterName)#"
                : p.pitchClass.letterName)
        return nameOnly + String(p.octave)
    }

    /// MIDI → name with optional octave suffix; opposite default to
    /// the two-arg variant for back-compat with the original utility.
    public static func name(for midiNumber: Int, useFlats: Bool = false, showOctaveNumber: Bool = true) -> String {
        let p = Pitch(midi: midiNumber, preferSharps: !useFlats)
        let suffix: String = {
            switch p.accidental {
            case .flat: return "b"
            case .sharp: return "#"
            default: return ""
            }
        }()
        let nameOnly = "\(p.pitchClass.letterName)\(suffix)"
        return showOctaveNumber ? nameOnly + String(p.octave) : nameOnly
    }

    // MARK: - Private helpers

    /// Parse a key name (no octave) into a `Pitch` at octave 4. Accepts
    /// "C", "F#", "Bb" formats.
    private static func parseKeyName(_ name: String) -> Pitch? {
        guard let first = name.first else { return nil }
        let letter: PitchClass
        switch first {
        case "C", "c": letter = .c
        case "D", "d": letter = .d
        case "E", "e": letter = .e
        case "F", "f": letter = .f
        case "G", "g": letter = .g
        case "A", "a": letter = .a
        case "B", "b": letter = .b
        default: return nil
        }
        let suffix = name.dropFirst()
        let accidental: Accidental
        switch suffix {
        case "":   accidental = .natural
        case "#":  accidental = .sharp
        case "b":  accidental = .flat
        default:   return nil
        }
        return Pitch(pitchClass: letter, accidental: accidental, octave: 4)
    }

    /// Split a name like "C4", "F#3", "Bb-1" into (note-portion, octave-int).
    private static func splitNoteAndOctave(_ name: String) -> (String, Int)? {
        var i = name.endIndex
        // Walk backwards over digits and an optional leading minus.
        while i > name.startIndex {
            let prev = name.index(before: i)
            let c = name[prev]
            if c.isNumber || (c == "-" && prev > name.startIndex) {
                i = prev
                continue
            }
            break
        }
        guard i > name.startIndex, i < name.endIndex else { return nil }
        let noteName = String(name[..<i])
        guard let octave = Int(name[i...]) else { return nil }
        return (noteName, octave)
    }
}
