// Copyright © 2022 Almost Engineer. All rights reserved.

import Foundation
import Combine
import SharedComponentsiOSModule
import AudioPlayerModule
import AudioPlayerModuleiOS

class LargeAudioPlayerPresentationAdapter {
    private var thumbnaiSourceDelegate: ThumbnailSourceDelegate?
    private let audioPlayerstatePublishers: AudioPlayerStatePublishers
    private var subscriptions = Set<AnyCancellable>()
    var presenter: LargeAudioPlayerPresenter?
    
    init(audioPlayerstatePublishers: AudioPlayerStatePublishers, thumbnaiSourceDelegate: ThumbnailSourceDelegate) {
        self.audioPlayerstatePublishers = audioPlayerstatePublishers
        self.thumbnaiSourceDelegate = thumbnaiSourceDelegate
    }
}

extension LargeAudioPlayerPresentationAdapter: LargeAudioPlayerViewDelegate {
    
    func onOpen() {
        audioPlayerstatePublishers.audioPlayerStatePublisher
            .dispatchOnMainQueue()
            .sink(
                receiveValue: { [weak self] playerState in
                    self?.updatePlayerState(playerState)
                })
            .store(in: &subscriptions)
        
        audioPlayerstatePublishers.audioPlayerPrepareForSeekPublisher
            .dispatchOnMainQueue()
            .sink(
                receiveValue: { [weak self] seekProgress in
                    self?.prepareForSeek(seekProgress)
                })
            .store(in: &subscriptions)
    }
        
    func onSelectSpeedPlayback() {
        presenter?.onSelectSpeedPlayback()
    }
}

private extension LargeAudioPlayerPresentationAdapter {

    func updatePlayerState(_ playerState: PlayerState) {
        switch playerState {
        case .noPlayingItem:
            break
            
        case .updatedPlayingItem(let playingItem):
            self.handleReceivedData(playingItem: playingItem)
            
        case .startPlayingNewItem(let playingItem):
            self.handleReceivedData(playingItem: playingItem)
        }
    }
    
    func handleReceivedData(playingItem: PlayingItem) {
        self.presenter?.didReceivePlayerState(with: playingItem)
        self.thumbnaiSourceDelegate?.didUpdateSourceURL(playingItem.episode.thumbnail)
    }
    
    func prepareForSeek(_ progress: AudioPlayerModule.PlayingItem.Progress) {
        self.presenter?.didReceiveFutureProgressAfterSeek(with: progress)
    }
}
