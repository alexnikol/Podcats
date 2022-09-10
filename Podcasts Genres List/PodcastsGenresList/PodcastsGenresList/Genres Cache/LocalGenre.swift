// Copyright © 2022 Almost Engineer. All rights reserved.

import Foundation

public struct LocalGenre: Equatable, Codable {
    let id: Int
    let name: String
    
    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}
