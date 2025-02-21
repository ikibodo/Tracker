//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by N L on 26.12.24..
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testViewController() {
        let vc = TrackersViewController()
        
//        assertSnapshot(of: vc, as:.image)
//        assertSnapshot(of: vc, as:.image(traits: .init(userInterfaceStyle: .dark)))
        assertSnapshot(of: vc, as:.image(traits: .init(userInterfaceStyle: .light)))
    }
}
