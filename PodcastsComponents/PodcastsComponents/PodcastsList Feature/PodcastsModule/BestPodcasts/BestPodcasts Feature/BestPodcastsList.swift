// Copyright © 2022 Almost Engineer. All rights reserved.

import Foundation

public struct BestPodcastsList: Equatable {
    public let genreId: Int
    public let genreName: String
    public let podcasts: [Podcast]
    
    public init(genreId: Int, genreName: String, podcasts: [Podcast]) {
        self.genreId = genreId
        self.genreName = genreName
        self.podcasts = podcasts
    }
}
