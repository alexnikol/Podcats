// Copyright © 2022 Almost Engineer. All rights reserved.

import XCTest
import SharedTestHelpersLibrary
import AudioPlayerModule


final class LocalPlaybackProgressLoader {
    typealias SaveResult = Error?
    
    private let store: PlaybackProgressStore
    private let currentDate: () -> Date
    
    init(store: PlaybackProgressStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ playingItem: AudioPlayerModule.PlayingItem, completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedPlayingItem(completion: { _ in })
    }
}

protocol PlaybackProgressStore {
    typealias DeletionCompletion = (Error?) -> Void
    
    func deleteCachedPlayingItem(completion: @escaping DeletionCompletion)
}

class PlaybackProgressStoreSpy: PlaybackProgressStore {
    enum Message {
        case deleteCache
    }
    
    private(set) var receivedMessages: [Message] = []
    
    func deleteCachedPlayingItem(completion: @escaping DeletionCompletion) {
        receivedMessages.append(.deleteCache)
    }
}

final class CachePlaybackProgressUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let playingItem = makePlayingItemModels()
        
        sut.save(playingItem.model) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCache])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: LocalPlaybackProgressLoader, store: PlaybackProgressStoreSpy) {
        let store = PlaybackProgressStoreSpy()
        let sut = LocalPlaybackProgressLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func makePlayingItemModels() -> (model: PlayingItem, localModel: LocalPlayingItem) {
        let episode = makeUniqueEpisode()
        let podcast = makePodcast()
        let model = PlayingItem(
            episode: episode,
            podcast: podcast,
            updates: [
                .playback(.playing),
                .progress(
                    .init(
                        currentTimeInSeconds: 10,
                        totalTime: .notDefined,
                        progressTimePercentage: 0.1
                    )
                ),
                .volumeLevel(0.5)
            ]
        )
        
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
                .playback(.playing),
                .progress(
                    .init(
                        currentTimeInSeconds: 10,
                        totalTime: .notDefined,
                        progressTimePercentage: 0.1
                    )
                ),
                .volumeLevel(0.5)
            ]
        )
        
        return (model, localModel)
    }
}
