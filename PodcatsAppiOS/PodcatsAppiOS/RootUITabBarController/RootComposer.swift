// Copyright © 2022 Almost Engineer. All rights reserved.

import UIKit
import Combine
import HTTPClient
import PodcastsGenresList
import AudioPlayerModule
import SearchContentModule

final class RootComposer {
    
    enum TabbarColors {
        static let selectedColor = UIColor.accentColor
        static let defaultColor = UIColor.label
    }
    
    private init() {}
    
    static func compose(
        baseURL: URL,
        httpClient: HTTPClient,
        localGenresLoader: LocalGenresLoader,
        audioPlayer: AudioPlayer,
        audioPlayerStatePublishers: AudioPlayerStatePublishers,
        playbackProgressCache: PlaybackProgressCache,
        localPlaybackProgressLoader: @escaping () -> LocalPlaybackProgressLoader.Publisher
    ) -> UIViewController {
        let tabBarPresenter = RootTabBarPresenter()
        let tabBarPresentationAdapter = RootTabBarPresentationAdapter(
            audioPlayer: audioPlayer,
            audioPlayerStatePublishers: audioPlayerStatePublishers,
            playbackProgressCache: playbackProgressCache,
            playbackProgressLoader: localPlaybackProgressLoader
        )
        tabBarPresentationAdapter.presenter = tabBarPresenter
        
        let exploreNavigation = UINavigationController()
        let exploreCoordinator = ExploreCoordinator(
            navigationController: exploreNavigation,
            baseURL: baseURL,
            httpClient: httpClient,
            localGenresLoader: localGenresLoader
        )
        exploreNavigation.tabBarItem = UITabBarItem(
            title: tabBarPresenter.exploreTabBarItemTitle,
            image: UIImage(systemName: "rectangle.grid.2x2.fill")?.withTintColor(TabbarColors.defaultColor),
            selectedImage: UIImage(systemName: "rectangle.grid.2x2.fill")?.withTintColor(TabbarColors.selectedColor)
        )
        exploreCoordinator.start()
        
        let searchNavigation = UINavigationController()
        let searchCoordinator = SearchCoordinator(
            navigationController: searchNavigation,
            baseURL: baseURL,
            httpClient: httpClient
        )
        searchNavigation.tabBarItem = UITabBarItem(
            title: tabBarPresenter.searchTabBarItemTitle,
            image: UIImage(systemName: "waveform.and.magnifyingglass")?.withTintColor(TabbarColors.defaultColor),
            selectedImage: UIImage(systemName: "waveform.and.magnifyingglass")?.withTintColor(TabbarColors.selectedColor)
        )
        searchCoordinator.start()
        
        let episodeThumbnailLoaderService = EpisodeThumbnailLoaderService(
            httpClient: httpClient,
            podcastsImageDataStore: PodcastsImageDataStoreContainer.shared.podcastsImageDataStore
        )
        
        var largePlayerControlDelegate: LargePlayerControlDelegate?
        let stickyPlayer = StickyAudioPlayerUIComposer.playerWith(
            audioPlayerStatePublisher: audioPlayerStatePublishers.audioPlayerStatePublisher,
            controlsDelegate: audioPlayer,
            imageLoader: episodeThumbnailLoaderService.makeRemotePodcastImageDataLoader(for:),
            onPlayerOpen: {
                largePlayerControlDelegate?.openPlayer()
            }
        )
        
        let rootTabBarController = RootTabBarController(
            stickyAudioPlayerController: stickyPlayer,
            viewDelegate: tabBarPresentationAdapter
        )
        tabBarPresenter.view = rootTabBarController
        
        let rootCoordinator = RootTabBarCoordinator(
            httpClient: httpClient,
            tabbarController: rootTabBarController,
            audioPlayer: audioPlayer,
            audioPlayerStatePublishers: audioPlayerStatePublishers
        )
        largePlayerControlDelegate = rootCoordinator
        exploreCoordinator.largePlayerControlDelegate = largePlayerControlDelegate
        searchCoordinator.largePlayerControlDelegate = largePlayerControlDelegate
        
        rootCoordinator.start(controllers: [exploreNavigation, searchNavigation])
        return rootTabBarController
    }
}
