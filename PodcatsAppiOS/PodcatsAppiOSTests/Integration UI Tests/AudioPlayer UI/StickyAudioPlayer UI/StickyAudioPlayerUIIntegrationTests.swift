// Copyright © 2022 Almost Engineer. All rights reserved.

import XCTest
import SharedTestHelpersLibrary
import Combine
import PodcastsModule
import AudioPlayerModule
import AudioPlayerModuleiOS
@testable import Podcats

final class StickyAudioPlayerUIIntegrationTests: XCTestCase {
    
    func test_onLoad_doesNotSendsControlSignals() {
        let (sut, _, controlsSpy) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(controlsSpy.messages.isEmpty)
    }
    
    func test_sendControlMessages_sendTogglePlaybackStateToControlsDelegate() {
        let (sut, _, controlsSpy) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.simulateUserInitiatedTogglePlaybackEpisode()
        
        XCTAssertEqual(controlsSpy.messages, [.tooglePlaybackState])
    }
    
    func test_sendControlMessages_sendSeekStateToControlsDelegate() {
        let (sut, _, controlsSpy) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.simulateUserInitiatedSeekForeward()
        
        XCTAssertEqual(controlsSpy.messages, [.seekToSeconds(30)])
    }
    
    func test_rendersState_rendersCurrentPlayersStateAndUpdateStateOnNewReceive() {
        let (sut, audioPlayerSpy, _) = makeSUT()

        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: nil)

        let playingItem1 = makePlayingItem()

        audioPlayerSpy.sendNewPlayerState(.startPlayingNewItem(playingItem1))
        assertThat(sut, isRendering: playingItem1)

        let playingItem2 = makePlayingItem(
            title: "Another Podcast Title",
            publisher: "Another Publisher",
            currentTimeInSeconds: 10,
            totalTime: .valueInSeconds(200),
            progressTimePercentage: 0.4,
            volumeLevel: 0.6,
            speedPlayback: .x2
        )

        audioPlayerSpy.sendNewPlayerState(.startPlayingNewItem(playingItem2))
        assertThat(sut, isRendering: playingItem2)
    }
    
    func test_rendersState_receiveCurrentPlayingStateWhenPlayerCreatedWhenCurrentPlayerItemAlreadyPlaying() {
        let sharedPublisher = AudioPlayerStatePublishers(playbackProgressCache: PlaybackProgressCacheDummy())
        var sut1: SUT? = makeSUT(audioPlayerstatePublishers: sharedPublisher)
        sut1?.sut.loadViewIfNeeded()
        
        let playingItem = makePlayingItem()
        
        sut1?.audioPlayerSpy.sendNewPlayerState(.startPlayingNewItem(playingItem))
        
        sut1 = nil
        
        let (sut2, _, _) = makeSUT(audioPlayerstatePublishers: sharedPublisher)
        sut2.loadViewIfNeeded()
        
        assertThat(sut2, isRendering: playingItem)
    }
    
    func test_rendersState_dispatchesFromBackgroundToMainThread() {
        let (sut, audioPlayerSpy, _) = makeSUT()
        sut.loadViewIfNeeded()
        
        let playingItem = makePlayingItem()
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            audioPlayerSpy.sendNewPlayerState(.startPlayingNewItem(playingItem))
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = (sut: StickyAudioPlayerViewController,
                             audioPlayerSpy: AudioPlayerClientDummy,
                             controlsDelegate: AudioPlayerControlsSpy)
    
    private func makeSUT(
        audioPlayerstatePublishers: AudioPlayerStatePublishers = AudioPlayerStatePublishers(playbackProgressCache: PlaybackProgressCacheDummy()),
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        let controlsSpy = AudioPlayerControlsSpy()
        let audioPlayer = AudioPlayerClientDummy()
        let sut = StickyAudioPlayerUIComposer.playerWith(
            audioPlayerStatePublisher: audioPlayerstatePublishers.audioPlayerStatePublisher,
            controlsDelegate: controlsSpy,
            imageLoader: { _ in
                Empty().eraseToAnyPublisher()
            },
            onPlayerOpen: {}
        )
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(audioPlayerstatePublishers, file: file, line: line)
        trackForMemoryLeaks(controlsSpy, file: file, line: line)
        trackForMemoryLeaks(audioPlayer, file: file, line: line)
        audioPlayer.delegate = audioPlayerstatePublishers
        return (sut, audioPlayer, controlsSpy)
    }
    
    private func assertThat(
        _ sut: StickyAudioPlayerViewController,
        isRendering playingItem: PlayingItem?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard let playingItem = playingItem else {
            XCTAssertEqual(sut.episodeTitleText(), nil, file: file, line: line)
            XCTAssertEqual(sut.episodeDescriptionText(), nil, file: file, line: line)
            return
        }
        
        let viewModel = makePresenter().map(playingItem: playingItem)
        XCTAssertEqual(sut.episodeTitleText(), viewModel.titleLabel, file: file, line: line)
        XCTAssertEqual(sut.episodeDescriptionText(), viewModel.descriptionLabel, file: file, line: line)
        XCTAssertEqual(sut.playButtonImage(), UIImage(systemName: "pause.fill"), file: file, line: line)
    }
    
    private func makePresenter(file: StaticString = #file, line: UInt = #line) -> StickyAudioPlayerPresenter {
        class AudioPlayerViewNullObject: StickyAudioPlayerView {
            func display(viewModel: AudioPlayerModule.StickyAudioPlayerViewModel) {}
        }
        
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")
        let presenter = StickyAudioPlayerPresenter(
            resourceView: AudioPlayerViewNullObject(),
            calendar: calendar,
            locale: locale
        )
        trackForMemoryLeaks(presenter, file: file, line: line)
        return presenter
    }
}
