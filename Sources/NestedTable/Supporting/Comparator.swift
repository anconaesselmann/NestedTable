//  Created by Axel Ancona Esselmann on 1/25/24.
//

import Foundation

extension String: Comparable {
    public func compare(_ element: Self) -> ComparisonResult {
        self < element ? .orderedDescending : .orderedAscending
    }
}

// TODO: add conformance for other commont types

public protocol Comparable {
    func compare(_ element: Self) -> ComparisonResult
}

public extension ComparisonResult {
    var reversed: ComparisonResult {
        switch self {
        case .orderedAscending: return .orderedDescending
        case .orderedSame: return .orderedSame
        case .orderedDescending: return .orderedAscending
        }
    }
}

public struct Comparator<Element>: SortComparator where Element: Comparable {
    public var order: SortOrder = .forward

    public func compare(_ lhs: Element, _ rhs: Element) -> ComparisonResult {
        let result: ComparisonResult
        result = lhs.compare(rhs)
        return order == .forward ? result : result.reversed
    }
}

public struct OptionalComparator<Element>: SortComparator where Element: Comparable {
    public var order: SortOrder = .forward

    public func compare(_ lhs: Element?, _ rhs: Element?) -> ComparisonResult {
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
