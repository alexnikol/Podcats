// Copyright © 2022 Almost Engineer. All rights reserved.

import Foundation

final class GenresCachePolicy {
    
    private init() {}
    
    private static let calendar = Calendar(identifier: .gregorian)
        
    private static var maxCacheAgeInDays: Int {
        return 7
    }
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}
