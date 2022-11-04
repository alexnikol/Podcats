// Copyright © 2022 Almost Engineer. All rights reserved.

import XCTest
import BestPodcastsList

class BestPodcastsPresenterTests: XCTestCase {
    
    func test_map_createsViewModel() {
        let podcast1 = makePodcast(title: "Podcast name 1", image: anyURL(), type: .episodic)
        let podcast2 = makePodcast(title: "Podcast name 2", image: anyURL(), type: .serial)
        let podcastsList = makeBestPodcastsList(genreId: 1, genreName: "Any Genre Name", podcasts: [podcast1, podcast2])
        
        let viewModel = BestPodcastsPresenter.map(podcastsList)
        XCTAssertEqual(podcastsList.genreName, viewModel.title)
        
        for index in 0..<2 {
            XCTAssertEqual(podcastsList.podcasts[index].title, viewModel.podcasts[index].title)
            XCTAssertEqual(podcastsList.podcasts[index].publisher, viewModel.podcasts[index].publisher)
            XCTAssertEqual(podcastsList.podcasts[index].language, viewModel.podcasts[index].languageValueLabel)
            XCTAssertEqual(podcastsList.podcasts[index].image, viewModel.podcasts[index].image)
            XCTAssertEqual(String(describing: podcastsList.podcasts[index].type), viewModel.podcasts[index].typeValueLabel)
        }
    }
    
    // MARK: - Helpers
    
    private func makePodcast(title: String, image: URL, type: PodcastType) -> Podcast {
        Podcast(id: UUID().uuidString, title: title, publisher: "Any Publisher", language: "English", type: type, image: image)
    }
        
    private func makeBestPodcastsList(genreId: Int = 1, genreName: String = "Any genre name", podcasts: [Podcast]) -> BestPodcastsList {
        BestPodcastsList(genreId: genreId, genreName: genreName, podcasts: podcasts)
    }
    
    func anyURL() -> URL {
        URL(string: "http://a-url.com")!
    }
}