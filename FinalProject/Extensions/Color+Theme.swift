import SwiftUI
import UIKit

extension Color {
    static func adaptive(light: String, dark: String) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(Color(hex: dark))
                : UIColor(Color(hex: light))
        })
    }
}

enum Theme {
    static let bgTop = Color.adaptive(light: "E8F6FF", dark: "0B1424")
    static let bgMid = Color.adaptive(light: "F0FAFF", dark: "111E33")
    static let bgBottom = Color.adaptive(light: "FFFFFF", dark: "0A1018")

    static let cardBackground = Color.adaptive(light: "FFFFFF", dark: "1E293B")
    static let cardBorder = Color.adaptive(light: "E0F2FE", dark: "334155")
    static let chipBackground = Color.adaptive(light: "E0F2FE", dark: "27374D")

    static let textPrimary = Color.adaptive(light: "0C4A6E", dark: "E0F2FE")
    static let textSecondary = Color.adaptive(light: "0369A1", dark: "7DD3FC")
    static let textMuted = Color.adaptive(light: "94A3B8", dark: "64748B")

    static let iconCircleBackground = Color.adaptive(light: "E0F7FF", dark: "1E3A5F")
    static let decorCircle1 = Color.adaptive(light: "BAE6FD", dark: "1E3A5F")
    static let decorCircle2 = Color.adaptive(light: "7DD3FC", dark: "12233A")
    static let borderLight = Color.adaptive(light: "BAE6FD", dark: "334155")
}
