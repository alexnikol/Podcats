// Copyright © 2022 Almost Engineer. All rights reserved.

import XCTest
import SharedTestHelpersLibrary
import SearchContentModule
import PodcastsGenresList

final class TypeheadSearchContentPresentationTests: XCTestCase {
    
    func test_createsViewModel() {
        let terms = uniqueTerms()
        let genres = uniqueGenres()
        let podcasts = uniquePodcastSearchResults()
        let domainModel = TypeheadSearchContentResult(terms: terms, genres: genres, podcasts: podcasts)
        
        let generalViewModel = TypeheadSearchContentPresenter.map(domainModel)
        let termsViewModels = domainModel.terms.map(TypeheadSearchContentPresenter.map)
        let genresViewModels = domainModel.genres.map(TypeheadSearchContentPresenter.map)
        let podcastsViewModels = domainModel.podcasts.map(TypeheadSearchContentPresenter.map)
        
        XCTAssertEqual(generalViewModel.terms, domainModel.terms)
        XCTAssertEqual(generalViewModel.podcasts, domainModel.podcasts)
        XCTAssertEqual(generalViewModel.genres, domainModel.genres)
        XCTAssertEqual(termsViewModels, terms)
        XCTAssertEqual(genresViewModels, ["Any genre 1", "Any genre 2"])
        assert(
            receivedViewModel: podcastsViewModels[0],
            expectedViewModel: TypeheadSearchResultPodcastViewModel(
                titleOriginal: "Title",
                publisherOriginal: "Publisher",
                thumbnail: anyURL()
            )
        )
        assert(
            receivedViewModel: podcastsViewModels[1],
            expectedViewModel: TypeheadSearchResultPodcastViewModel(
                titleOriginal: "Another Title",
                publisherOriginal: "Another Publisher",
                thumbnail: anyURL()
            )
        )
    }
    
    // MARK: - Helpers
    
    private func assert(
        receivedViewModel: TypeheadSearchResultPodcastViewModel,
        expectedViewModel: TypeheadSearchResultPodcastViewModel,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(receivedViewModel.titleOriginal, expectedViewModel.titleOriginal, file: file, line: line)
        XCTAssertEqual(receivedViewModel.publisherOriginal, expectedViewModel.publisherOriginal, file: file, line: line)
        XCTAssertEqual(receivedViewModel.thumbnail, expectedViewModel.thumbnail, file: file, line: line)
    }
}