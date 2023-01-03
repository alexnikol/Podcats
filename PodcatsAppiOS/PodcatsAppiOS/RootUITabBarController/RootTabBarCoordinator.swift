// Copyright © 2022 Almost Engineer. All rights reserved.

import UIKit
import HTTPClient
import AudioPlayerModule
import AudioPlayerModuleiOS
import PodcastsModule

final class RootTabBarCoordinator {
    private let httpClient: HTTPClient
    private let tabbarController: RootTabBarController
    private let audioPlayer: AudioPlayer
    private let audioPlayerStatePublishers: AudioPlayerStatePublishers
    private var largePlayerController: LargeAudioPlayerViewController?
    
    init(httpClient: HTTPClient,
         tabbarController: RootTabBarController,
         audioPlayer: AudioPlayer,
         audioPlayerStatePublishers: AudioPlayerStatePublishers) {
        self.httpClient = httpClient
        self.tabbarController = tabbarController
        self.audioPlayer = audioPlayer
        self.audioPlayerStatePublishers = audioPlayerStatePublishers
    }
    
    func start(controllers: [UIViewController]) {
        tabbarController.setViewControllers(controllers, animated: false)
    }
    
    private func openPlayingPlayer() {
        guard let largePlayerController = largePlayerController else {
            largePlayerController = createPlayer()
            openPlayingPlayer()
            return
        }
        present(screen: largePlayerController)
    }
    
    private func startPlayback(episode: PlayingEpisode, podcast: PlayingPodcast) {
        audioPlayer.startPlayback(fromURL: episode.audio, withMeta: Meta(episode: episode, podcast: podcast))
        openPlayingPlayer()
    }
        
    private func present(screen: UIViewController) {
        tabbarController.showDetailViewController(screen, sender: self)
    }
            
    private func createPlayer() -> LargeAudioPlayerViewController {
        let service = EpisodeThumbnailLoaderService(
            httpClient: httpClient,
            podcastsImageDataStore: PodcastsImageDataStoreContainer.shared.podcastsImageDataStore
        )
        
        let largePlayerController = LargeAudioPlayerUIComposer.playerWith(
            audioPlayerstatePublishers: audioPlayerStatePublishers,
            controlsDelegate: audioPlayer,
            imageLoader: service.makeRemotePodcastImageDataLoader(for:)
        )
        return largePlayerController
    }
}

extension RootTabBarCoordinator: LargePlayerControlDelegate {

    func openPlayer() {
        openPlayingPlayer()
    }
    
    func startPlaybackAndOpenPlayer(episode: PlayingEpisode, podcast: PlayingPodcast) {
        startPlayback(episode: episode, podcast: podcast)
    }
}
