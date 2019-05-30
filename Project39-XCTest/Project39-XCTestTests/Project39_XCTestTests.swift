//
//  Project39_XCTestTests.swift
//  Project39-XCTestTests
//
//  Created by Kush, Ryan on 5/29/19.
//  Copyright © 2019 Kush, Ryan. All rights reserved.
//

import XCTest
@testable import Project39_XCTest

class Project39_XCTestTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.setUp()
    }

    func testAllWordsLoaded() {
        let playData = PlayData()
        XCTAssertEqual(playData.allWords.count, 18440, "allWords was not 18440")
    }

    func testWordCountsAreCorrect() {
        let playData = PlayData()
        XCTAssertEqual(playData.wordCounts.count(for: "home"), 174, "Home does not appear 174 times")
        XCTAssertEqual(playData.wordCounts.count(for: "fun"), 4, "Fun does not appear 4 times")
        XCTAssertEqual(playData.wordCounts.count(for: "mortal"), 41, "Mortal does not appear 41 times")
    }

    func testWordsLoadQuickly() {
        measure {
            _ = PlayData()
        }
    }

    func testUserFilterWorks() {
        let playData = PlayData()

        playData.applyUserFilter("100")
        XCTAssertEqual(playData.filteredWords.count, 495, "There are only 495 words that appear 100 times in the list")

        playData.applyUserFilter("1000")
        XCTAssertEqual(playData.filteredWords.count, 55, "There are only 55 words that appear 1000 times in the list")

        playData.applyUserFilter("10000")
        XCTAssertEqual(playData.filteredWords.count, 1, "There is only 1 word that appears 10000 times in the list")

        playData.applyUserFilter("test")
        XCTAssertEqual(playData.filteredWords.count, 56, "test does not appear 56 times in the list")

        playData.applyUserFilter("swift")
        XCTAssertEqual(playData.filteredWords.count, 7, "swift does not appear 7 times in the list")

        playData.applyUserFilter("objective-c")
        XCTAssertEqual(playData.filteredWords.count, 0, "objective-c appears in the list")
    }

}
