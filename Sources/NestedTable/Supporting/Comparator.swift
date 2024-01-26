//  Created by Axel Ancona Esselmann on 1/25/24.
//

import Foundation

extension String: Comparable {
    func compare(_ element: Self) -> ComparisonResult {
        self < element ? .orderedDescending : .orderedAscending
    }
}

// TODO: add conformance for other commont types

protocol Comparable {
    func compare(_ element: Self) -> ComparisonResult
}

extension ComparisonResult {
    var reversed: ComparisonResult {
        switch self {
        case .orderedAscending: return .orderedDescending
        case .orderedSame: return .orderedSame
        case .orderedDescending: return .orderedAscending
        }
    }
}

struct Comparator<Element>: SortComparator where Element: Comparable {
    var order: SortOrder = .forward

    func compare(_ lhs: Element, _ rhs: Element) -> ComparisonResult {
        let result: ComparisonResult
        result = lhs.compare(rhs)
        return order == .forward ? result : result.reversed
    }
}

struct OptionalComparator<Element>: SortComparator where Element: Comparable {
    var order: SortOrder = .forward

    func compare(_ lhs: Element?, _ rhs: Element?) -> ComparisonResult {
        let result: ComparisonResult
        switch (lhs, rhs) {
        case (nil, nil):
            result = .orderedSame
        case (.some, nil):
            result = .orderedDescending
        case (nil, .some):
            result = .orderedAscending
        case let (lhs?, rhs?):
            result = lhs.compare(rhs)
        }
        return order == .forward ? result : result.reversed
    }
}
