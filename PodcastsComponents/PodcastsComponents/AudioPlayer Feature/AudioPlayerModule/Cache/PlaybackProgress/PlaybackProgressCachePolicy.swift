// Copyright © 2022 Almost Engineer. All rights reserved.

import Foundation

final class PlaybackProgressCachePolicy {
    
    private var cachedPlayingItem: PlayingItem?
    
    private var minimumPlaybackProgressTimeForCacheInSeconds: Int {
        60
    }
    
    func isCacheAvailable(with playingItem: PlayingItem) -> Bool {
        guard let cachedPlayingItem = cachedPlayingItem else {
            return true
        }
        
        guard cachedPlayingItem.episode.id == playingItem.episode.id else {
            return true
        }
                
        guard let cachedProgress = cachedPlayingItem.progress(), let newProgress = playingItem.progress() else {
            return false
        }
        
        if cachedProgress.totalTime == .notDefined && newProgress.totalTime != .notDefined {
            return true
        }
        
        return abs(newProgress.currentTimeInSeconds - cachedProgress.currentTimeInSeconds) >= minimumPlaybackProgressTimeForCacheInSeconds
    }
    
    func saveSuccessfullyCachedItem(_ playingItem: PlayingItem) {
        self.cachedPlayingItem = playingItem
    }
}

private extension PlayingItem {
    func progress() -> PlayingItem.Progress? {
        var foundProgress: PlayingItem.Progress?
        for update in updates {
            switch update {
            case let .progress(progress):
                foundProgress = progress

            default:
                continue
            }
        }
        return foundProgress
    }
}
