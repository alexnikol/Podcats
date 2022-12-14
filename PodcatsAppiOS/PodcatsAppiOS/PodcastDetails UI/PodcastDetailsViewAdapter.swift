// Copyright © 2022 Almost Engineer. All rights reserved.

import Foundation
import SharedComponentsiOSModule
import Combine
import PodcastsModule
import PodcastsModuleiOS
import LoadResourcePresenter
import UIKit

final class PodcastDetailsViewAdapter: ResourceView {
    typealias ResourceViewModel = PodcastDetailsViewModel
    
    private let imageLoader: (URL) -> AnyPublisher<Data, Error>
    private var cancellable: AnyCancellable?
    private let episodesPresenter = EpisodesPresenter()
    weak var controller: ListViewController?
    private var selection: (Episode) -> Void
    
    init(
        controller: ListViewController,
        imageLoader: @escaping (URL) -> AnyPublisher<Data, Error>,
        selection: @escaping (Episode) -> Void
    ) {
        self.controller = controller
        self.imageLoader = imageLoader
        self.selection = selection
    }
    
    func display(_ viewModel: PodcastDetailsViewModel) {
        let episodeCellControllers = viewModel.episodes.map(configureEpisodeCellController)
                
        let thumbnailViewController = ThumbnailUIComposer.composeThumbnailWithImageLoader(
            thumbnailURL: viewModel.image,
            imageLoader: imageLoader
        )
        
        let profileSection = PodcastHeaderCellController(
            cellControllers: episodeCellControllers,
            viewModel: viewModel,
            thumbnailViewController: thumbnailViewController
        )
                
        controller?.display([profileSection])
        controller?.title = viewModel.title
    }
    
    private func configureEpisodeCellController(for episode: Episode) -> EpisodeCellController {
        let episodeViewModel = episodesPresenter.map(episode)
        return EpisodeCellController(
            viewModel: episodeViewModel,
            selection: { [weak self] in
                self?.selection(episode)
            }
        )
    }
}
