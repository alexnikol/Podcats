// Copyright © 2022 Almost Engineer. All rights reserved.

import Foundation

public final class LocalPlaybackProgressLoader {
    private let store: PlaybackProgressStore
    private let currentDate: () -> Date
    private let cachePolicy = PlaybackProgressCachePolicy()
    
    public init(store: PlaybackProgressStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalPlaybackProgressLoader: PlaybackProgressCache {
    
    public typealias SaveResult = PlaybackProgressCache.SaveResult
    
    public func save(_ playingItem: PlayingItem, completion: @escaping (SaveResult) -> Void) {
        guard cachePolicy.isCacheAvailable(with: playingItem) else {
            completion(nil)
            return
        }
        
        store.deleteCachedPlayingItem(completion: { [weak self] deletion in
            guard let self = self else { return }
            
            if let deletion = deletion {
                completion(deletion)
            } else {
                self.cache(playingItem, completion: completion)
            }
        })
    }
    
    private func cache(_ playingItem: PlayingItem, completion: @escaping (SaveResult) -> Void) {
        self.store.insert(playingItem.toLocal(), timestamp: currentDate(), completion: { [weak self] insertionError in
            guard let self = self else { return }
            
            if insertionError == nil {
                self.cachePolicy.saveSuccessfullyCachedItem(playingItem)
            }
            completion(insertionError)
        })
    }
}

extension LocalPlaybackProgressLoader {
    
    public enum StorageErrors: Error {
        case emptyStorage
    }
    
    public typealias LoadResult = Result<PlayingItem, Error>
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve(completion: { [weak self] loadResult in
            guard self != nil else { return }
            
            switch loadResult {
            case .empty:
                completion(.failure(StorageErrors.emptyStorage))
                
            case let .failure(error):
                completion(.failure(error))
                
            case let .found(playingItem, _):
                completion(.success(playingItem.toModel()))
            }
        })
    }
}

// MARK: - PlayingItem + local models mapping

private extension PlayingItem {
    func toLocal() -> LocalPlayingItem {
        LocalPlayingItem(
            episode: LocalPlayingEpisode(
                id: episode.id,
                title: episode.title,
                thumbnail: episode.thumbnail,
                audio: episode.audio,
                publishDateInMiliseconds: episode.publishDateInMiliseconds
            ),
            podcast: LocalPlayingPodcast(
                id: podcast.id,
                title: podcast.title,
                publisher: podcast.publisher),
            updates: updates.map( { $0.toLocal() })
        )
    }
}

private extension PlayingItem.State {
    func toLocal() -> LocalPlayingItem.State {
        switch self {
        case .playback(let playbackState):
            return .playback(playbackState.toLocal())
            
        case .volumeLevel(let float):
            return .volumeLevel(float)
            
        case .progress(let progress):
            return .progress(progress.toLocal())
            
        case .speed(let playbackSpeed):
            return .speed(playbackSpeed)
        }
    }
}

private extension PlayingItem.PlaybackState {
    func toLocal() -> LocalPlayingItem.PlaybackState {
        switch self {
        case .playing:
            return .playing
            
        case .pause:
            return .pause
            
        case .loading:
            return .loading
        }
    }
}

private extension PlayingItem.Progress {
    func toLocal() -> LocalPlayingItem.Progress {
        .init(
            currentTimeInSeconds: currentTimeInSeconds,
            totalTime: totalTime.toLocal(),
            progressTimePercentage: progressTimePercentage
        )
    }
}

private extension EpisodeDuration {
    func toLocal() -> LocalEpisodeDuration {
        switch self {
        case .notDefined:
            return .notDefined
            
        case .valueInSeconds(let value):
            return .valueInSeconds(value)
        }
    }
}
