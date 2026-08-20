import SwiftUI
import UIKit

enum AppAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: "跟随系统"
        case .light: "浅色"
        case .dark: "深色"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

extension Color {
    static let canvas = Color(uiColor: .systemBackground)
    static let surface = Color(uiColor: .secondarySystemBackground)
    static let elevatedSurface = Color(uiColor: .tertiarySystemBackground)
    static let ink = Color(uiColor: .label)
    static let muted = Color(uiColor: .secondaryLabel)
    static let accent = adaptive(
        light: UIColor(red: 0.122, green: 0.416, blue: 0.314, alpha: 1),
        dark: UIColor(red: 0.330, green: 0.780, blue: 0.610, alpha: 1)
    )
    static let soft = Color(uiColor: .secondarySystemFill)
    static let divider = Color(uiColor: .separator)
    static let heroSurface = adaptive(
        light: UIColor(red: 0.055, green: 0.165, blue: 0.125, alpha: 1),
        dark: UIColor(red: 0.063, green: 0.243, blue: 0.180, alpha: 1)
    )
    static let heroText = adaptive(
        light: UIColor(red: 0.949, green: 0.969, blue: 0.957, alpha: 1),
        dark: UIColor(red: 0.949, green: 0.969, blue: 0.957, alpha: 1)
    )
    static let heroMutedText = adaptive(
        light: UIColor(red: 0.730, green: 0.790, blue: 0.758, alpha: 1),
        dark: UIColor(red: 0.760, green: 0.850, blue: 0.810, alpha: 1)
    )
    static let danger = Color(uiColor: .systemRed)
    static let dangerSurface = adaptive(
        light: UIColor(red: 0.545, green: 0.220, blue: 0.176, alpha: 1),
        dark: UIColor(red: 0.345, green: 0.125, blue: 0.106, alpha: 1)
    )
    static let warning = Color(uiColor: .systemOrange)

    private static func adaptive(light: UIColor, dark: UIColor) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }
}
