// Copyright © 2022 Almost Engineer. All rights reserved.

import UIKit
import Combine
import LoadResourcePresenter
import SharedComponentsiOSModule
import PodcastsModule
import PodcastsModuleiOS

public enum BestPodcastsUIComposer {
    
    public static func bestPodcastComposed(
        genreID: Int,
        podcastsLoader: @escaping (Int) -> AnyPublisher<BestPodcastsList, Error>,
        imageLoader: @escaping (URL) -> AnyPublisher<Data, Error>,
        selection: @escaping (Podcast) -> Void
    ) -> ListViewController {
        let presentationAdapter = GenericLoaderPresentationAdapter<BestPodcastsList, BestPodcastsViewAdapter>(
            loader: { podcastsLoader(genreID) }
        )
        let refreshController = RefreshViewController(delegate: presentationAdapter)
        let controller = ListViewController(refreshController: refreshController)
        
        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: BestPodcastsViewAdapter(
                controller: controller,
                imageLoader: imageLoader,
                selection: selection
            ),
            loadingView: WeakRefVirtualProxy(refreshController),
            errorView: WeakRefVirtualProxy(refreshController),
            mapper: BestPodcastsPresenter.map
        )
        return controller
    }
}
