import SwiftUI
struct ServerRound: View {
    @ObservedObject var client:LeagueClient; let league:League
    @State var matches:[ServerFixture] = []
    @State var others = ""
    @State var homeScores: [Int:Int] = [:]
    @State var awayScores: [Int:Int] = [:]
    var body: some View {
        VStack(alignment:.leading,spacing:16) {
            Text("Server training round").font(.title2.bold())
            Text("Demo fixtures on your server · updated when refreshed").font(.caption).foregroundStyle(Color.muted)
            ForEach(matches) { match in
                VStack(alignment:.leading,spacing:12) {
                    Text("\(match.home) v \(match.away)").font(.headline)
                    Text(Date(timeIntervalSince1970:match.kickoff).formatted(date:.abbreviated,time:.shortened)).font(.caption)
                    if match.cancelled != 0 { Text("Cancelled · 0 points") }
                    else if match.kickoff > Date().timeIntervalSince1970 && match.h == nil {
                        ForEach(["home","draw","away"],id:\.self) { outcome in
                            Button { Task { await client.run { let _: [String:String] = try await client.request("/leagues/\(league.id)/picks/\(match.id)",body:["outcome":outcome]); matches = try await client.request("/leagues/\(league.id)/fixtures") } } } label: {
                                HStack { Text(outcome == "home" ? match.home : outcome == "away" ? match.away : "Draw"); Spacer(); if match.outcome == outcome { Image(systemName:"checkmark.circle.fill") } }.padding(14).frame(maxWidth:.infinity).background(Color.panel,in:RoundedRectangle(cornerRadius:8))
                            }
                        }
                        Text("Tap an outcome to save. You can change it until kick-off.").font(.caption)
                        DisclosureGroup("Optional exact score") {
                            Stepper("Home: \(homeScores[match.id, default:0])", value: Binding(get: { homeScores[match.id, default:0] }, set: { homeScores[match.id] = $0 }), in:0...20)
                            Stepper("Away: \(awayScores[match.id, default:0])", value: Binding(get: { awayScores[match.id, default:0] }, set: { awayScores[match.id] = $0 }), in:0...20)
                            Button("Save exact score") { Task { await client.run {
                                let h = homeScores[match.id, default:0], a = awayScores[match.id, default:0]
                                let _: [String:String] = try await client.request("/leagues/\(league.id)/picks/\(match.id)", body:["outcome": h == a ? "draw" : h > a ? "home" : "away", "home":String(h),"away":String(a)])
                                matches = try await client.request("/leagues/\(league.id)/fixtures")
                            } } }.frame(minHeight:44)
                        }
                        if let h = match.pickHome, let a = match.pickAway { Text("Saved exact score: \(h)–\(a)").font(.caption).foregroundStyle(Color.gold) }
                    } else {
                        Text("Answers closed · \(match.h.map(String.init) ?? "–") : \(match.a.map(String.init) ?? "–")")
                        Button("View members' answers") { Task { await client.run { struct Answer:Decodable { let name:String; let outcome:String }; let rows:[Answer] = try await client.request("/leagues/\(league.id)/picks/\(match.id)"); others = rows.map { "\($0.name): \($0.outcome)" }.joined(separator:"\n"); if rows.isEmpty { others = "No answers saved." } } } }
                    }
                }.padding(16).overlay(RoundedRectangle(cornerRadius:12).stroke(Color.muted.opacity(0.3)))
            }
            if !others.isEmpty { Text(others) }
            Button("Refresh round and ranking") { Task { await load(); await client.ranking(league) } }.frame(minHeight:44)
        }.task { await load() }
    }
    func load() async {
        #if DEBUG && targetEnvironment(simulator)
        if client.captureDemo { matches = client.captureFixtures; return }
        #endif
        await client.run { matches = try await client.request("/leagues/\(league.id)/fixtures") } }
}
