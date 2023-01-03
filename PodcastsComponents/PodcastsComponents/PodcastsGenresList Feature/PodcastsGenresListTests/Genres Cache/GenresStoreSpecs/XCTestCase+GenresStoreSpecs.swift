// Copyright © 2022 Almost Engineer. All rights reserved.

import XCTest
import PodcastsGenresList

extension GenresStoreSpecs where Self: XCTestCase {
    
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: GenresStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: .empty, file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: GenresStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .empty, file: file, line: line)
    }
    
    func assertThatretrieveDeliversFoundValuesOnNonEmptyCache(on sut: GenresStore, file: StaticString = #file, line: UInt = #line) {
        let genres = uniqueGenres().local
        let timestamp = Date()
        
        insert((genres, timestamp), to: sut)
        
        expect(sut, toRetrieve: .found(genres: genres, timestamp: timestamp), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: GenresStore, file: StaticString = #file, line: UInt = #line) {
        let genres = uniqueGenres().local
        let timestamp = Date()
        
        insert((genres, timestamp), to: sut)
        
        expect(sut, toRetrieveTwice: .found(genres: genres, timestamp: timestamp), file: file, line: line)
    }
    
    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: GenresStore, file: StaticString = #file, line: UInt = #line) {
        let insertionError = insert((uniqueGenres().local, Date()), to: sut)

        XCTAssertNil(insertionError, "Expected to insert cache successfully")
    }
    
    func assertThaInsertDeliversNoErrorOnNonEmptyCache(on sut: GenresStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueGenres().local, Date()), to: sut)

        let insertionError = insert((uniqueGenres().local, Date()), to: sut)

        XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
    }
    
    func assertThaInsertOverridesPreviouslyInsertedCacheValues(on sut: GenresStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueGenres().local, Date()), to: sut)
        
        let latestGenres = uniqueGenres().local
        let latestTimestamp = Date()
        insert((latestGenres, latestTimestamp), to: sut)
        
        expect(sut, toRetrieve: .found(genres: latestGenres, timestamp: latestTimestamp), file: file, line: line)
    }
    
    func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: GenresStore, file: StaticString = #file, line: UInt = #line) {
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
    }
    
    func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: GenresStore, file: StaticString = #file, line: UInt = #line) {
        deleteCache(from: sut)
        
        expect(sut, toRetrieveTwice: .empty, file: file, line: line)
    }
    
    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: GenresStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueGenres().local, Date()), to: sut)
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
    }
        
    func assertThatDeleteHasNoSideEffectsOnNonEmptyCache(on sut: GenresStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueGenres().local, Date()), to: sut)
        deleteCache(from: sut)
        
        expect(sut, toRetrieveTwice: .empty, file: file, line: line)
    }
    
    func assertThatStoreSideEffectsRunSerially(on sut: GenresStore, file: StaticString = #file, line: UInt = #line) {
        var completedOperationsInOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueGenres().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCacheGenres { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueGenres().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 4.0)
        
        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order", file: file, line: line)
    }

    @discardableResult
    func insert(_ cache: (genres: [LocalGenre], timestamp: Date),
                        to sut: GenresStore) -> Error? {
        var insertionError: Error?
        let exp = expectation(description: "Wait for cache insertion")
        sut.insert(cache.genres, timestamp: cache.timestamp) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    @discardableResult
    func deleteCache(from sut: GenresStore) -> Error? {
        let exp = expectation(description: "Wait on deletion comletion")
        
        var deletionError: Error?
        sut.deleteCacheGenres { error in
            deletionError = error
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    func expect(_ sut: GenresStore,
                        toRetrieveTwice expectedResult: RetrieveCacheGenresResult,
                        file: StaticString = #file,
                        line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    func expect(_ sut: GenresStore,
                        toRetrieve expectedResult: RetrieveCacheGenresResult,
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty),
                (.failure, .failure):
                break
                
            case let (.found(expectedGenres, expectedTimestamp), .found(retrievedGenres, retrievedTimestamp)):
                XCTAssertEqual(expectedGenres, retrievedGenres, file: file, line: line)
                XCTAssertEqual(expectedTimestamp, retrievedTimestamp, "\(expectedTimestamp.timeIntervalSince1970) - \(retrievedTimestamp.timeIntervalSince1970)", file: file, line: line)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
        
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
