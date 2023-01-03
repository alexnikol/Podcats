// Copyright © 2023 Almost Engineer. All rights reserved.

import Foundation
import AudioPlayerModule

final class InMemoryPlaybackProgressStore: PlaybackProgressStore {
    struct Cache {
        let progress: LocalPlayingItem
        let timestamp: Date
    }
    
    private(set) var cache: Cache?
    
    init(cache: Cache? = nil) {
        self.cache = cache
    }
    
    static var empty: InMemoryPlaybackProgressStore {
        InMemoryPlaybackProgressStore(cache: nil)
    }
    
    static var withNonEmptyCache: InMemoryPlaybackProgressStore {
        let episode = makePlayingEpisode()
        let podcast = makePlayingPodcast()
        let localEpisode = LocalPlayingEpisode(
            id: episode.id,
            title: episode.title,
            thumbnail: episode.thumbnail,
            audio: episode.audio,
            publishDateInMiliseconds: episode.publishDateInMiliseconds
        )
        let localPodcast = LocalPlayingPodcast(id: podcast.id, title: podcast.title, publisher: podcast.publisher)
        let localModel = LocalPlayingItem(
            episode: localEpisode,
            podcast: localPodcast,
            updates: [
                .progress(.init(
                    currentTimeInSeconds: 10,
                    totalTime: .notDefined,
                    progressTimePercentage: 0.4)
                ),
                .playback(.pause),
                .speed(.x0_75),
                .volumeLevel(0.5)
            ]
        )
        return InMemoryPlaybackProgressStore(cache: Cache(progress: localModel, timestamp: Date()))
    }
    
    func deleteCachedPlayingItem(completion: @escaping DeletionCompletion) {
        cache = nil
        completion(nil)
    }
    
    func insert(_ playingItem: LocalPlayingItem, timestamp: Date, completion: @escaping InsertionCompletion) {
        cache = Cache(progress: playingItem, timestamp: timestamp)
        completion(nil)
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        if let cache = cache {
            completion(.found(playingItem: cache.progress, timestamp: cache.timestamp))
        } else {
            completion(.empty)
        }
    }
}
