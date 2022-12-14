// Copyright © 2022 Almost Engineer. All rights reserved.

import XCTest
import SharedTestHelpersLibrary
import PodcastsGenresList
import PodcastsGenresListiOS
import SharedComponentsiOSModule
import LoadResourcePresenter

final class GenresUISnapshotTests: XCTestCase {
    
    func test_emptyGenres() {
        let (sut, _) = makeSUT()
        
        sut.display(emptyGenres())
        
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .light)), named: "EMPTY_GENRES_light")
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .dark)), named: "EMPTY_GENRES_dark")
    }
    
    func test_genresContent() {
        let (sut, _) = makeSUT()
        
        sut.display(genresContent())

        assert(snapshot: sut.snapshot(for: .iPhone14(style: .light)), named: "GENRES_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .dark)), named: "GENRES_WITH_CONTENT_dark")
    }
    
    func test_highlightedGenreViewState() {
        let (sut, _) = makeSUT()
        
        sut.display(genresContent())
        
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .light)), named: "GENRES_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .dark)), named: "GENRES_WITH_CONTENT_dark")
        
        sut.simulateGenreHighlightState(at: 0, isHighlight: true)
        
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .light)), named: "GENRE_VIEW_HIGHLIGHTED_STATE_light")
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .dark)), named: "GENRE_VIEW_HIGHLIGHTED_STATE_dark")
        
        sut.simulateGenreHighlightState(at: 0, isHighlight: false)
        
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .light)), named: "GENRES_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .dark)), named: "GENRES_WITH_CONTENT_dark")
    }
    
    func test_genresLoadingStateWithNoContent() {
        let (sut, loadingView) = makeSUT()
        
        loadingView.display(.init(isLoading: true))

        assert(snapshot: sut.snapshot(for: .iPhone14(style: .light)), named: "GENRES_LOADING_STATE_NO_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .dark)), named: "GENRES_LOADING_STATE_NO_CONTENT_dark")
        
        loadingView.display(.init(isLoading: false))
        
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .light)), named: "GENRES_NOT_LOADING_STATE_NO_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .dark)), named: "GENRES_NOT_LOADING_STATE_NO_CONTENT_dark")
    }
    
    func test_genresLoadingStateWithContent() {
        let (sut, loadingView) = makeSUT()
        
        sut.display(genresContent())
        
        loadingView.display(.init(isLoading: true))
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .light)), named: "GENRES_LOADING_STATE_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .dark)), named: "GENRES_LOADING_STATE_WITH_CONTENT_dark")
        
        loadingView.display(.init(isLoading: false))
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .light)), named: "GENRES_NOT_LOADING_STATE_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone14(style: .dark)), named: "GENRES_NOT_LOADING_STATE_WITH_CONTENT_dark")
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: GenresListViewController, loadingView: ResourceLoadingView) {
        let genresRefreshDelegate = RefreshViewControllerSpyDelegate()
        let refreshController = RefreshViewController(delegate: genresRefreshDelegate)
        let controller = GenresListViewController(refreshController: refreshController)
        controller.loadViewIfNeeded()
        return (controller, refreshController)
    }
    
    private func emptyGenres() -> [GenreCellController] {
        return []
    }
    
    private func genresContent() -> [GenreCellController] {
        return [
            GenreCellController(model: GenreCellViewModel(name: "Genre 1", color: .red), selection: {}),
            GenreCellController(model: GenreCellViewModel(name: "Genre 2", color: .green), selection: {}),
            GenreCellController(model: GenreCellViewModel(name: "Genre 3", color: .blue), selection: {}),
            GenreCellController(model: GenreCellViewModel(name: "Genre 4", color: .orange), selection: {}),
            GenreCellController(model: GenreCellViewModel(name: "Genre 5", color: .yellow), selection: {})
        ]
    }
    
    private class RefreshViewControllerSpyDelegate: RefreshViewControllerDelegate {
        func didRequestLoading() {}
        func didRequestCancel() {}
    }
}
