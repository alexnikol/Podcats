// Copyright © 2022 Almost Engineer. All rights reserved.

import Foundation

public struct PodcastImageViewModel {
    public let title: String
    public let publisher: String
    public let languageStaticLabel: String
    public let languageValueLabel: String
    public let typeStaticLabel: String
    public let typeValueLabel: String
    public let image: URL
    
    public init(title: String,
                publisher: String,
                languageStaticLabel: String,
                languageValueLabel: String,
                typeStaticLabel: String,
                typeValueLabel: String,
                image: URL) {
        self.title = title
        self.publisher = publisher
        self.languageStaticLabel = languageStaticLabel
        self.languageValueLabel = languageValueLabel
        self.typeStaticLabel = typeStaticLabel
        self.typeValueLabel = typeValueLabel
        self.image = image
    }
}
