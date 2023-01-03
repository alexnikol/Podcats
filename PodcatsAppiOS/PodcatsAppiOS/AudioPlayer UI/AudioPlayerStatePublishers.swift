// Copyright © 2022 Almost Engineer. All rights reserved.

import Foundation
import Combine
import AudioPlayerModule

public final class AudioPlayerStatePublishers: AudioPlayerOutputDelegate {
    public typealias AudioPlayerStatePublisher = AnyPublisher<PlayerState, Never>
    public typealias AudioPlayerPrepareForSeekPublisher = AnyPublisher<PlayingItem.Progress, Never>
    
    private let _audioPlayerStatePublisher = CurrentValueSubject<PlayerState, Never>(.noPlayingItem)
    private let _audioPlayerPrepareForSeekPublisher = PassthroughSubject<PlayingItem.Progress, Never>()
    private let playbackProgressCache: PlaybackProgressCache
    private var cancellables = Set<AnyCancellable>()
    
    var audioPlayerStatePublisher: AudioPlayerStatePublisher {
        _audioPlayerStatePublisher.eraseToAnyPublisher()
    }
    
    var audioPlayerPrepareForSeekPublisher: AudioPlayerPrepareForSeekPublisher {
        _audioPlayerPrepareForSeekPublisher.eraseToAnyPublisher()
    }
    
    public func didUpdateState(with state: PlayerState) {
        _audioPlayerStatePublisher.send(state)
    }
    
    public func prepareForProgressAfterSeekApply(futureProgress: PlayingItem.Progress) {
        _audioPlayerPrepareForSeekPublisher.send(futureProgress)
    }
    
    init(playbackProgressCache: PlaybackProgressCache) {
        self.playbackProgressCache = playbackProgressCache
        self.subscribeOnAudioPlayerEvents()
    }
    
    private func subscribeOnAudioPlayerEvents() {
        audioPlayerStatePublisher
            .sink(
                receiveValue: { [weak self] playbackState in
                    switch playbackState {
                    case let .updatedPlayingItem(playbackProgress), let .startPlayingNewItem(playbackProgress):
                        self?.playbackProgressCache.cachingWithoutHandling(playbackProgress)
                        
                    default: break
                    }
                }
            ).store(in: &cancellables)
    }
}

private extension PlaybackProgressCache {
    func cachingWithoutHandling(_ playbackProgress: PlayingItem) {
        self.save(playbackProgress, completion: { _ in })
    }
}
