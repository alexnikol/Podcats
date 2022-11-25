// Copyright © 2022 Almost Engineer. All rights reserved.

import UIKit
import CoreData
import HTTPClient
import PodcastsModule
import PodcastsGenresList
import AudioPlayerModuleiOS

final class GenresCoordinator {
    private let navigationController: UINavigationController
    private let baseURL: URL
    private let httpClient: HTTPClient
    private let localGenresLoader: LocalGenresLoader
    
    lazy var podcastsImageDataStore: PodcastsImageDataStore = {
        try! CoreDataPodcastsImageDataStore(
            storeURL: NSPersistentContainer
                .defaultDirectoryURL()
                .appendingPathComponent("best-podcasts-image-data-store.sqlite")
        )
    }()
    
    init(navigationController: UINavigationController,
         baseURL: URL,
         httpClient: HTTPClient,
         localGenresLoader: LocalGenresLoader) {
        self.navigationController = navigationController
        self.baseURL = baseURL
        self.httpClient = httpClient
        self.localGenresLoader = localGenresLoader
    }
        
    func start() {
        let controller = LargeAudioPlayerViewController(
            nibName: String(describing: LargeAudioPlayerViewController.self),
            bundle: Bundle(for: LargeAudioPlayerViewController.self)
        )
        navigationController.setViewControllers([controller], animated: false)
//        navigationController.setViewControllers([createGenres()], animated: false)
    }
    
    private func show(screen: UIViewController) {
        self.navigationController.pushViewController(screen, animated: true)
    }
    
    private func createGenres() -> UIViewController {
        let genresLoaderService = GenresLoaderService(
            baseURL: baseURL,
            httpClient: httpClient,
            localGenresLoader: localGenresLoader
        )
        return GenresUIComposer.genresComposedWith(
            loader: genresLoaderService.makeLocalGenresLoaderWithRemoteFallback,
            selection: { genre in
                let bestPodcasts = self.createBestPodcasts(byGenre: genre)
                self.show(screen: bestPodcasts)
            }
        )
    }
    
    private func createBestPodcasts(byGenre genre: Genre) -> UIViewController {
        let bestPodcastsService = BestPodcastsService(
            baseURL: baseURL,
            httpClient: httpClient,
            podcastsImageDataStore: podcastsImageDataStore
        )
        return BestPodcastsUIComposer.bestPodcastComposed(
            genreID: genre.id,
            podcastsLoader: bestPodcastsService.makeBestPodcastsRemoteLoader,
            imageLoader: bestPodcastsService.makeLocalPodcastImageDataLoaderWithRemoteFallback(for:),
            selection: { podcast in
                let podcastDetails = self.createPodcastDetails(byPodcast: podcast)
                self.show(screen: podcastDetails)
            }
        )
    }
    
    private func createPodcastDetails(byPodcast podcast: Podcast) -> UIViewController {
        let podcastDetailsService = PodcastDetailsService(
            baseURL: baseURL,
            httpClient: httpClient,
            podcastsImageDataStore: podcastsImageDataStore
        )
        return PodcastDetailsUIComposer.podcastDetailsComposedWith(
            podcastID: podcast.id,
            podcastsLoader: podcastDetailsService.makeRemotePodcastDetailsLoader,
            imageLoader: podcastDetailsService.makeRemotePodcastImageDataLoader(for:)
        )
    }
}
