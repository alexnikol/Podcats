// Copyright © 2022 Almost Engineer. All rights reserved.

import CoreData

@objc(ManagedPlaybackProgressStoreCache)
final class ManagedPlaybackProgressStoreCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var playbackProgress: ManagedPlaybackProgress
}

extension ManagedPlaybackProgressStoreCache {
    static func find(in context: NSManagedObjectContext) throws -> ManagedPlaybackProgressStoreCache? {
        let request = NSFetchRequest<ManagedPlaybackProgressStoreCache>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedPlaybackProgressStoreCache {
        try find(in: context).map(context.delete)
        return ManagedPlaybackProgressStoreCache(context: context)
    }
}

extension ManagedPlaybackProgressStoreCache {
    func localPlayingItem() -> LocalPlayingItem {
        let playbackProgress = playbackProgress
        let episode = playbackProgress.episode
        let podcast = playbackProgress.podcast
        let updates: [LocalPlayingItem.State] = playbackProgress.updates
            .compactMap { $0 as? ManagedUpdateState }
            .compactMap { state in
                if let volume = state as? ManagedStateVolume {
                    return .volumeLevel(volume.value)
                } else if let speedValue = state as? ManagedStateSpeed,
                          let speedItem = PlaybackSpeed(rawValue: speedValue.value) {
                    return .speed(speedItem)
                } else if let playbackObject = state as? ManagedPlaybackState,
                          let localPlaybackState = LocalPlayingItem.PlaybackState(rawValue: playbackObject.value) {
                    return .playback(localPlaybackState)
                } else if let progressObject = state as? ManagedProgress {
                    var localDuration: LocalEpisodeDuration
                    if progressObject.totalTime is ManagedDurationNotDefined {
                        localDuration = .notDefined
                    } else if let durationObject = progressObject.totalTime as? ManagedDurationWithValue {
                        localDuration = .valueInSeconds(durationObject.value)
                    } else {
                        return nil
                    }
                    return .progress(LocalPlayingItem.Progress(
                        currentTimeInSeconds: progressObject.currentTimeInSeconds,
                        totalTime: localDuration,
                        progressTimePercentage: progressObject.progressTimePercentage)
                    )
                }
                return nil
            }
        
        return LocalPlayingItem(
            episode: LocalPlayingEpisode(
                id: episode.id,
                title: episode.title,
                thumbnail: episode.thumbnail,
                audio: episode.audio,
                publishDateInMiliseconds: episode.publishDateInMiliseconds
            ),
            podcast: LocalPlayingPodcast(
                id: podcast.id,
                title: podcast.title,
                publisher: podcast.publisher
            ),
            updates: updates
        )
    }
}

extension ManagedPlaybackProgressStoreCache {
    static func toCoreDataPlayingItem(from localPlayingItem: LocalPlayingItem, in context: NSManagedObjectContext) -> ManagedPlaybackProgress {
        let managed = ManagedPlaybackProgress(context: context)
        managed.episode = toCoreDataEpisode(from: localPlayingItem.episode, in: context)
        managed.podcast = toCoreDataPodcast(from: localPlayingItem.podcast, in: context)
        managed.updates = toCoreDataStates(from: localPlayingItem.updates, in: context)
        return managed
    }
}

extension ManagedPlaybackProgressStoreCache {
    static func toCoreDataEpisode(from localPlayingEpisode: LocalPlayingEpisode, in context: NSManagedObjectContext) -> ManagedEpisode {
        let managed = ManagedEpisode(context: context)
        managed.id = localPlayingEpisode.id
        managed.title = localPlayingEpisode.title
        managed.thumbnail = localPlayingEpisode.thumbnail
        managed.audio = localPlayingEpisode.audio
        managed.publishDateInMiliseconds = localPlayingEpisode.publishDateInMiliseconds
        return managed
    }
    
    static func toCoreDataPodcast(from localPlayingPodcast: LocalPlayingPodcast, in context: NSManagedObjectContext) -> ManagedPodcast {
        let managed = ManagedPodcast(context: context)
        managed.id = localPlayingPodcast.id
        managed.title = localPlayingPodcast.title
        managed.publisher = localPlayingPodcast.publisher
        return managed
    }
    
    static func toCoreDataStates(from states: [LocalPlayingItem.State], in context: NSManagedObjectContext) -> NSOrderedSet {
        let result: [NSManagedObject] = states.map { state in
            switch state {
            case .playback(let playbackState):
                let object = ManagedPlaybackState(context: context)
                object.value = playbackState.rawValue
                return object
                
            case .volumeLevel(let volume):
                let object = ManagedStateVolume(context: context)
                object.value = volume
                return object
                
            case .progress(let progress):
                let object = ManagedProgress(context: context)
                object.progressTimePercentage = progress.progressTimePercentage
                object.currentTimeInSeconds = progress.currentTimeInSeconds
                
                switch progress.totalTime {
                case .notDefined:
                    object.totalTime = ManagedDurationNotDefined(context: context)
                    
                case .valueInSeconds(let seconds):
                    let durationObject = ManagedDurationWithValue(context: context)
                    durationObject.value = seconds
                    object.totalTime = durationObject
                }
                return object
                
            case .speed(let playbackSpeed):
                let object = ManagedStateSpeed(context: context)
                object.value = playbackSpeed.rawValue
                return object
            }
        }
        return NSOrderedSet(array: result)
    }
}
