// Copyright © 2022 Almost Engineer. All rights reserved.

import CoreData

@objc(ManagedProgress)
final class ManagedProgress: ManagedUpdateState {
    @NSManaged var currentTimeInSeconds: Int
    @NSManaged var totalTime: ManagedDuration
    @NSManaged var progressTimePercentage: Float
}
