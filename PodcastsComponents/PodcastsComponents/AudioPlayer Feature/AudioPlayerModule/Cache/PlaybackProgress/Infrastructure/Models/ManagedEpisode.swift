// Copyright © 2022 Almost Engineer. All rights reserved.

import CoreData

@objc(ManagedEpisode)
final class ManagedEpisode: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var title: String
    @NSManaged var thumbnail: URL
    @NSManaged var audio: URL
    @NSManaged var publishDateInMiliseconds: Int
    @NSManaged var cached: ManagedPlaybackProgress
}
