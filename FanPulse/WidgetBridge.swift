import Foundation

extension GameStore {
    var widgetSnapshot: WidgetSnapshot {
        WidgetSnapshot(title: "Your training round", value: "\(season.picks.count) / \(season.fixtures.count)",
            label: "picks saved", detail: "\(season.points) points · \(season.correct) correct \(season.correct == 1 ? "prediction" : "predictions")",
            footnote: "Local training league", progress: Double(season.picks.count) / Double(max(1,season.fixtures.count)))
    }
    func publishWidget() { WidgetStore.publish(widgetSnapshot) }
}

#if DEBUG && targetEnvironment(simulator)
extension GameStore {
    /// Only explicit UI-test launches in disposable simulators can mutate this fixture.
    func applyWidgetQA(_ url: URL) {
        guard ProcessInfo.processInfo.arguments.contains("-WidgetQA"),
              URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.contains(where: { $0.name == "qa" && ["1", "2"].contains($0.value ?? "") }) == true else { return }
        let secondUpdate = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.contains(where: { $0.name == "qa" && $0.value == "2" }) == true
        if let fixture = season.fixtures.first(where: { $0.isOpen(at: Date()) && (!secondUpdate || season.picks[$0.id] == nil) }) {
            _ = save(Pick(outcome: .draw, home: nil, away: nil), id: fixture.id)
        }
    }
}
#endif
