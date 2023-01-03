// Copyright © 2022 Almost Engineer. All rights reserved.

import Foundation
import AudioPlayerModule

final class PlaybackProgressCacheDummy: PlaybackProgressCache {
    func save(_ playingItem: AudioPlayerModule.PlayingItem, completion: @escaping (SaveResult) -> Void) {}
}
