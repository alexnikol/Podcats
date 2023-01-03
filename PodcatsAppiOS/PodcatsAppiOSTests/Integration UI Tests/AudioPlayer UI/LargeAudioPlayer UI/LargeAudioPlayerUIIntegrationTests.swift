// Copyright © 2022 Almost Engineer. All rights reserved.

import XCTest
import SharedTestHelpersLibrary
import Combine
import PodcastsModule
import AudioPlayerModule
import AudioPlayerModuleiOS
@testable import Podcats

final class LargeAudioPlayerUIIntegrationTests: XCTestCase {
    
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
    
    func test_sendControlMessages_sendVolumeStateToControlsDelegate() {
        let (sut, _, controlsSpy) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.simulateUserInitiatedVolumeChange(to: 0.5)
        sut.simulateUserInitiatedVolumeChange(to: 0.1)
        
        XCTAssertEqual(controlsSpy.messages, [.volumeChange(0.5), .volumeChange(0.1)])
    }
    
    func test_sendControlMessages_sendSeekStateToControlsDelegate() {
        let (sut, _, controlsSpy) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.simulateUserInitiatedSeekToProgessFirstWay(to: 0.0)
        sut.simulateUserInitiatedSeekToProgessSecondWay(to: 0.6)
        sut.simulateUserInitiatedSeekBackward()
        sut.simulateUserInitiatedSeekForeward()
        
        XCTAssertEqual(
            controlsSpy.messages,
            [.seekToProgress(0.0), .seekToProgress(0.6), .seekToSeconds(-15), .seekToSeconds(30)]
        )
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
    
    private typealias SUT = (sut: LargeAudioPlayerViewController,
                             audioPlayerSpy: AudioPlayerClientDummy,
                             controlsDelegate: AudioPlayerControlsSpy)
    
    private func makeSUT(
        audioPlayerstatePublishers: AudioPlayerStatePublishers = AudioPlayerStatePublishers(playbackProgressCache: PlaybackProgressCacheDummy()),
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        let controlsSpy = AudioPlayerControlsSpy()
        let audioPlayer = AudioPlayerClientDummy()
        let sut = LargeAudioPlayerUIComposer.playerWith(
            audioPlayerstatePublishers: audioPlayerstatePublishers,
            controlsDelegate: controlsSpy,
            imageLoader: { _ in
                Empty().eraseToAnyPublisher()
            }
        )
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(audioPlayerstatePublishers, file: file, line: line)
        trackForMemoryLeaks(controlsSpy, file: file, line: line)
        trackForMemoryLeaks(audioPlayer, file: file, line: line)
        audioPlayer.delegate = audioPlayerstatePublishers
        return (sut, audioPlayer, controlsSpy)
    }
    
    private func assertThat(
        _ sut: LargeAudioPlayerViewController,
        isRendering playingItem: PlayingItem?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard let playingItem = playingItem else {
            XCTAssertEqual(sut.episodeTitleText(), nil, file: file, line: line)
            XCTAssertEqual(sut.episodeDescriptionText(), nil, file: file, line: line)
            XCTAssertEqual(sut.leftTimeLabelText(), nil, file: file, line: line)
            XCTAssertEqual(sut.rightTimeLabelText(), nil, file: file, line: line)
            XCTAssertEqual(sut.volumeLevel(), 0, file: file, line: line)
            XCTAssertEqual(sut.playbackProgress(), 0, file: file, line: line)
            return
        }
        
        let viewModel = makePresenter().map(playingItem: playingItem)
        XCTAssertEqual(sut.episodeTitleText(), viewModel.titleLabel, file: file, line: line)
        XCTAssertEqual(sut.episodeDescriptionText(), viewModel.descriptionLabel, file: file, line: line)
        XCTAssertEqual(viewModel.updates.count, 4, "Should have 4 state update objects")
        
        for update in viewModel.updates {
            switch update {
            case .playback:
                XCTAssertEqual(sut.playButtonImage(), UIImage(systemName: "pause.fill"), file: file, line: line)
                
            case let .progress(progressViewModel):
                XCTAssertEqual(sut.leftTimeLabelText(), progressViewModel.currentTimeLabel, file: file, line: line)
                XCTAssertEqual(sut.rightTimeLabelText(), progressViewModel.endTimeLabel, file: file, line: line)
                XCTAssertEqual(sut.playbackProgress(), progressViewModel.progressTimePercentage, file: file, line: line)
                
            case let .volumeLevel(level):
                XCTAssertEqual(sut.volumeLevel(), level, file: file, line: line)
                
            case let .speed(speedPlayback):
                XCTAssertEqual(sut.speedPlaybackValue(), speedPlayback.displayTitle, file: file, line: line)
            }
        }
    }
    
    private func makePresenter(file: StaticString = #file, line: UInt = #line) -> LargeAudioPlayerPresenter {
        class AudioPlayerViewNullObject: LargeAudioPlayerView {
            func diplayFuturePrepareForSeekProgress(with progress: AudioPlayerModule.ProgressViewModel) {}
            func displaySpeedPlaybackSelection(with list: [AudioPlayerModule.PlaybackSpeed]) {}
            func display(viewModel: LargeAudioPlayerViewModel) {}
            func displaySpeedPlaybackSelection(viewModel: AudioPlayerModule.SpeedPlaybackViewModel) {}
        }
        
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")
        let presenter = LargeAudioPlayerPresenter(
            resourceView: AudioPlayerViewNullObject(),
            calendar: calendar,
            locale: locale
        )
        trackForMemoryLeaks(presenter, file: file, line: line)
        return presenter
    }
}
