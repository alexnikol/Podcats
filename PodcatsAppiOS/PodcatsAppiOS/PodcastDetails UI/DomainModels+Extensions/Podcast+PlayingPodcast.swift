// Copyright © 2022 Almost Engineer. All rights reserved.

import PodcastsModule
import AudioPlayerModule

extension PodcastDetails {
    func toPlayingPodcast() -> PlayingPodcast {
        PlayingPodcast(id: id, title: title, publisher: publisher)
    }
}
