// Copyright © 2022 Almost Engineer. All rights reserved.

import CoreData

@objc(ManagedPlaybackProgress)
final class ManagedPlaybackProgress: NSManagedObject {
    @NSManaged var podcast: ManagedPodcast
    @NSManaged var episode: ManagedEpisode
    @NSManaged var updates: NSOrderedSet
    @NSManaged var cached: ManagedPlaybackProgressStoreCache
}
