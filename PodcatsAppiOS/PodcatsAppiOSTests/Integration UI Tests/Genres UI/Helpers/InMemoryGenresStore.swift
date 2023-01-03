// Copyright © 2022 Almost Engineer. All rights reserved.

import Foundation
import PodcastsGenresList

final class InMemoryGenresStore: GenresStore {
    struct GenresCache {
        let genres: [LocalGenre]
        let timestamp: Date
    }
    
    private(set) var cache: GenresCache?
    
    init(cache: GenresCache? = nil) {
        self.cache = cache
    }
    
    static var empty: InMemoryGenresStore {
        InMemoryGenresStore(cache: nil)
    }
    
    static var withNonExpiredFeedCache: InMemoryGenresStore {
        return InMemoryGenresStore(cache: GenresCache(genres: [LocalGenre(id: 1, name: "Any Genre")], timestamp: Date()))
    }
    
    static var withExpiredFeedCache: InMemoryGenresStore {
        return InMemoryGenresStore(cache: GenresCache(genres: [LocalGenre(id: 1, name: "Any Genre")], timestamp: Date.distantPast))
    }
    
    func deleteCacheGenres(completion: @escaping DeletionCompletion) {
        cache = nil
        completion(nil)
    }
    
    func insert(_ genres: [LocalGenre], timestamp: Date, completion: @escaping InsertionCompletion) {
        cache = GenresCache(genres: genres, timestamp: timestamp)
        completion(nil)
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        if let cache = cache {
            completion(.found(genres: cache.genres, timestamp: cache.timestamp))
        } else {
            completion(.empty)
        }
    }
}
