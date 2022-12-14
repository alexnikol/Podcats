// Copyright © 2022 Almost Engineer. All rights reserved.

import Foundation
import Combine
import PodcastsModule

extension PodcastImageDataLoader {
    typealias Publisher = AnyPublisher<Data, Swift.Error>
    
    func loadPublisher(from url: URL) -> Publisher {
        var task: PodcastImageDataLoaderTask?
        return Deferred {
            Future { completion in
                return task = self.loadImageData(from: url, completion: completion)
            }
            .handleEvents(receiveCancel: {
                task?.cancel()
            })
        }.eraseToAnyPublisher()
    }
}

extension Publisher where Output == Data {
    func caching(to cache: PodcastImageDataCache, for url: URL) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: { data in
            cache.save(data, for: url, completion: { _ in })
        }).eraseToAnyPublisher()
    }
}
