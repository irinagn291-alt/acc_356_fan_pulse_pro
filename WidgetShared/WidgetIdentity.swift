import Foundation

enum WidgetIdentity {
    static let group = "group.app.fanpulse.local"
    static let kind = "app.fanpulse.local.progress"
    static let scheme = "fanpulse"
    static let route = "round"
    static let displayName = "Fan Pulse"
    static let emptyHint = "Save your matchday picks."
    static let widgetName = "Round progress"
    static let widgetDescription = "Your training picks and earned points."
    static let icon = "sportscourt.fill"
    static let theme = "pulse"
    static let accent: [Double] = [1, 0.22, 0.34]
    static let background: [Double] = [0.07, 0.08, 0.1]
    static let serif = false
    static var url: URL { URL(string: "\(scheme)://widget/\(route)")! }
    static func accepts(_ url: URL) -> Bool { url.scheme == scheme && url.host == "widget" && url.path == "/" + route }
}
