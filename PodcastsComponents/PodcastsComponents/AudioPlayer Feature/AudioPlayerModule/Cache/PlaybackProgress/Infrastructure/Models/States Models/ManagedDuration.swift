// Copyright © 2022 Almost Engineer. All rights reserved.

import CoreData

@objc(ManagedDuration)
class ManagedDuration: NSManagedObject {}

@objc(ManagedDurationNotDefined)
final class ManagedDurationNotDefined: ManagedDuration {}

@objc(ManagedDurationWithValue)
final class ManagedDurationWithValue: ManagedDuration {
    @NSManaged var value: Int
}
