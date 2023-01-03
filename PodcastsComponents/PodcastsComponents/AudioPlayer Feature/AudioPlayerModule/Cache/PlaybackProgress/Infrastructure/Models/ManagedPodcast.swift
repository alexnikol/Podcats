// Copyright © 2022 Almost Engineer. All rights reserved.

import CoreData

@objc(ManagedPodcast)
final class ManagedPodcast: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var title: String
    @NSManaged var publisher: String
    @NSManaged var cached: ManagedPlaybackProgress
}
