//
//  NoteNameDisplayTests.swift
//  PianoKeyboardTests
//
//  Created by Claude on 2025/07/27.
//

import Foundation
import XCTest
import SwiftUI
@testable import PianoKeyboard

class NoteNameDisplayTests: XCTestCase {
    
    func test_noteNameGeneration_withSharps() {
        // Middle C
        XCTAssertEqual(Note.name(for: 60, useFlats: false, showOctaveNumber: true), "C4")
        XCTAssertEqual(Note.name(for: 60, useFlats: false, showOctaveNumber: false), "C")
        
        // C#4
        XCTAssertEqual(Note.name(for: 61, useFlats: false, showOctaveNumber: true), "C#4")
        XCTAssertEqual(Note.name(for: 61, useFlats: false, showOctaveNumber: false), "C#")
        
        // A4 (440 Hz)
        XCTAssertEqual(Note.name(for: 69, useFlats: false, showOctaveNumber: true), "A4")
        
        // Low A (A0)
        XCTAssertEqual(Note.name(for: 21, useFlats: false, showOctaveNumber: true), "A0")
        
        // High C (C8)
        XCTAssertEqual(Note.name(for: 108, useFlats: false, showOctaveNumber: true), "C8")
    }
    
    func test_noteNameGeneration_withFlats() {
        // C#4 as Db4
        XCTAssertEqual(Note.name(for: 61, useFlats: true, showOctaveNumber: true), "Db4")
        XCTAssertEqual(Note.name(for: 61, useFlats: true, showOctaveNumber: false), "Db")
        
        // D#4 as Eb4
        XCTAssertEqual(Note.name(for: 63, useFlats: true, showOctaveNumber: true), "Eb4")
        
        // F#4 as Gb4
        XCTAssertEqual(Note.name(for: 66, useFlats: true, showOctaveNumber: true), "Gb4")
        
        // G#4 as Ab4
        XCTAssertEqual(Note.name(for: 68, useFlats: true, showOctaveNumber: true), "Ab4")
        
        // A#4 as Bb4
        XCTAssertEqual(Note.name(for: 70, useFlats: true, showOctaveNumber: true), "Bb4")
    }
    
    func test_viewModel_noteNamePreferences() {
        let viewModel = PianoKeyboardViewModel()
        
        XCTAssertFalse(viewModel.showNoteNames)
        XCTAssertFalse(viewModel.useFlats)
        XCTAssertFalse(viewModel.showOctaveNumbers)
        
        viewModel.showNoteNames = true
        viewModel.useFlats = true
        viewModel.showOctaveNumbers = true
        
        XCTAssertTrue(viewModel.showNoteNames)
        XCTAssertTrue(viewModel.useFlats)
        XCTAssertTrue(viewModel.showOctaveNumbers)
    }
    
    func test_viewModel_noteNameHelper() {
        let viewModel = PianoKeyboardViewModel()
        
        // When showNoteNames is false
        XCTAssertNil(viewModel.noteName(for: 60))
        
        // When showNoteNames is true
        viewModel.showNoteNames = true
        viewModel.useFlats = false
        viewModel.showOctaveNumbers = true
        XCTAssertEqual(viewModel.noteName(for: 60), "C4")
        XCTAssertEqual(viewModel.noteName(for: 61), "C#4")
        
        // Test with flats and no octaves
        viewModel.useFlats = true
        viewModel.showOctaveNumbers = false
        XCTAssertEqual(viewModel.noteName(for: 61), "Db")
        XCTAssertEqual(viewModel.noteName(for: 63), "Eb")
    }
    
    func test_viewModel_customNoteNames() {
        let viewModel = PianoKeyboardViewModel()
        
        XCTAssertTrue(viewModel.customNoteNames.isEmpty)
        
        // Set custom names
        viewModel.customNoteNames = [
            60: "Do",
            62: "Re",
            64: "Mi"
        ]
        
        // Custom names take priority even when showNoteNames is false
        XCTAssertEqual(viewModel.noteName(for: 60), "Do")
        XCTAssertEqual(viewModel.noteName(for: 62), "Re")
        XCTAssertEqual(viewModel.noteName(for: 64), "Mi")
        
        // Non-custom notes return nil when showNoteNames is false
        XCTAssertNil(viewModel.noteName(for: 61))
        
        // Non-custom notes return note names when showNoteNames is true
        viewModel.showNoteNames = true
        XCTAssertEqual(viewModel.noteName(for: 61), "C#4")
        
        // Custom names still take priority
        XCTAssertEqual(viewModel.noteName(for: 60), "Do")
    }
    
    func test_pianoKeyboardView_noteNameParameters() {
        let viewModel = PianoKeyboardViewModel()
        viewModel.showNoteNames = true
        viewModel.useFlats = true
        viewModel.showOctaveNumbers = true
        
        _ = PianoKeyboardView(
            viewModel: viewModel,
            style: ClassicStyle()
        )
        
        XCTAssertTrue(viewModel.showNoteNames)
        XCTAssertTrue(viewModel.useFlats)
        XCTAssertTrue(viewModel.showOctaveNumbers)
    }
    
    func test_showLabelsOnHighlight() {
        let viewModel = PianoKeyboardViewModel()
        viewModel.showNoteNames = true
        viewModel.showLabelsOnHighlight = true
        
        // Without highlights, no names should show
        XCTAssertNil(viewModel.noteName(for: 60))
        XCTAssertNil(viewModel.noteName(for: 61))
        
        // Add highlights
        viewModel.highlightedKeys = [60: .blue, 61: .red]
        
        // Now highlighted keys should show names
        XCTAssertEqual(viewModel.noteName(for: 60), "C4")
        XCTAssertEqual(viewModel.noteName(for: 61), "C#4")
        
        // Non-highlighted keys should not show names
        XCTAssertNil(viewModel.noteName(for: 62))
        
        // When showLabelsOnHighlight is false, all keys show names
        viewModel.showLabelsOnHighlight = false
        XCTAssertEqual(viewModel.noteName(for: 62), "D4")
    }
}