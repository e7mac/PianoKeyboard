//
//  HighlightingTests.swift
//  PianoKeyboardTests
//
//  Created by Claude on 2025/07/27.
//

import Foundation
import XCTest
import SwiftUI
@testable import PianoKeyboard

class HighlightingTests: XCTestCase {
    
    func test_viewModel_highlightedKeys() {
        let viewModel = PianoKeyboardViewModel()
        
        XCTAssertTrue(viewModel.highlightedKeys.isEmpty)
        
        viewModel.highlightedKeys = [60: .blue, 64: .green]
        
        XCTAssertEqual(viewModel.highlightedKeys.count, 2)
        XCTAssertEqual(viewModel.highlightedKeys[60], .blue)
        XCTAssertEqual(viewModel.highlightedKeys[64], .green)
        XCTAssertNil(viewModel.highlightedKeys[61])
    }
    
    func test_viewModel_updateHighlightedKeys() {
        let viewModel = PianoKeyboardViewModel()
        
        viewModel.highlightedKeys = [60: .red]
        XCTAssertEqual(viewModel.highlightedKeys[60], .red)
        
        viewModel.highlightedKeys[60] = .blue
        XCTAssertEqual(viewModel.highlightedKeys[60], .blue)
        
        viewModel.highlightedKeys.removeValue(forKey: 60)
        XCTAssertNil(viewModel.highlightedKeys[60])
    }
    
    func test_viewModel_highlightMultipleKeys() {
        let viewModel = PianoKeyboardViewModel()
        
        // Highlight C major triad
        viewModel.highlightedKeys = [
            60: .blue,  // C
            64: .green, // E
            67: .red    // G
        ]
        
        XCTAssertEqual(viewModel.highlightedKeys.count, 3)
        XCTAssertNotNil(viewModel.highlightedKeys[60])
        XCTAssertNotNil(viewModel.highlightedKeys[64])
        XCTAssertNotNil(viewModel.highlightedKeys[67])
    }
    
    func test_viewModel_clearHighlights() {
        let viewModel = PianoKeyboardViewModel()
        
        viewModel.highlightedKeys = [60: .blue, 61: .red, 62: .green]
        XCTAssertEqual(viewModel.highlightedKeys.count, 3)
        
        viewModel.highlightedKeys = [:]
        XCTAssertTrue(viewModel.highlightedKeys.isEmpty)
    }
    
    func test_pianoKeyboardView_withHighlights() {
        let viewModel = PianoKeyboardViewModel()
        viewModel.highlightedKeys = [60: .blue, 61: .purple]
        
        _ = PianoKeyboardView(
            viewModel: viewModel,
            style: ClassicStyle()
        )
        
        XCTAssertEqual(viewModel.highlightedKeys.count, 2)
        XCTAssertEqual(viewModel.highlightedKeys[60], .blue)
        XCTAssertEqual(viewModel.highlightedKeys[61], .purple)
    }
}