// Copyright © 2022 Almost Engineer. All rights reserved.

import UIKit
import Combine
import PodcastsGenresList
import PodcastsGenresListiOS

final class GenresUIComposer {
    
    private init() {}
    
    static func genresComposedWith(loader: @escaping () -> GenresLoader.Publisher) -> GenresListViewController {        
        let presentationAdapter = GenresLoaderPresentationAdapter(genresLoader: loader)
        let refreshController = GenresRefreshViewController(delegate: presentationAdapter)
        let genresController = GenresListViewController(refreshController: refreshController)
        genresController.title = GenresPresenter.title
        
        presentationAdapter.presenter = GenresPresenter(
            genresView: GenresViewAdapter(
                controller: genresController,
                genresColorProvider: makeGenresColorProvider()
            ),
            loadingView: WeakRefVirtualProxy(refreshController)
        )
        return genresController
    }
    
    private static func makeGenresColorProvider() -> GenresActiveColorProvider<UIColor> {
        let genresActiveColorProvider = GenresActiveColorProvider(colorConverted: { UIColor(hexString: $0) })
        do {
            try genresActiveColorProvider.setColors(
                ["#e6194b", "#3cb44b", "#ffe119", "#4363d8",
                 "#f58231", "#911eb4", "#46f0f0", "#f032e6",
                 "#bcf60c", "#fabebe", "#008080", "#e6beff",
                 "#9a6324", "#fffac8", "#800000", "#aaffc3",
                 "#808000", "#ffd8b1", "#000075", "#808080",
                 "#E574BC", "#EF94D5", "#F9B4ED", "#EABAF6",
                 "#DABFFF", "#C4C7FF", "#ADCFFF", "#96D7FF",
                 "#7FDEFF", "#FFC8DD", "#FF70A5", "#BDE0FE",
                 "#99CEFF", "#FFC8DD", "#FFAFCC", "#BDE0FE",
                 "#A2D2FF", "#EA84C9"]
            )
        } catch {
            fatalError("Unexpected colors set with error \(error)")
        }
        return genresActiveColorProvider
    }
}

extension GenresLoader {
    typealias Publisher = AnyPublisher<[Genre], Error>
    
    func loadPublisher() -> Publisher {
        Deferred {
            Future(load)
        }.eraseToAnyPublisher()
    }
}

extension Publisher {
    func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {        
        self.catch { _ in fallbackPublisher() }.eraseToAnyPublisher()
    }
}

extension Publisher where Output == [Genre] {
    func caching(to cache: GenresCache) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: { genres in
            cache.save(genres, completion: { _ in })
        }).eraseToAnyPublisher()
    }
}
