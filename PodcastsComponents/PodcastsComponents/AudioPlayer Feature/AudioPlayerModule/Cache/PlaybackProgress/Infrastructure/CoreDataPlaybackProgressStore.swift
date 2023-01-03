// Copyright © 2022 Almost Engineer. All rights reserved.

import Foundation
import CoreData

public final class CoreDataPlaybackProgressStore: PlaybackProgressStore {
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL) throws {
        let bundle = Bundle(for: Self.self)
        container = try NSPersistentContainer.load(modelName: "PlaybackProgressStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func deleteCachedPlayingItem(completion: @escaping DeletionCompletion) {
        perform { context in
            do {
                try ManagedPlaybackProgressStoreCache.find(in: context).map(context.delete).map(context.save)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func insert(_ playingItem: LocalPlayingItem, timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            do {
                let managedCache = try ManagedPlaybackProgressStoreCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.playbackProgress = ManagedPlaybackProgressStoreCache
                    .toCoreDataPlayingItem(from: playingItem, in: context)

                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            do {
                let request = NSFetchRequest<ManagedPlaybackProgressStoreCache>(entityName: ManagedPlaybackProgressStoreCache.entity().name!)
                request.returnsObjectsAsFaults = false
                
                if let cache = try context.fetch(request).first {
                    completion(.found(playingItem: cache.localPlayingItem(), timestamp: cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}
