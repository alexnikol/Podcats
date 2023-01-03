// Copyright © 2022 Almost Engineer. All rights reserved.

import Foundation

public extension LocalPlayingItem {
    enum PlaybackState: Int, Equatable {
        case playing
        case pause
        case loading
    }
}

// MARK: - LocalPlayingItem.PlaybackState mapping helper

extension LocalPlayingItem.PlaybackState {
    func toModel() -> PlayingItem.PlaybackState {
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
