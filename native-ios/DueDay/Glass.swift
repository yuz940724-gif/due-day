import SwiftUI
import UIKit

extension Color {
    static let canvas = adaptive(
        light: UIColor(red: 0.961, green: 0.953, blue: 0.929, alpha: 1),
        dark: UIColor(red: 0.035, green: 0.051, blue: 0.043, alpha: 1)
    )
    static let surface = adaptive(
        light: UIColor(red: 0.988, green: 0.984, blue: 0.969, alpha: 1),
        dark: UIColor(red: 0.075, green: 0.102, blue: 0.090, alpha: 1)
    )
    static let ink = adaptive(
        light: UIColor(red: 0.090, green: 0.137, blue: 0.118, alpha: 1),
        dark: UIColor(red: 0.925, green: 0.949, blue: 0.937, alpha: 1)
    )
    static let muted = adaptive(
        light: UIColor(red: 0.408, green: 0.451, blue: 0.427, alpha: 1),
        dark: UIColor(red: 0.660, green: 0.710, blue: 0.686, alpha: 1)
    )
    static let accent = adaptive(
        light: UIColor(red: 0.122, green: 0.416, blue: 0.314, alpha: 1),
        dark: UIColor(red: 0.330, green: 0.780, blue: 0.610, alpha: 1)
    )
    static let soft = adaptive(
        light: UIColor(red: 0.863, green: 0.922, blue: 0.894, alpha: 1),
        dark: UIColor(red: 0.110, green: 0.220, blue: 0.174, alpha: 1)
    )
    static let danger = adaptive(
        light: UIColor(red: 0.769, green: 0.373, blue: 0.294, alpha: 1),
        dark: UIColor(red: 0.950, green: 0.480, blue: 0.400, alpha: 1)
    )
    static let warning = adaptive(
        light: UIColor(red: 0.780, green: 0.545, blue: 0.212, alpha: 1),
        dark: UIColor(red: 0.950, green: 0.700, blue: 0.320, alpha: 1)
    )

    private static func adaptive(light: UIColor, dark: UIColor) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }
}
