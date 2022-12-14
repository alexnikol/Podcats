// Copyright © 2022 Almost Engineer. All rights reserved.

import CoreData

@objc(ManagedGenre)
final class ManagedGenre: NSManagedObject {
    @NSManaged var id: Int
    @NSManaged var name: String
    @NSManaged var cached: ManagedGenresStoreCache
}
