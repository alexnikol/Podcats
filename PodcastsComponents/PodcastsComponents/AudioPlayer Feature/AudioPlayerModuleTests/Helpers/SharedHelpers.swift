// Copyright © 2022 Almost Engineer. All rights reserved.

import XCTest
import SharedTestHelpersLibrary
import AudioPlayerModule

extension XCTestCase {
    
    func makeUniqueEpisode() -> PlayingEpisode {
        let publishDateInMiliseconds = Int(1670914583549)
        let episode = PlayingEpisode(
            id: UUID().uuidString,
            title: "Any Episode title",
            thumbnail: anyURL(),
            audio: anyURL(),
            publishDateInMiliseconds: publishDateInMiliseconds
        )
        return episode
    }
    
    func makePodcast(title: String = "Any Podcast Title", publisher: String = "Any Publisher Title") -> PlayingPodcast {
        PlayingPodcast(
            id: UUID().uuidString,
            title: title,
            publisher: publisher
        )
    }
    
    func makePlayingItem(
        playbackState: PlayingItem.PlaybackState,
        currentTimeInSeconds: Int,
        totalTime: EpisodeDuration,
        playbackSpeed: PlaybackSpeed
    ) -> PlayingItem {
        PlayingItem(
            episode: makeUniqueEpisode(),
            podcast: makePodcast(),
            updates: [
                .playback(playbackState),
                .progress(
                    .init(
                        currentTimeInSeconds: currentTimeInSeconds,
                        totalTime: totalTime,
                        progressTimePercentage: 0.1234
                    )
                ),
                .volumeLevel(0.5),
                .speed(playbackSpeed)
            ]
        )
    }
}
