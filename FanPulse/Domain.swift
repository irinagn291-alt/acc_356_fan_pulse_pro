import Foundation

enum Outcome: String, Codable, CaseIterable { case home, draw, away }
struct Pick: Codable, Equatable { var outcome: Outcome; var home: Int?; var away: Int? }
struct Fixture: Identifiable, Codable {
    var id: Int; var home: String; var away: String; var kickoff: Date
    var resultHome: Int? = nil; var resultAway: Int? = nil; var cancelled = false
    var postponed = false
    var finished: Bool { resultHome != nil && resultAway != nil }
    func isOpen(at now: Date) -> Bool { !cancelled && !finished && now < kickoff }
    func points(_ pick: Pick?) -> Int {
        guard !cancelled, let h = resultHome, let a = resultAway, let pick else { return 0 }
        let outcome: Outcome = h == a ? .draw : (h > a ? .home : .away)
        return (pick.outcome == outcome ? 3 : 0) + (pick.home == h && pick.away == a ? 2 : 0)
    }
}
struct Season: Codable {
    var fixtures: [Fixture]; var picks: [Int: Pick] = [:]; var name = "You"
    static func demo(now: Date = Date()) -> Season {
        let teams = [("North London", "Merseyside"), ("Manchester", "West London"), ("Brighton", "Newcastle"), ("Birmingham", "Nottingham"), ("Bournemouth", "Leeds")]
        return Season(fixtures: teams.enumerated().map { i, t in Fixture(id: i, home: t.0, away: t.1, kickoff: now.addingTimeInterval(Double(3600 * (i + 2)))) })
    }
    var points: Int { fixtures.reduce(0) { $0 + $1.points(picks[$1.id]) } }
    var completed: Int { fixtures.filter { $0.finished && !$0.cancelled && picks[$0.id] != nil }.count }
    var correct: Int { fixtures.filter { $0.points(picks[$0.id]) >= 3 }.count }
    mutating func save(_ pick: Pick, for id: Int, now: Date) throws {
        guard let fixture = fixtures.first(where: { $0.id == id }), fixture.isOpen(at: now) else { throw GameError.closed }
        if let h = pick.home, let a = pick.away {
            guard (0...20).contains(h), (0...20).contains(a), pick.outcome == (h == a ? .draw : h > a ? .home : .away) else { throw GameError.score }
        } else if pick.home != nil || pick.away != nil { throw GameError.score }
        picks[id] = pick
    }
    mutating func finishDemo() { for i in fixtures.indices { fixtures[i].resultHome = [2,1,0,3,1][i]; fixtures[i].resultAway = [1,1,2,0,0][i] } }
}
enum GameError: LocalizedError { case closed, score
    var errorDescription: String? { self == .closed ? "This match is closed. Your previous answer is unchanged." : "The exact score must agree with your selected outcome." }
}
protocol FixtureProvider: Sendable { func fixtures() async throws -> [Fixture] }
struct HTTPFixtureProvider: FixtureProvider {
    let endpoint: URL
    func fixtures() async throws -> [Fixture] {
        let (data, response) = try await URLSession.shared.data(from: endpoint)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
        let decoder = JSONDecoder(); decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([Fixture].self, from: data)
    }
}
