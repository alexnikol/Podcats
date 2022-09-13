// Copyright © 2022 Almost Engineer. All rights reserved.

import XCTest
import PodcastsGenresList

class CoreDataGenresStore: GenresStore {
    
    func deleteCacheGenres(completion: @escaping DeletionCompletion) {}
    
    func insert(_ genres: [LocalGenre], timestamp: Date, completion: @escaping InsertionCompletion) {}
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
}

class CoreDataGenresStoreTests: XCTestCase, GenresStoreSpecs {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CoreDataGenresStore()
        
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {}
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {}
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {}
    
    func test_insert_deliversNoErrorOnEmptyCache() {}
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {}
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {}
    
    func test_delete_deliversNoErrorOnEmptyCache() {}
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {}
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {}
    
    func test_delete_hasNoSideEffectsOnNonEmptyCache() {}
    
    func test_storeSideEffects_runSerially() {}
}
