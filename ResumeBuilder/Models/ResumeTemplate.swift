import UIKit

enum ResumeTemplate: String, Codable, CaseIterable {
    case classic
    case modern
    case minimal
    case executive
    case creative

    var displayName: String {
        switch self {
        case .classic: return "Classic"
        case .modern: return "Modern"
        case .minimal: return "Minimal"
        case .executive: return "Executive"
        case .creative: return "Creative"
        }
    }

    var subtitle: String {
        switch self {
        case .classic: return "Clean blue professional layout"
        case .modern: return "Sleek slate with teal accents"
        case .minimal: return "Simple black & white design"
        case .executive: return "Elegant serif style"
        case .creative: return "Gradient header & modern badges"
        }
    }

    var iconName: String {
        switch self {
        case .classic: return "doc.text"
        case .modern: return "rectangle.split.3x1"
        case .minimal: return "doc.plaintext"
        case .executive: return "briefcase"
        case .creative: return "paintbrush"
        }
    }

    var accentColor: UIColor {
        switch self {
        case .classic: return UIColor(red: 0.1, green: 0.3, blue: 0.6, alpha: 1)
        case .modern: return UIColor(red: 0.05, green: 0.58, blue: 0.53, alpha: 1) // Modern Teal
        case .minimal: return UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1) // Dark Charcoal
        case .executive: return UIColor(red: 0.55, green: 0.35, blue: 0.15, alpha: 1) // Warm Bronze
        case .creative: return UIColor(red: 0.49, green: 0.18, blue: 0.9, alpha: 1) // Vibrant Violet
        }
    }

    var headerBackgroundColor: UIColor? {
        switch self {
        case .modern: return UIColor(red: 0.09, green: 0.12, blue: 0.2, alpha: 1) // Deep Charcoal Navy
        case .creative: return UIColor(red: 0.45, green: 0.15, blue: 0.65, alpha: 1) // Primary Gradient Start
        default: return nil
        }
    }

    var headerGradientColors: [UIColor]? {
        switch self {
        case .creative:
            return [
                UIColor(red: 0.45, green: 0.15, blue: 0.65, alpha: 1), // Deep Purple
                UIColor(red: 0.82, green: 0.22, blue: 0.51, alpha: 1)  // Vibrant Magenta/Pink
            ]
        default:
            return nil
        }
    }

    var headerTextColor: UIColor {
        switch self {
        case .modern, .creative: return .white
        default: return .label
        }
    }

    var usesSerifTitle: Bool {
        self == .executive
    }
}
