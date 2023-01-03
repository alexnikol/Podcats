// Copyright © 2022 Almost Engineer. All rights reserved.

import Combine
import HTTPClient
import AudioPlayerModule

extension LocalPlaybackProgressLoader {
    typealias Publisher = AnyPublisher<PlayingItem, Error>
    
    func loadPublisher() -> Publisher {
        Deferred {
            Future(self.load)
        }.eraseToAnyPublisher()
    }
}

extension Publisher where Output == PlayingItem {
    func caching(to cache: PlaybackProgressCache) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: { playingItem in
            cache.save(playingItem, completion: { _ in })
        }).eraseToAnyPublisher()
    }
}
