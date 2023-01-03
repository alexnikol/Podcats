// Copyright © 2022 Almost Engineer. All rights reserved.

import XCTest
import SharedTestHelpersLibrary
import AudioPlayerModule

final class CachePlaybackProgressUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletionWithoutPreviousCache() {
        let (sut, store) = makeSUT()
        let playingItem = makePlayingItemModels()
        
        sut.save(playingItem.model) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCache])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let playingItem = makePlayingItemModels()
        let deletionError = anyNSError()
        
        sut.save(playingItem.model) { _ in }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCache])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let playingItem = makePlayingItemModels()
        
        sut.save(playingItem.model) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCache, .insert(playingItem.localModel, timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWithError: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
    }
    
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWithError: insertionError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        })
    }
    
    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWithError: nil, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        })
    }
    
    func test_save_doestNotRequestCacheIfPreviousCacheOfTheSameEpisodeWasEarlierThanMinimumProgressChangeFrequency() {
        let saveTime = Date()
        let (sut, store) = makeSUT(currentDate: { saveTime })
        
        let episodeID = UUID()
        let local1 = cacheInitialPlayingItem(to: sut, store: store, episodeID: episodeID, currentTimeInSeconds: 0)
        
        let playingItem2 = makePlayingItemModel(
            episodeID: episodeID,
            currentTimeInSeconds: minimumPlaybackProgressTimeForCache.adding(seconds: -1)
        )
        sut.save(playingItem2.model) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCache, .insert(local1, saveTime)])
    }
    
    func test_save_requestCacheIfPreviousCacheOfTheSameEpisodeWasEqualThanMinimumProgressChangeFrequency() {
        let saveTime = Date()
        let (sut, store) = makeSUT(currentDate: { saveTime })
        
        let episodeID = UUID()
        let local1 = cacheInitialPlayingItem(to: sut, store: store, episodeID: episodeID, currentTimeInSeconds: 0)
        
        let playingItem2 = makePlayingItemModel(
            episodeID: episodeID,
            currentTimeInSeconds: minimumPlaybackProgressTimeForCache
        )
        sut.save(playingItem2.model) { _ in }
        store.completeDeletionSuccessfully(at: 1)
        store.completeInsertionSuccessfully(at: 1)
        
        XCTAssertEqual(
            store.receivedMessages,
            [.deleteCache, .insert(local1, saveTime), .deleteCache, .insert(playingItem2.local, saveTime)]
        )
    }
    
    func test_save_requestCacheIfPreviousCacheOfTheSameEpisodeWasLaterThanMinimumProgressChangeFrequency() {
        let saveTime = Date()
        let (sut, store) = makeSUT(currentDate: { saveTime })
        
        let episodeID = UUID()
        let local1 = cacheInitialPlayingItem(to: sut, store: store, episodeID: episodeID, currentTimeInSeconds: 0)
        
        let playingItem2 = makePlayingItemModel(
            episodeID: episodeID,
            currentTimeInSeconds: minimumPlaybackProgressTimeForCache.adding(seconds: 1)
        )
        sut.save(playingItem2.model) { _ in }
        store.completeDeletionSuccessfully(at: 1)
        store.completeInsertionSuccessfully(at: 1)
        
        XCTAssertEqual(
            store.receivedMessages,
            [.deleteCache, .insert(local1, saveTime), .deleteCache, .insert(playingItem2.local, saveTime)]
        )
    }
    
    func test_save_requestCacheIfPreviousCacheOfTheSameEpisodeWasIsMoreThanDeltaMinimumProgressChangeFrequency() {
        let saveTime = Date()
        let (sut, store) = makeSUT(currentDate: { saveTime })
        
        let episodeID = UUID()
        let local1 = cacheInitialPlayingItem(to: sut, store: store, episodeID: episodeID, currentTimeInSeconds: minimumPlaybackProgressTimeForCache)
        
        let playingItem2 = makePlayingItemModel(
            episodeID: episodeID,
            currentTimeInSeconds: 0
        )
        sut.save(playingItem2.model) { _ in }
        store.completeDeletionSuccessfully(at: 1)
        store.completeInsertionSuccessfully(at: 1)
        
        XCTAssertEqual(
            store.receivedMessages,
            [.deleteCache, .insert(local1, saveTime), .deleteCache, .insert(playingItem2.local, saveTime)]
        )
    }
    
    func test_save_requestCacheOfPlaybackProgressForNewEpisodeAndNoDependOnPreviousCache() {
        let saveTime = Date()
        let (sut, store) = makeSUT(currentDate: { saveTime })
        
        let previousEpisodeID = UUID()
        let local1 = cacheInitialPlayingItem(to: sut, store: store, episodeID: previousEpisodeID, currentTimeInSeconds: 0)
        
        let newEpisodeID = UUID()
        let playingItem2 = makePlayingItemModel(
            episodeID: newEpisodeID,
            currentTimeInSeconds: minimumPlaybackProgressTimeForCache.adding(seconds: -1)
        )
        sut.save(playingItem2.model) { _ in }
        store.completeDeletionSuccessfully(at: 1)
        store.completeInsertionSuccessfully(at: 1)
        
        XCTAssertEqual(
            store.receivedMessages,
            [.deleteCache, .insert(local1, saveTime), .deleteCache, .insert(playingItem2.local, saveTime)]
        )
    }
    
    func test_save_requestCacheIfPreviousCacheOfTheSameEpisodeHasNotDefinedTotalTime() {
        let saveTime = Date()
        let (sut, store) = makeSUT(currentDate: { saveTime })
        
        let episodeID = UUID()
        let local1 = cacheInitialPlayingItem(to: sut, store: store, episodeID: episodeID, currentTimeInSeconds: 0)
        
        let playingItem2 = makePlayingItemModel(
            episodeID: episodeID,
            currentTimeInSeconds: 1,
            totalTime: 200
        )
        sut.save(playingItem2.model) { _ in }
        store.completeDeletionSuccessfully(at: 1)
        store.completeInsertionSuccessfully(at: 1)
        
        XCTAssertEqual(
            store.receivedMessages,
            [.deleteCache, .insert(local1, saveTime), .deleteCache, .insert(playingItem2.local, saveTime)]
        )
    }
    
    func test_save_doesNotDeliverErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = PlaybackProgressStoreSpy()
        var sut: LocalPlaybackProgressLoader? = LocalPlaybackProgressLoader(store: store, currentDate: Date.init)
        let deletionError = anyNSError()
        
        var receivedResults = [LocalPlaybackProgressLoader.SaveResult]()
        sut?.save(makePlayingItemModels().model) { receivedResults.append($0) }
        
        sut = nil
        store.completeDeletion(with: deletionError)
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = PlaybackProgressStoreSpy()
        var sut: LocalPlaybackProgressLoader? = LocalPlaybackProgressLoader(store: store, currentDate: Date.init)
        let insertionError = anyNSError()
        
        var receivedResults = [LocalPlaybackProgressLoader.SaveResult]()
        sut?.save(makePlayingItemModels().model) { receivedResults.append($0) }
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: insertionError)
        
        XCTAssertTrue(receivedResults.isEmpty)
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
    
    private func expect(
        _ sut: LocalPlaybackProgressLoader,
        toCompleteWithError expectedError: NSError?,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for save completion")
        
        var receivedError: Error?
        sut.save(makePlayingItemModels().model) { error in
            receivedError = error
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as? NSError, expectedError, file: file, line: line)
    }
    
    private func cacheInitialPlayingItem(
        to sut: LocalPlaybackProgressLoader,
        store: PlaybackProgressStoreSpy,
        episodeID: UUID,
        currentTimeInSeconds: Int
    ) -> LocalPlayingItem {
        let playingItem1 = makePlayingItemModel(episodeID: episodeID, currentTimeInSeconds: currentTimeInSeconds)
        sut.save(playingItem1.model) { _ in }
        store.completeDeletionSuccessfully(at: 0)
        store.completeInsertionSuccessfully(at: 0)
        return playingItem1.local
    }
    
    private var minimumPlaybackProgressTimeForCache: Int {
        let timeInSeconds = 60
        return timeInSeconds
    }
    
    private func makePlayingItemModel(
        episodeID: UUID,
        currentTimeInSeconds: Int = 0,
        totalTime: Int? = nil
    ) -> (model: PlayingItem, local: LocalPlayingItem) {
        let episode = makeEpisode(episodeID: episodeID.uuidString)
        let podcast = makePodcast()
        let model = PlayingItem(
            episode: episode,
            podcast: podcast,
            updates: [
                .playback(.playing),
                .progress(.init(
                    currentTimeInSeconds: currentTimeInSeconds,
                    totalTime: totalTime == nil ? .notDefined : .valueInSeconds(totalTime ?? 0),
                    progressTimePercentage: 0.5)
                ),
                .volumeLevel(0.5)
            ]
        )
        let localModel = LocalPlayingItem(
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
                publisher: podcast.publisher
            ),
            updates: [
                .playback(.playing),
                .progress(.init(
                    currentTimeInSeconds: currentTimeInSeconds,
                    totalTime: totalTime == nil ? .notDefined : .valueInSeconds(totalTime ?? 0),
                    progressTimePercentage: 0.5)
                ),
                .volumeLevel(0.5)
            ]
        )
        return (model, localModel)
    }
    
    private func makeEpisode(episodeID: String) -> PlayingEpisode {
        let publishDateInMiliseconds = Int(1670914583549)
        let episode = PlayingEpisode(
            id: episodeID,
            title: "Any Episode title",
            thumbnail: anyURL(),
            audio: anyURL(),
            publishDateInMiliseconds: publishDateInMiliseconds
        )
        return episode
    }
}

private extension Int {
    func adding(seconds: Int) -> Int {
        return self + seconds
    }
}
