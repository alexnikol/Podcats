// Copyright © 2022 Almost Engineer. All rights reserved.

import Foundation
import Combine
import SharedComponentsiOSModule
import AudioPlayerModule
import AudioPlayerModuleiOS

class StickyAudioPlayerPresentationAdapter {
    private let audioPlayerStatePublisher: AudioPlayerStatePublishers.AudioPlayerStatePublisher
    private var thumbnaiSourceDelegate: ThumbnailSourceDelegate?
    private var subscriptions = Set<AnyCancellable>()
    var presenter: StickyAudioPlayerPresenter?
    var onPlayerOpenAction: () -> Void
    
    init(audioPlayerStatePublisher: AudioPlayerStatePublishers.AudioPlayerStatePublisher,
         thumbnaiSourceDelegate: ThumbnailSourceDelegate, onPlayerOpen: @escaping () -> Void) {
        self.audioPlayerStatePublisher = audioPlayerStatePublisher
        self.onPlayerOpenAction = onPlayerOpen
        self.thumbnaiSourceDelegate = thumbnaiSourceDelegate
    }
}

extension StickyAudioPlayerPresentationAdapter: StickyAudioPlayerViewDelegate {
    
    func onPlayerOpen() {
        onPlayerOpenAction()
    }
    
    func onOpen() {
        audioPlayerStatePublisher
            .dispatchOnMainQueue()
            .sink(
                receiveValue: { [weak self] playerState in
                    self?.updatePlayerState(playerState)
                })
            .store(in: &subscriptions)
    }
}

private extension StickyAudioPlayerPresentationAdapter {

    func updatePlayerState(_ playerState: PlayerState) {
        switch playerState {
        case .noPlayingItem:
            break
            
        case .updatedPlayingItem(let playingItem):
            handleReceivedData(playingItem: playingItem)
            
        case .startPlayingNewItem(let playingItem):
            handleReceivedData(playingItem: playingItem)
        }
    }
    
    private func handleReceivedData(playingItem: PlayingItem) {
        self.presenter?.didReceivePlayerState(with: playingItem)
        self.thumbnaiSourceDelegate?.didUpdateSourceURL(playingItem.episode.thumbnail)
    }
}
