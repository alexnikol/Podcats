// Copyright © 2022 Almost Engineer. All rights reserved.

import XCTest
import PodcastsGenresList

final class GenresItemsMapperTests: XCTestCase {
        
    func test_map_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() throws {
        let emptyListJSON = makeGenresJSON([])
        
        let result = try GenresItemsMapper.map(emptyListJSON, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, [])
    }
    
    func test_map_deliversGenresItemsOn200HTTPResponseWithJSONItems() throws {
        let genre1 = makeGenres(id: 1, name: "a genre name")
        let genre2 = makeGenres(id: 2, name: "another genre name")
        let json = makeGenresJSON([genre1.json, genre2.json])
        
        let result = try GenresItemsMapper.map(json, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, [genre1.model, genre2.model])
    }
    
    // MARK: - Helpers
            
    private func makeGenres(id: Int, name: String) -> (model: Genre, json: [String: Any]) {
        let genre = Genre(id: id, name: name)
        let json = [
            "id": id,
            "name": name
        ] as [String: Any]
        
        return (genre, json)
    }
    
    private func makeGenresJSON(_ genres: [[String: Any]]) -> Data {
        let json = ["genres": genres]
        return try! JSONSerialization.data(withJSONObject: json)
    }
}
