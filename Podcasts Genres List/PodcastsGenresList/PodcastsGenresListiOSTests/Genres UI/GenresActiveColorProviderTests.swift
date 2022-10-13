//
//  GenresActiveColorProviderTests.swift
//  PodcastsGenresListiOSTests
//
//  Created by Alexander Nikolaychuk on 16.09.2022.
//  Copyright © 2022 Almost Engineer. All rights reserved.
//

import XCTest

class GenresActiveColorProvider {
    
    private enum Error: Swift.Error {
        case invalidColorsList
        case emptyColorsList
    }
    
    var colors: [String] = []
    
    func getColor(by index: Int) throws -> UIColor {
        guard !colors.isEmpty else {
            throw Error.emptyColorsList
        }
        
        guard index >= colors.count else {
            return UIColor(hexString: colors[index])
        }
        
        let inxedWithoutOverflow = index % colors.count
        
        return UIColor(hexString: colors[inxedWithoutOverflow])
    }
    
    func setColors(_ colors: [String]) throws {
        guard !colors.isEmpty else {
            throw Error.emptyColorsList
        }
        
        try colors.forEach { try validate($0) }
        self.colors = colors
    }
    
    private func validate(_ color: String) throws -> Void {
        let preparedColorString = color.replacingOccurrences(of: "#", with: "")
        let isColorsStringValid = preparedColorString.filter(\.isHexDigit).count == preparedColorString.count
        if isColorsStringValid {
            return
        }
        throw Error.invalidColorsList
    }
}

final class GenresActiveColorProviderTests: XCTestCase {
        
    func test_onSetColors_saveProvidedColorsList() {
        let sut = makeSUT()
        let colors = validColors()
        
        XCTAssertNoThrow(try sut.setColors(colors), "Expected successful set colors operation")
        XCTAssertEqual(sut.colors, colors)
    }
    
    func test_onSetColors_deliversErrorIfAnyOfProvidedColorsAreNotValidHexString() {
        let sut = makeSUT()
        let invalidColor = "mmmmmm"
        let colors = [invalidColor] + validColors()
        
        XCTAssertThrowsError(try sut.setColors(colors), "Expected failed operation since provided list of colors has an invalid color")
    }
    
    func test_onSetColors_deliversNoErrorOnColorsWithNoCareAboutHashtagSymbol() {
        let sut = makeSUT()
        let validColors = ["000000", "#ffffff"]
        
        XCTAssertNoThrow(try sut.setColors(validColors), "Expected successful operation since provided colors validation do not depend on # symbol")
    }
    
    func test_onSetColors_deliversErrorOnEmptyList() {
        let sut = makeSUT()
        let colors: [String] = []
        
        XCTAssertThrowsError(try sut.setColors(colors), "Expected failed operation on provided list: \(colors)")
    }
    
    func test_onGetColorByIndex_deliversErrorOnEmptyColorsList() {
        let sut = makeSUT()
        let index = 0

        XCTAssertThrowsError(try sut.getColor(by: index), "Expected error on empty colors list")
    }
    
    func test_onGetColorByIndex_deliversColorsByIndexWithNonEmptyColorsList() {
        let sut = makeSUT()
        let index = 0
        
        XCTAssertNoThrow(try sut.setColors(validColors()), "Expected successful set colors operation")
        XCTAssertNoThrow(try sut.getColor(by: index), "Expected no error on non empty colors list")
    }
    
    func test_onGetColorByIndex_deliversColorByIndexOfPassedColorsList() {
        let sut = makeSUT()
        let validColor1 = "e6194b"
        let validColor2 = "3cb44b"
        let validColors = [validColor1, validColor2]
        
        XCTAssertNoThrow(try sut.setColors(validColors), "Expected successful set colors operation")
        XCTAssertEqual(try sut.getColor(by: 0), UIColor(hexString: validColor1))
        XCTAssertEqual(try sut.getColor(by: 1), UIColor(hexString: validColor2))
    }
    
    func test_onGetColorByIndex_deliversColorsByAnyIndexFromProviderWithNonEmptyListByGetFromStartPattern() {
        let sut = makeSUT()
        let validColor1 = "e6194b"
        let validColor2 = "3cb44b"
        let validColor3 = "000000"
        let validColors = [validColor1, validColor2, validColor3]
        
        XCTAssertNoThrow(try sut.setColors(validColors), "Expected successful set colors operation")
        XCTAssertEqual(try sut.getColor(by: 4), UIColor(hexString: validColor2))
        XCTAssertEqual(try sut.getColor(by: 5), UIColor(hexString: validColor3))
        XCTAssertEqual(try sut.getColor(by: 6), UIColor(hexString: validColor1))
        XCTAssertEqual(try sut.getColor(by: 7), UIColor(hexString: validColor2))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> GenresActiveColorProvider {
        let sut = GenresActiveColorProvider()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func validColors() -> [String] {
        return ["e6194b", "3cb44b"]
    }
}

private extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
