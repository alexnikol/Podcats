// Copyright © 2022 Almost Engineer. All rights reserved.

import XCTest
import PodcastsModule
import PodcastsModuleiOS
@testable import Podcats

class PodcastDetailsUIIngtegrationTests: XCTestCase {
    
    func test_loadPodcastDetailsActions_requestPodcastDetails() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedListReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiates a load")
        
        sut.simulateUserInitiatedListReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected a third loading request once user initiates a load")
    }
    
    func test_loadPodcastDetailsIndicator_isVisibleWhileLoadingPodcastDetails() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowinLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completePodcastDetailsLoading(at: 0)
        XCTAssertFalse(sut.isShowinLoadingIndicator, "Expected no loading indicator once loading is complete succesfully")
        
        sut.simulateUserInitiatedListReload()
        XCTAssertTrue(sut.isShowinLoadingIndicator, "Expected loading indicator once user initiates a reload")
        
        loader.completePodcastDetailsLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowinLoadingIndicator, "Expected no loading indicator once loading is completes with error")
    }
    
    func test_loadPodcastDetailsCompletion_rendersSuccessfullyLoadedPodcastDetails() {
        let uniquePodcastDetails1 = makeUniquePodcastDetails(episodes: makeUniqueEpisodes())
        let uniquePodcastDetails2 = makeUniquePodcastDetails(episodes: makeUniqueEpisodes())
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        assertThat(sut, isRendering: String())
        
        loader.completePodcastDetailsLoading(with: uniquePodcastDetails1, at: 0)
        assertThat(sut, isRendering: uniquePodcastDetails1.episodes)
        assertThat(sut, isRendering: uniquePodcastDetails1.title)
        
        sut.simulateUserInitiatedListReload()
        loader.completePodcastDetailsLoading(with: uniquePodcastDetails2, at: 1)
        assertThat(sut, isRendering: uniquePodcastDetails2.episodes)
        assertThat(sut, isRendering: uniquePodcastDetails2.title)
    }
    
    func test_loadPodcastDetailsCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let uniquePodcastDetails = makeUniquePodcastDetails(episodes: makeUniqueEpisodes())

        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completePodcastDetailsLoading(with: uniquePodcastDetails, at: 0)
        assertThat(sut, isRendering: uniquePodcastDetails.episodes)
        assertThat(sut, isRendering: uniquePodcastDetails.title)
        
        sut.simulateUserInitiatedListReload()
        loader.completePodcastDetailsLoadingWithError(at: 1)
        assertThat(sut, isRendering: uniquePodcastDetails.episodes)
        assertThat(sut, isRendering: uniquePodcastDetails.title)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        podcastID: String = UUID().uuidString,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: ListViewController, loader: PodcastDetailsLoaderSpy) {
        let loader = PodcastDetailsLoaderSpy()
        let sut = PodcastDetailsUIComposer.podcastDetailsComposedWith(
            podcastID: podcastID,
            podcastsLoader: loader.podcastDetailsPublisher,
            imageLoader: loader.imageDataPublisher
        )
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }
    
    private func assertThat(_ sut: ListViewController, isRendering episodes: [Episode], file: StaticString = #file, line: UInt = #line) {
        guard sut.numberOfRenderedEpisodesViews() == episodes.count else {
            return XCTFail("Expected \(episodes.count) rendered episodes, got \(sut.numberOfRenderedEpisodesViews()) rendered views instead")
        }
        
        episodes.enumerated().forEach { index, episode in
            assertThat(sut, hasViewConfiguredFor: episode, at: index, file: file, line: line)
        }
    }
    
    private func assertThat(
        _ sut: ListViewController,
        hasViewConfiguredFor episode: Episode,
        at index: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let episodeViewModel = EpisodesPresenter().map(episode)
        let view = sut.episodeView(at: index)
        XCTAssertNotNil(view, file: file, line: line)
        XCTAssertEqual(view?.titleText, episodeViewModel.title, "Wrong title at index \(index)", file: file, line: line)
        XCTAssertEqual(view?.descriptionText, episodeViewModel.description, "Wrong description at index \(index)", file: file, line: line)
        XCTAssertEqual(view?.audoLengthText, episodeViewModel.displayAudioLengthInSeconds, "Wrong audio length at index \(index)", file: file, line: line)
        XCTAssertEqual(view?.publishDateText, episodeViewModel.displayPublishDate, "Wrong publish date at index \(index)", file: file, line: line)
    }
    
    private func assertThat(_ sut: ListViewController, isRendering title: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(sut.title ?? "", title)
    }
    
    private func makeEpisode(
        id: String,
        title: String,
        description: String,
        thumbnail: URL,
        audio: URL,
        audioLengthInSeconds: Int,
        containsExplicitContent: Bool,
        publishDateInMiliseconds: Int
    ) -> Episode {
        Episode(
            id: id,
            title: title,
            description: description,
            thumbnail: thumbnail,
            audio: audio,
            audioLengthInSeconds: audioLengthInSeconds,
            containsExplicitContent: containsExplicitContent,
            publishDateInMiliseconds: publishDateInMiliseconds
        )
    }
    
    private func makeUniqueEpisodes() -> [Episode] {
        let episode1 = makeEpisode(
            id: UUID().uuidString,
            title: "Any Title 1",
            description: "Any Description 1",
            thumbnail: anyURL(),
            audio: anyURL(),
            audioLengthInSeconds: Int.random(in: 1...1000),
            containsExplicitContent: Bool.random(),
            publishDateInMiliseconds: Int.random(in: 1479110302015...1479110402015)
        )
        
        let episode2 = makeEpisode(
            id: UUID().uuidString,
            title: "Any Title 2",
            description: "Any Description 2",
            thumbnail: anyURL(),
            audio: anyURL(),
            audioLengthInSeconds: Int.random(in: 1...1000),
            containsExplicitContent: Bool.random(),
            publishDateInMiliseconds: Int.random(in: 1479110302015...1479110402015)
        )
        return [episode1, episode2]
    }
    
    private func makeUniquePodcastDetails(
        episodes: [Episode]
    ) -> PodcastDetails {
        PodcastDetails(
            id: UUID().uuidString,
            title: "Any Title",
            publisher: "Any Publisher",
            language: "Any Language",
            type: .episodic,
            image: anyURL(),
            episodes: episodes,
            description: "Any Description",
            totalEpisodes: Int.random(in: 1...1000)
        )
    }
}