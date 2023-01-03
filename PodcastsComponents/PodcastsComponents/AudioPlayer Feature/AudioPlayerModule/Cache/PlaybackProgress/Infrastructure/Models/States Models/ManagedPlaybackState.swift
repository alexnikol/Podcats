// Copyright © 2022 Almost Engineer. All rights reserved.

import CoreData

@objc(ManagedPlaybackState)
final class ManagedPlaybackState: ManagedUpdateState {
    @NSManaged var value: Int
}
