//
//  Color+Extensions.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 15.04.2025.
//

import SwiftUI

extension Color {
    /// Simulates the result of applying `self.opacity(opacity)` over `background`, returning a fully opaque color.
    func blended(opacity: Double) -> Color {
        // Extract RGB components (SwiftUI doesn't support this directly, so we go via UIColor)
        let fg = UIColor(self).cgColor.components ?? [0,0,0,1]
        let bg = UIColor(.white).cgColor.components ?? [0,0,0,1]

        let r = fg[0] * opacity + bg[0] * (1 - opacity)
        let g = fg[1] * opacity + bg[1] * (1 - opacity)
        let b = fg[2] * opacity + bg[2] * (1 - opacity)

        return Color(red: r, green: g, blue: b)
    }
}

extension Color: @retroactive Codable {
    private enum CodingKeys: String, CodingKey {
        case red, green, blue, opacity
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        let opacity = try container.decode(Double.self, forKey: .opacity)
        self = Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        try container.encode(Double(r), forKey: .red)
        try container.encode(Double(g), forKey: .green)
        try container.encode(Double(b), forKey: .blue)
        try container.encode(Double(a), forKey: .opacity)
    }
}
