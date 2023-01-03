// Copyright © 2022 Almost Engineer. All rights reserved.

import Foundation

public protocol PlaybackProgressCache {
    typealias SaveResult = Error?
    func save(_ playingItem: PlayingItem, completion: @escaping (SaveResult) -> Void)
}
