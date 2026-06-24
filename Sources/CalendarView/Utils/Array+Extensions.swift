//
//  Array+Extensions.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 15.04.2025.
//

import Foundation

extension Array {
    mutating func sort<T: Comparable>(by keyPath: KeyPath<Element, T>, ascending: Bool = true) {
        self.sort { ascending ? $0[keyPath: keyPath] < $1[keyPath: keyPath] : $0[keyPath: keyPath] > $1[keyPath: keyPath] }
    }
}

extension Array {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>, ascending: Bool = true) -> [Element] {
        self.sorted { ascending ? $0[keyPath: keyPath] < $1[keyPath: keyPath] : $0[keyPath: keyPath] > $1[keyPath: keyPath] }
    }

    func sorted(
        by comparators: [(Element, Element) -> Bool?]
    ) -> [Element] {
        sorted { lhs, rhs in
            for cmp in comparators {
                if let result = cmp(lhs, rhs) {
                    return result
                }
            }
            return false
        }
    }
}

struct ArrayUtils {
    static func cmp<Element, T: Comparable>(
        _ keyPath: KeyPath<Element, T>,
        ascending: Bool = true
    ) -> (Element, Element) -> Bool? {
        { lhs, rhs in
            let l = lhs[keyPath: keyPath]
            let r = rhs[keyPath: keyPath]
            if l == r { return nil }
            return ascending ? (l < r) : (l > r)
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

extension Int: @retroactive Identifiable {
    public var id: Int {
        self
    }
}
