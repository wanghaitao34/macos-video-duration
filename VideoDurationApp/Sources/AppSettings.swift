import SwiftUI
import Combine

enum AppLanguage: String, CaseIterable {
    case system = "system"
    case zh = "zh-Hans"
    case en = "en"

    @MainActor var displayName: String {
        switch self {
        case .system: return L10n.current.followSystem
        case .zh: return "中文"
        case .en: return "English"
        }
    }
}

enum AppAppearance: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    @MainActor var displayName: String {
        switch self {
        case .system: return L10n.current.followSystem
        case .light: return L10n.current.lightMode
        case .dark: return L10n.current.darkMode
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

@MainActor
class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @AppStorage("appLanguage") var language: AppLanguage = .system {
        didSet { objectWillChange.send() }
    }

    @AppStorage("appAppearance") var appearance: AppAppearance = .system {
        didSet { objectWillChange.send() }
    }

    var effectiveLanguage: String {
        switch language {
        case .system:
            let preferred = Locale.preferredLanguages.first ?? "en"
            return preferred.hasPrefix("zh") ? "zh-Hans" : "en"
        case .zh:
            return "zh-Hans"
        case .en:
            return "en"
        }
    }

    var l10n: L10n {
        L10n.forLanguage(effectiveLanguage)
    }
}
