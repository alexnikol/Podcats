// Copyright © 2022 Almost Engineer. All rights reserved.

import Foundation

public class Meta {
    public let episode: PlayingEpisode
    public let podcast: PlayingPodcast
    
    public init(episode: PlayingEpisode, podcast: PlayingPodcast) {
        self.episode = episode
        self.podcast = podcast
    }
}

public protocol AudioPlayer: AudioPlayerControlsDelegate {
    var delegate: AudioPlayerOutputDelegate? { get set }
    
    func startPlayback(fromURL url: URL, withMeta meta: Meta)
    func preparePlayback(fromURL url: URL, withPlayingItem playingItem: PlayingItem)
}
