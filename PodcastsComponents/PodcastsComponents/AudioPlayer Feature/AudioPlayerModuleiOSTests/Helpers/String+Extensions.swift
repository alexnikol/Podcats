// Copyright © 2022 Almost Engineer. All rights reserved.

import Foundation

extension String {
    func repeatTimes(_ times: Int) -> String {
        return String(repeating: self + " ", count: times)
    }
}
