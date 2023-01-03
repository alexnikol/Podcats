// Copyright © 2022 Almost Engineer. All rights reserved.

import Foundation
import AudioPlayerModule

final class AudioPlayerClientDummy: AudioPlayer {
    var isPlaying = false
    
    func play() {}
    func pause() {}
    func changeVolumeTo(value: Float) {}
    func seekToProgress(_ progress: Float) {}
    func seekToSeconds(_ seconds: Int) {}
    
    var delegate: AudioPlayerOutputDelegate?
    
    func sendNewPlayerState(_ state: PlayerState) {
        delegate?.didUpdateState(with: state)
    }
    
    func startPlayback(fromURL url: URL, withMeta meta: AudioPlayerModule.Meta) {}
    func preparePlayback(fromURL url: URL, withPlayingItem playingItem: AudioPlayerModule.PlayingItem) {}
    func changeSpeedPlaybackTo(value: AudioPlayerModule.PlaybackSpeed) {}
    func prepareForSeek(_ progress: Float) {}
}
