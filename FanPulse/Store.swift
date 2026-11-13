import SwiftUI
import UserNotifications

@MainActor final class GameStore: ObservableObject {
    @Published var season = Season.demo()
    @Published var error: String?
    @Published var loaded = false
    @Published var notifications = false
    @Published var history: [SeasonRecord] = []
    private let file = URL.documentsDirectory.appending(path: "fan-pulse-season.json")
    #if DEBUG && targetEnvironment(simulator)
    private var captureDemo = false
    convenience init(captureKey: String?) {
        if let captureKey {
            self.init(demoKey: captureKey)
        } else {
            self.init()
        }
    }
    private init(demoKey: String) {
        captureDemo = true
        var demo = Season.demo()
        let complete = ["results", "personal-leaderboard", "profile"].contains(demoKey)
        let picks: [Pick] = [
            Pick(outcome: .home, home: 2, away: 1),
            Pick(outcome: .draw, home: nil, away: nil),
            Pick(outcome: .away, home: nil, away: nil),
            Pick(outcome: .home, home: nil, away: nil),
            Pick(outcome: .home, home: nil, away: nil)
        ]
        for (index, pick) in picks.prefix(complete ? 5 : 2).enumerated() {
            try? demo.save(pick, for: index, now: Date())
        }
        if complete { demo.finishDemo() }
        if demoKey == "profile" || demoKey == "personal-leaderboard" { demo.name = "Alex" }
        season = demo
        loaded = true
    }
    #endif
    init() {
        do { if FileManager.default.fileExists(atPath: file.path) { season = try JSONDecoder().decode(Season.self, from: Data(contentsOf: file)) } }
        catch { self.error = "Your saved season could not be read. The file is preserved; restart to try again." }
        if let data = UserDefaults.standard.data(forKey:"seasonHistory"), let records = try? JSONDecoder().decode([SeasonRecord].self,from:data) { history = records }
        loaded = true
        if error == nil { publishWidget() }
    }
    func persist() {
        #if DEBUG && targetEnvironment(simulator)
        if captureDemo { return }
        #endif
        do { try JSONEncoder().encode(season).write(to: file, options: .atomic); publishWidget() } catch { self.error = "Your changes could not be saved. Please try again." } }
    func save(_ pick: Pick, id: Int) -> Bool { do { try season.save(pick, for: id, now: Date()); persist(); return error == nil } catch { self.error = error.localizedDescription; return false } }
    func resetSeason() {
        #if DEBUG && targetEnvironment(simulator)
        if captureDemo { season = .demo(); history = []; return }
        #endif
        if !season.picks.isEmpty {
            history.insert(SeasonRecord(id:UUID(),date:Date(),points:season.points,correct:season.correct,completed:season.completed),at:0)
            if let data = try? JSONEncoder().encode(history) { UserDefaults.standard.set(data,forKey:"seasonHistory") }
        }
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        season = .demo(); persist()
    }
    func remind() async {
        #if DEBUG && targetEnvironment(simulator)
        if captureDemo { return }
        #endif
        do {
            notifications = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound])
            guard notifications else { error = "Notifications are off. You can enable them in Settings."; return }
            for f in season.fixtures where f.isOpen(at: Date()) {
                let content = UNMutableNotificationContent(); content.title = "Your round is waiting"; content.body = "Save your answer for \(f.home) v \(f.away)."
                let delay = max(1, f.kickoff.timeIntervalSinceNow - 1800)
                try await UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "match-\(f.id)", content: content, trigger: UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)))
            }
        } catch { self.error = error.localizedDescription }
    }
}
struct League: Codable, Identifiable { var id: Int; var name: String; var code: String }
struct Standing: Codable, Identifiable { var id: Int; var name: String; var points: Int }
@MainActor final class LeagueClient: ObservableObject {
    @Published var base = "http://127.0.0.1:8765"
    @Published var username = ""; @Published var password = ""
    @Published var leagues: [League] = []; @Published var standings: [Standing] = []
    @Published var busy = false; @Published var error: String?; @Published var token: String?
    #if DEBUG && targetEnvironment(simulator)
    private(set) var captureDemo = false
    init() {}
    var captureFixtures: [ServerFixture] = []
    convenience init(captureDemo: Bool) {
        self.init()
        if captureDemo {
            self.captureDemo = true
            token = "capture-demo"
            leagues = [League(id: 1, name: "Matchday Friends", code: "MATCHDAY")]
            standings = [Standing(id: 1, name: "Alex", points: 0), Standing(id: 2, name: "Sam", points: 0)]
            captureFixtures = [ServerFixture(id: 1, home: "North London", away: "Merseyside", kickoff: Date().addingTimeInterval(7200).timeIntervalSince1970, h: nil, a: nil, cancelled: 0, outcome: "home", pickHome: nil, pickAway: nil)]
        }
    }
    #endif
    func request<T: Decodable>(_ path: String, body: [String:String]? = nil) async throws -> T {
        #if DEBUG && targetEnvironment(simulator)
        if captureDemo { throw URLError(.notConnectedToInternet) }
        #endif
        guard let url = URL(string: base + path), ["http", "https"].contains(url.scheme ?? "") else { throw URLError(.badURL) }
        var req = URLRequest(url: url); req.timeoutInterval = 10
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token { req.setValue("Bearer " + token, forHTTPHeaderField: "Authorization") }
        if let body { req.httpMethod = "POST"; req.httpBody = try JSONEncoder().encode(body) }
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let res = response as? HTTPURLResponse, (200...299).contains(res.statusCode) else {
            let message = (try? JSONDecoder().decode([String:String].self, from: data)["error"]) ?? "Server request failed."
            throw NSError(domain: "FanPulse", code: 1, userInfo: [NSLocalizedDescriptionKey:message])
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
    func run(_ action: () async throws -> Void) async { busy = true; defer { busy = false }; do { try await action(); error = nil } catch { self.error = error.localizedDescription } }
    func auth(register: Bool) async { await run { let result: [String:String] = try await request(register ? "/register" : "/login", body: ["name":username,"password":password]); token = result["token"]; password = ""; leagues = try await request("/leagues") } }
    func group(name: String, join: Bool) async { await run { let _: League = try await request(join ? "/join" : "/leagues", body: [join ? "code" : "name": name]); leagues = try await request("/leagues") } }
    func ranking(_ league: League) async { await run { standings = try await request("/leagues/\(league.id)/standings") } }
}
struct ServerFixture: Codable, Identifiable {
    let id:Int; let home:String; let away:String; let kickoff:Double
    let h:Int?; let a:Int?; let cancelled:Int; let outcome:String?; let pickHome:Int?; let pickAway:Int?
}

struct SeasonRecord: Codable, Identifiable { let id:UUID; let date:Date; let points:Int; let correct:Int; let completed:Int }
