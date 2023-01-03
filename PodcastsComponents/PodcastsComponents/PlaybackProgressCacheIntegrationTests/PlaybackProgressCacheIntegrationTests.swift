// Copyright © 2022 Almost Engineer. All rights reserved.

import XCTest
import SharedTestHelpersLibrary
import AudioPlayerModule

final class PlaybackProgressCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toLoad: .failure(LocalPlaybackProgressLoader.StorageErrors.emptyStorage))
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let playingItem = uniquePlayingItem()
        
        save(playingItem, with: sutToPerformSave)
        
        expect(sutToPerformLoad, toLoad: .success(playingItem))
    }
    
    func test_load_overridesItemsSavedOnASeparateInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformSecondSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstPlayingItem = uniquePlayingItem()
        let latestPlayingItem = uniquePlayingItem()
        
        save(firstPlayingItem, with: sutToPerformFirstSave)
        save(latestPlayingItem, with: sutToPerformSecondSave)
        
        expect(sutToPerformLoad, toLoad: .success(latestPlayingItem))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> LocalPlaybackProgressLoader {
        let storeURL = specificTestStoreURL()
        let store = try! CoreDataPlaybackProgressStore(storeURL: storeURL)
        let sut = LocalPlaybackProgressLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: LocalPlaybackProgressLoader,
                        toLoad expectedResult: Result<PlayingItem, Error>,
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case (let .success(loadedPlayingItem), let .success(expectedPlayingItem)):
                XCTAssertEqual(loadedPlayingItem, expectedPlayingItem, file: file, line: line)
                
            case (let .failure(receivedError as LocalPlaybackProgressLoader.StorageErrors), let .failure(expectedError as LocalPlaybackProgressLoader.StorageErrors)):
                if receivedError != expectedError {
                    XCTFail("Expected \(expectedError), got \(receivedError) instead", file: file, line: line)
                }
                
            default:
                XCTFail("Expected result is \(expectedResult), but got \(receivedResult) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func save(_ playingItem: PlayingItem,
                      with sut: LocalPlaybackProgressLoader,
                      file: StaticString = #file,
                      line: UInt = #line) {
        let exp = expectation(description: "Wait for save completion")
        sut.save(playingItem) { saveResult in
            XCTAssertNil(saveResult, "Expected to save playing item successfully", file: file, line: line)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func specificTestStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: specificTestStoreURL())
    }
    
    private func uniquePlayingItem() -> PlayingItem {
        return makePlayingItem(
            playbackState: .pause,
            currentTimeInSeconds: (2...400).randomElement() ?? 200,
            totalTime: .valueInSeconds((2...400).randomElement() ?? 100),
            playbackSpeed: .x0_75
        )
    }
    
    private func none() -> PlayingItem? {
        return nil
    }
}
