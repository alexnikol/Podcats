// Copyright © 2022 Almost Engineer. All rights reserved.

import XCTest
import UIKit
import HTTPClient
import SharedComponentsiOSModule
import PodcastsGenresList
import AudioPlayerModule
import PodcastsGenresListiOS
import PodcastsModuleiOS
import AudioPlayerModuleiOS
import SearchContentModuleiOS
@testable import Podcats

final class PodcatsAcceptanceTests: XCTestCase {
    
    func test_onLaunch_displaysRemoteGenresWhenCustomerHasConnectivityAndEmptyCache() {
        let rootTabBar = launch(genresStore: InMemoryGenresStore.empty, httpClient: HTTPClientStub.online(response))
        let genres = genres(from: rootTabBar)
        
        XCTAssertEqual(genres.numberOfRenderedGenresViews(), 2)
    }
    
    func test_onLaunch_displaysNoGenresWhenCustomersHasNoConnectivityAndEmptyCache() {
        let rootTabBar = launch(genresStore: InMemoryGenresStore.empty, httpClient: HTTPClientStub.offline)
        let genres = genres(from: rootTabBar)
        
        XCTAssertEqual(genres.numberOfRenderedGenresViews(), 0)
    }
    
    func test_onLaunch_displaysCachedGenresWhenCustomerHasConnectivityAndNonExpiredCache() {
        let sharedStore = InMemoryGenresStore.withNonExpiredFeedCache
        let rootTabBar = launch(genresStore: sharedStore, httpClient: HTTPClientStub.offline)
        let genres = genres(from: rootTabBar)
        
        XCTAssertNotNil(sharedStore.cache)
        XCTAssertEqual(genres.numberOfRenderedGenresViews(), 1)
    }
    
    func test_onLaunch_doesNotDisplaysProgressPlaybackOnEmptyProgressCache() {
        let sharedStore = InMemoryGenresStore.withNonExpiredFeedCache
        let rootTabBar = launch(
            genresStore: sharedStore,
            playbackProgressStore: InMemoryPlaybackProgressStore.empty,
            httpClient: HTTPClientStub.online(response)
        )
        
        let stickyPlayer = stickyPlayer(fromRoot: rootTabBar)
        
        XCTAssertNil(stickyPlayer?.episodeTitleText())
    }
    
    func test_onLaunch_displaysCachedProgressPlayback() {
        let sharedStore = InMemoryGenresStore.withNonExpiredFeedCache
        let rootTabBar = launch(
            genresStore: sharedStore,
            playbackProgressStore: InMemoryPlaybackProgressStore.withNonEmptyCache,
            httpClient: HTTPClientStub.online(response)
        )
        
        let stickyPlayer = stickyPlayer(fromRoot: rootTabBar)
        
        XCTAssertEqual(stickyPlayer?.episodeTitleText(), "Any Episode Title")
    }
    
    func test_onEnteringBackground_deletesExpiredGenresCache() {
        let store = InMemoryGenresStore.withExpiredFeedCache
        
        enterBackground(with: store, playbackProgressStore: InMemoryPlaybackProgressStore.empty)
        
        XCTAssertNil(store.cache, "Expected to delete expired cache")
    }
    
    func test_onEnteringBackground_keepsNonExpiredFeedCache() {
        let store = InMemoryGenresStore.withNonExpiredFeedCache
        
        enterBackground(with: store, playbackProgressStore: InMemoryPlaybackProgressStore.empty)
        
        XCTAssertNotNil(store.cache, "Expected to keep non expired cache")
    }
    
    func test_onPodcastGenreSelection_displaysBestPodcasts() {
        let bestPodcasts = showBestPodcasts()
        
        XCTAssertEqual(bestPodcasts.numberOfRenderedPodcastsViews(), 2)
    }
    
    func test_onPodcastSelection_displaysPodcastDetails() {
        let bestPodcasts = showBestPodcasts()
        let podcastDetails = showPodcastDetails(fromBestPodcastsListScreen: bestPodcasts)
        
        XCTAssertEqual(podcastDetails.numberOfRenderedEpisodesViews(), 1)
    }
    
    func test_onEpisodeSelection_displaysAudioPlayer() {
        let bestPodcasts = showBestPodcasts()
        let podcastDetails = showPodcastDetails(fromBestPodcastsListScreen: bestPodcasts)
        let audioPlayer = showAudioPlayer(fromPodcastDetailsScreen: podcastDetails)
        audioPlayer.loadView()
        
        XCTAssertEqual(audioPlayer.episodeTitleText(), "Episode title")
        XCTAssertEqual(audioPlayer.episodeDescriptionText(), "Podcast  title")
    }
    
    func test_onLaunchSearch_displaysSearchScreen() {
        let rootTabBar = launch(genresStore: InMemoryGenresStore.empty, httpClient: HTTPClientStub.online(response))
        let (generalSearch, typeaheadSearch) = search(from: rootTabBar)
        
        XCTAssertEqual(generalSearch.numberOfRenderedSearchedEpisodesViews(), 0)
        XCTAssertEqual(generalSearch.numberOfRenderedSearchedPodcastsViews(), 0)
        XCTAssertEqual(generalSearch.numberOfCuratedList(), 0)
        XCTAssertEqual(typeaheadSearch.numberOfRenderedSearchTermViews(), 0)
    }
    
    func test_onLaunchSearch_displaysTypeaheadSearchResultOnTyping() {
        let rootTabBar = launch(genresStore: InMemoryGenresStore.empty, httpClient: HTTPClientStub.online(response))
        let (generalSearch, typeaheadSearch) = search(from: rootTabBar)
        let searchController = generalSearch.navigationItem.searchController
        
        searchController?.simulateUserInitiatedTyping(with: "any term")
        RunLoop.current.run(until: Date())
        
        XCTAssertEqual(typeaheadSearch.numberOfRenderedSearchTermViews(), 2)
    }
    
    func test_onLaunchSearch_displaysGeneralSearchResultOnTermSelection() {
        let rootTabBar = launch(genresStore: InMemoryGenresStore.empty, httpClient: HTTPClientStub.online(response))
        let (generalSearch, typeaheadSearch) = search(from: rootTabBar)
        let searchController = generalSearch.navigationItem.searchController
        
        searchController?.simulateUserInitiatedTyping(with: "any term")
        typeaheadSearch.simulateUserInitiatedTermSelection(at: 0)
        RunLoop.current.run(until: Date())
        
        XCTAssertEqual(generalSearch.numberOfRenderedSearchedEpisodesViews(), 1)
        XCTAssertEqual(generalSearch.numberOfRenderedSearchedPodcastsViews(), 1)
        XCTAssertEqual(generalSearch.numberOfRenderedPodcastsInCuratedList(in: 2), 2)
    }
    
    func test_onSearchedEpisodeSelection_displaysAudioPlayer() {
        let rootTabBar = launch(genresStore: InMemoryGenresStore.empty, httpClient: HTTPClientStub.online(response))
        let (generalSearch, typeaheadSearch) = search(from: rootTabBar)
        let searchController = generalSearch.navigationItem.searchController
        
        searchController?.simulateUserInitiatedTyping(with: "any term")
        typeaheadSearch.simulateUserInitiatedTermSelection(at: 0)
        RunLoop.current.run(until: Date())
        
        let audioPlayer = showAudioPlayer(fromGeneralSearchResult: generalSearch)
        audioPlayer.loadViewIfNeeded()
        
        XCTAssertEqual(audioPlayer.episodeTitleText(), "Any Found Episode Title")
        XCTAssertEqual(audioPlayer.episodeDescriptionText(), "Any Podcast name | Any Publisher name")
    }
    
    func test_onSearchedPodcastSelection_displaysPodcastDetails() {
        let rootTabBar = launch(genresStore: InMemoryGenresStore.empty, httpClient: HTTPClientStub.online(response))
        let (generalSearch, typeaheadSearch) = search(from: rootTabBar)
        let searchController = generalSearch.navigationItem.searchController
        
        searchController?.simulateUserInitiatedTyping(with: "any term")
        typeaheadSearch.simulateUserInitiatedTermSelection(at: 0)
        RunLoop.current.run(until: Date())
        
        let podcastDetails = showPodcastDetails(fromGeneralSearchResult: generalSearch)
        let podcastHeader = podcastDetails.podcastHeader()
        
        XCTAssertNotNil(podcastHeader)
    }
    
    func test_onSearchedPodcastDetailsEpisodeSelection_displaysLargePlayerFromEpisodeInsideSearchedPodcast() {
        let rootTabBar = launch(genresStore: InMemoryGenresStore.empty, httpClient: HTTPClientStub.online(response))
        let (generalSearch, typeaheadSearch) = search(from: rootTabBar)
        let searchController = generalSearch.navigationItem.searchController
        
        searchController?.simulateUserInitiatedTyping(with: "any term")
        typeaheadSearch.simulateUserInitiatedTermSelection(at: 0)
        RunLoop.current.run(until: Date())
        
        let podcastDetails = showPodcastDetails(fromGeneralSearchResult: generalSearch)
        
        let audioPlayer = showAudioPlayer(fromPodcastDetailsScreen: podcastDetails)
        audioPlayer.loadViewIfNeeded()
        
        XCTAssertEqual(audioPlayer.episodeTitleText(), "Any Episode Title")
        XCTAssertEqual(audioPlayer.episodeDescriptionText(), "Any Podcast Details Title | Any Publisher")
    }
    
    // MARK: - Helpers
    
    private func launch(
        genresStore: GenresStore,
        playbackProgressStore: PlaybackProgressStore = InMemoryPlaybackProgressStore.empty,
        httpClient: HTTPClient,
        file: StaticString = #file,
        line: UInt = #line
    ) -> RootTabBarController {
        let sut = SceneDelegate(httpClient: httpClient, genresStore: genresStore, playbackProgressStore: playbackProgressStore)
        sut.window = UIWindow()
        sut.configureWindow()
        
        let tabBar = sut.window?.rootViewController as! RootTabBarController
        return tabBar
    }
    
    private func genres(from tabBar: RootTabBarController) -> GenresListViewController {
        let nav = tabBar.viewControllers?.first as? UINavigationController
        let genres = nav?.topViewController as! GenresListViewController
        return genres
    }
    
    private func enterBackground(with store: InMemoryGenresStore, playbackProgressStore: PlaybackProgressStore) {
        let sut = SceneDelegate(httpClient: HTTPClientStub.offline, genresStore: store, playbackProgressStore: playbackProgressStore)
        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
    }
    
    private func response(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }
    
    private func showBestPodcasts() -> ListViewController {
        let rootTabBar = launch(genresStore: InMemoryGenresStore.empty, httpClient: HTTPClientStub.online(response))
        let genres = genres(from: rootTabBar)
        
        genres.simulateTapOnGenre(at: 0)
        RunLoop.current.run(until: Date())
        
        let nav = genres.navigationController
        return nav?.topViewController as! ListViewController
    }
    
    private func showPodcastDetails(fromBestPodcastsListScreen bestPodcastsListScreen: ListViewController) -> ListViewController {
        bestPodcastsListScreen.simulateTapOnPodcast(at: 0)
        RunLoop.current.run(until: Date())
        
        let nav = bestPodcastsListScreen.navigationController
        return nav?.topViewController as! ListViewController
    }
    
    private func showPodcastDetails(fromGeneralSearchResult generalSearchResult: ListViewController) -> ListViewController {
        generalSearchResult.simulateUserInitiatedSearchedPodcastSelection(at: 0)
        RunLoop.current.run(until: Date())
        
        let nav = generalSearchResult.navigationController
        return nav?.topViewController as! ListViewController
    }
    
    private func showAudioPlayer(fromPodcastDetailsScreen podcastDetailsScreen: ListViewController) -> LargeAudioPlayerViewController {
        podcastDetailsScreen.simulateTapOnEpisode(at: 0)
        RunLoop.current.run(until: Date())
        
        let nav = podcastDetailsScreen.navigationController
        return nav?.presentedViewController as! LargeAudioPlayerViewController
    }
    
    private func showAudioPlayer(fromGeneralSearchResult generalSearchResult: ListViewController) -> LargeAudioPlayerViewController {
        generalSearchResult.simulateUserInitiatedSearchedEpisodeSelection(at: 0)
        RunLoop.current.run(until: Date())
        
        let nav = generalSearchResult.navigationController
        return nav?.presentedViewController as! LargeAudioPlayerViewController
    }
    
    private func stickyPlayer(fromRoot root: RootTabBarController) -> StickyAudioPlayerViewController? {
        root.stickyAudioPlayerController
    }
    
    private func search(
        from tabBar: RootTabBarController
    ) -> (generalSearch: ListViewController, typeaheadSearch: TypeaheadListViewController) {
        let nav = tabBar.viewControllers?[1] as? UINavigationController
        let generalSearch = nav?.topViewController as! ListViewController
        let searchController = generalSearch.navigationItem.searchController
        let typeaheadSearch = searchController?.searchResultsController as! TypeaheadListViewController
        return (generalSearch, typeaheadSearch)
    }
    
    private func makeData(for url: URL) -> Data {
        let baseURL = "https://listen-api-test.listennotes.com"
        switch url.absoluteString {
        case "\(baseURL)/api/v2/genres":
            return makeGenresData()
            
        case "\(baseURL)/api/v2/best_podcasts?genre_id=1":
            return makeBestPodcastsData()
            
        case "\(baseURL)/api/v2/podcasts/unique_podcast_id":
            return makePodcastDetailsData()
            
        case "\(baseURL)/api/v2/typeahead?q=any%20term":
            return makeTypeaheadSearchData()
            
        case "\(baseURL)/api/v2/search?q=Any%20term%201":
            return makeGeneralSearchData()
            
        default:
            return Data()
        }
    }
    
    private func makeGenresData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["genres": [
            ["id": 1, "name": "Any Genre 1"],
            ["id": 2, "name": "Any Genre 2"]
        ]])
    }
    
    private func makeBestPodcastsData() -> Data {
        return try! JSONSerialization.data(withJSONObject: [
            "id": 1,
            "name": "Any Genre name",
            "podcasts": [
                [
                    "id": "unique_podcast_id",
                    "title": "Any Podcast name",
                    "publisher": "Any Publisher name",
                    "type": "episodic",
                    "image": "https://any-url.com/image1",
                    "language": "English"
                ],
                [
                    "id": UUID().uuidString,
                    "title": "Another Podcast name",
                    "publisher": "Another Publisher name",
                    "type": "serial",
                    "image": "https://any-url.com/image1",
                    "language": "Ukranian"
                ]
            ]])
    }
    
    private func makePodcastDetailsData() -> Data {
        return try! JSONSerialization.data(withJSONObject: [
            "id": UUID().uuidString,
            "title": "Any Podcast Details Title",
            "publisher": "Any Publisher",
            "language": "Any Language",
            "type": "serial",
            "image": "https://any-url.com/image",
            "episodes": [
                [
                    "id": UUID().uuidString,
                    "title": "Any Episode Title",
                    "description": "Any Description",
                    "thumbnail": "https://any-url.com/thumbnail",
                    "audio": "https://any-url.com/audio",
                    "audio_length_sec": 300,
                    "explicit_content": true,
                    "pub_date_ms": 12312312332
                ]
            ],
            "description": "Any Description",
            "total_episodes": 200
        ])
    }
    
    private func makeTypeaheadSearchData() -> Data {
        return try! JSONSerialization.data(withJSONObject: [
            "terms": [
                "Any term 1",
                "Any term 2"
            ],
            "genres": [],
            "podcasts": []
        ])
    }
    
    private func makeGeneralSearchData() -> Data {
        return try! JSONSerialization.data(withJSONObject: [
            "results": [
                [
                    "id": UUID().uuidString,
                    "title_original": "Any Found Episode Title",
                    "description_original": "Any Found Description",
                    "thumbnail": "https://any-url.com/thumbnail",
                    "audio": "https://any-url.com/audio",
                    "audio_length_sec": 300,
                    "explicit_content": true,
                    "pub_date_ms": 12312312332,
                    "podcast": [
                        "id": "unique_podcast_id",
                        "title_original": "Any Podcast name",
                        "publisher_original": "Any Publisher name",
                        "image": "https://any-url.com/image1",
                        "thumbnail": "https://another-url.com/image1"
                    ]
                ],
                [
                    "id": "unique_podcast_id",
                    "title_original": "Any Podcast name",
                    "publisher_original": "Any Publisher name",
                    "image": "https://any-url.com/image1",
                    "thumbnail": "https://another-url.com/image1"
                ],
                [
                    "id": UUID().uuidString,
                    "title_original": "Curated list 1",
                    "description_original": "Curated description 1",
                    "podcasts": [
                        [
                            "id": "unique_podcast_id2",
                            "title_original": "Any Podcast name",
                            "publisher_original": "Any Publisher name",
                            "image": "https://any-url.com/image1",
                            "thumbnail": "https://another-url.com/image1"
                        ],
                        [
                            "id": "unique_podcast_id2",
                            "title_original": "Any Podcast name",
                            "publisher_original": "Any Publisher name",
                            "image": "https://any-url.com/image1",
                            "thumbnail": "https://another-url.com/image1"
                        ]
                    ]
                ]
            ]
        ])
    }
}
