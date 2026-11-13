import SwiftUI

extension Color {
    static let pulse = Color(red:237/255,green:41/255,blue:57/255)
    static let ink = Color(red:23/255,green:25/255,blue:31/255)
    static let panel = Color(red:37/255,green:40/255,blue:48/255)
    static let muted = Color(red:166/255,green:173/255,blue:187/255)
    static let gold = Color(red:1,green:212/255,blue:90/255)
}
#if DEBUG && targetEnvironment(simulator)
// An explicit launch argument or environment flag is required for every demo route.
enum CaptureLaunch {
    static let keys = ["home", "round", "answer", "results", "personal-leaderboard", "leagues", "server-league", "profile"]
    static let key: String? = {
        let info = ProcessInfo.processInfo
        let args = info.arguments
        func value(after flag: String) -> String? {
            guard let index = args.firstIndex(of: flag), args.indices.contains(index + 1) else { return nil }
            return args[index + 1]
        }
        if args.contains("-ReviewScreen"), let key = value(after: "-ReviewScreen"), keys.contains(key) { return key }
        let envFlag = info.environment["APPSTORE_SCREENSHOTS"]?.lowercased()
        guard args.contains("-AppStoreScreenshots") || (envFlag != nil && !["", "0", "false", "no"].contains(envFlag!)) else { return nil }
        let index = Int(value(after: "-AppStoreScreenshotScreen") ?? info.environment["APPSTORE_SCREENSHOT_SCREEN"] ?? "0") ?? 0
        return keys.indices.contains(index) ? keys[index] : nil
    }()
}
enum CaptureDestination: Hashable { case answer(Int), results, ranking }
#endif
@main struct FanPulseApp: App {
    @StateObject var store: GameStore
    init() {
        #if DEBUG && targetEnvironment(simulator)
        _store = StateObject(wrappedValue: GameStore(captureKey: CaptureLaunch.key))
        #else
        _store = StateObject(wrappedValue: GameStore())
        #endif
    }
    var body: some Scene {
        WindowGroup {
            #if DEBUG && targetEnvironment(simulator)
            if CaptureLaunch.key != nil {
                RootView().environmentObject(store).preferredColorScheme(.dark).tint(.pulse)
                    .transaction { $0.disablesAnimations = true }
            } else {
                RootView().environmentObject(store).preferredColorScheme(.dark).tint(.pulse)
            }
            #else
            RootView().environmentObject(store).preferredColorScheme(.dark).tint(.pulse)
            #endif
        }
    }
}
struct RootView: View {
    @EnvironmentObject var store: GameStore
    @State var tab = 0
    #if DEBUG && targetEnvironment(simulator)
    @State private var homePath: [CaptureDestination] = []
    @State private var roundPath: [CaptureDestination] = []
    init() {
        let key = CaptureLaunch.key
        _tab = State(initialValue: ["round", "answer", "results"].contains(key ?? "") ? 1 : ["leagues", "server-league"].contains(key ?? "") ? 2 : key == "profile" ? 3 : 0)
        _homePath = State(initialValue: key == "personal-leaderboard" ? [.ranking] : [])
        _roundPath = State(initialValue: key == "answer" ? [.answer(0)] : key == "results" ? [.results] : [])
    }
    @ViewBuilder private func captureDestination(_ destination: CaptureDestination) -> some View {
        switch destination {
        case .answer(let id): AnswerView(id: id)
        case .results: ResultsView()
        case .ranking: RankingView()
        }
    }
    #endif
    var body: some View {
        TabView(selection: $tab) {
            #if DEBUG && targetEnvironment(simulator)
            if CaptureLaunch.key != nil {
                NavigationStack(path: $homePath) { HomeView(tab: $tab).navigationDestination(for: CaptureDestination.self) { captureDestination($0) } }.tabItem { Label("Home", systemImage:"house.fill") }.tag(0)
                NavigationStack(path: $roundPath) { RoundView().navigationDestination(for: CaptureDestination.self) { captureDestination($0) } }.tabItem { Label("Round", systemImage:"sportscourt.fill") }.tag(1)
            } else {
                NavigationStack { HomeView(tab: $tab) }.tabItem { Label("Home", systemImage:"house.fill") }.tag(0)
                NavigationStack { RoundView() }.tabItem { Label("Round", systemImage:"sportscourt.fill") }.tag(1)
            }
            #else
            NavigationStack { HomeView(tab: $tab) }.tabItem { Label("Home", systemImage:"house.fill") }.tag(0)
            NavigationStack { RoundView() }.tabItem { Label("Round", systemImage:"sportscourt.fill") }.tag(1)
            #endif
            NavigationStack { LeaguesView() }.tabItem { Label("Leagues", systemImage:"person.3.fill") }.tag(2)
            NavigationStack { ProfileView() }.tabItem { Label("Profile", systemImage:"person.crop.circle") }.tag(3)
        }.onOpenURL { url in
            if WidgetIdentity.accepts(url) {
                #if DEBUG && targetEnvironment(simulator)
                store.applyWidgetQA(url)
                #endif
                tab = 1
            }
        }.alert("Something needs attention", isPresented: Binding(get: { store.error != nil }, set: { if !$0 { store.error = nil } })) { Button("OK") { store.error = nil } } message: { Text(store.error ?? "") }
    }
}
struct Page<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View { ScrollView { VStack(alignment:.leading, spacing:24) { content }.padding(16).frame(maxWidth:760).frame(maxWidth:.infinity) }.background(Color.ink) }
}
struct Tag: View {
    var text: String
    var body: some View { Text(text).font(.caption.weight(.bold)).tracking(1).foregroundStyle(Color.gold) }
}
struct PrimaryButton: View {
    var title: String; var action: () -> Void
    var body: some View { Button(action:action) { Text(title).font(.headline).frame(maxWidth:.infinity).padding(16).background(Color.pulse,in:RoundedRectangle(cornerRadius:12)).foregroundStyle(.white) }.buttonStyle(.plain) }
}
struct PitchArt: View {
    var body: some View {
        GeometryReader { g in
            ZStack {
                Path { p in
                    let w = g.size.width, h = g.size.height
                    p.move(to:CGPoint(x:w*0.35,y:0)); p.addLine(to:CGPoint(x:w,y:0)); p.addLine(to:CGPoint(x:w*0.75,y:h)); p.addLine(to:CGPoint(x:0,y:h)); p.closeSubpath()
                }.fill(.white.opacity(0.08))
                Circle().stroke(.white.opacity(0.2),lineWidth:2).frame(width:130,height:130).offset(x:75,y:35)
                Image(systemName:"soccerball").font(.system(size:110)).foregroundStyle(.white.opacity(0.13)).rotationEffect(.degrees(-20)).offset(x:100,y:15)
            }
        }.accessibilityHidden(true)
    }
}
struct HomeView: View {
    @EnvironmentObject var store: GameStore; @Binding var tab: Int
    var body: some View {
        Page {
            HStack { Text("FAN / PULSE").font(.title2.black()); Spacer(); Image(systemName:"waveform.path.ecg").foregroundStyle(Color.pulse).font(.title) }
            HStack { Label("LOCAL TRAINING",systemImage:"wifi.slash"); Spacer(); Text("SEASON \(String(format: "%02d", store.history.count + 1))") }.font(.caption.bold()).foregroundStyle(Color.muted)
            VStack(alignment:.leading,spacing:16) {
                Tag(text:"MATCHDAY CHALLENGE")
                Text("Your club.\nYour instinct.").font(.system(size:38,weight:.black)).lineSpacing(-2)
                Text("Build your round. Raise your accuracy.").font(.subheadline)
                Button { tab = 1 } label: { HStack { Text("Make your picks").font(.headline); Spacer(); Image(systemName:"arrow.up.right") }.foregroundStyle(Color.ink).padding(16).background(.white,in:RoundedRectangle(cornerRadius:10)) }
            }.padding(24).frame(maxWidth:.infinity,alignment:.leading).background { Color.pulse.overlay(PitchArt()) }.clipShape(RoundedRectangle(cornerRadius:20))
            HStack(spacing:12) { Stat(value:"\(store.season.points)",label:"Season points",icon:"bolt.fill"); Stat(value:"\(store.season.picks.count)/5",label:"Answers saved",icon:"checkmark.circle.fill") }
            HStack { Text("Match of the round").font(.title3.bold()); Spacer(); Text("01 / 05").font(.caption).foregroundStyle(Color.muted) }
            if let f = store.season.fixtures.first { NavigationLink { AnswerView(id:f.id) } label: { MatchCard(f:f, pick:store.season.picks[f.id]) }.buttonStyle(.plain) }
            NavigationLink { RankingView() } label: { HStack { Image(systemName:"trophy.fill").foregroundStyle(Color.gold); VStack(alignment:.leading) { Text("My personal league").font(.headline); Text("1st place · \(store.season.points) points").foregroundStyle(Color.muted) }; Spacer(); Image(systemName:"chevron.right") }.padding(20).background(Color.panel,in:RoundedRectangle(cornerRadius:14)) }.buttonStyle(.plain)
            Text("Demo fixtures • generated on \(store.season.fixtures[0].kickoff.addingTimeInterval(-7200).formatted(date:.abbreviated,time:.shortened)). No live sports feed. Works offline.").font(.caption).foregroundStyle(Color.muted)
        }.toolbar(.hidden,for:.navigationBar)
    }
}
extension Font { func black() -> Font { self.weight(.black) } }
struct Stat: View { var value:String; var label:String; var icon:String
    var body: some View { VStack(alignment:.leading,spacing:10) { Image(systemName:icon).foregroundStyle(Color.gold); Text(value).font(.system(size:32,weight:.bold)).monospacedDigit(); Text(label).font(.caption).foregroundStyle(Color.muted) }.frame(maxWidth:.infinity,alignment:.leading).padding(20).background(Color.panel,in:RoundedRectangle(cornerRadius:14)) }
}
struct MatchCard: View {
    var f: Fixture; var pick: Pick?
    var body: some View {
        VStack(alignment:.leading,spacing:16) {
            HStack { Text("TRAINING LEAGUE").font(.caption.bold()).foregroundStyle(Color.muted); Spacer(); Text(f.cancelled ? "Cancelled" : f.finished ? "Finished" : pick == nil ? "Answer" : "Answer saved").font(.caption.bold()).foregroundStyle(pick == nil ? Color.gold : .white) }
            HStack { VStack(alignment:.leading,spacing:10) { Label(f.home,systemImage:"shield.lefthalf.filled"); Label(f.away,systemImage:"shield.checkered") }.font(.headline); Spacer(); if f.finished { Text("\(f.resultHome ?? 0)\n\(f.resultAway ?? 0)").font(.title2.bold()).monospacedDigit() } else { Image(systemName:pick == nil ? "arrow.right.circle" : "checkmark.circle.fill").font(.title).foregroundStyle(Color.pulse) } }
            Text(f.kickoff.formatted(date:.abbreviated,time:.shortened) + " · " + TimeZone.current.abbreviation()!).font(.caption).foregroundStyle(Color.muted)
        }.padding(20).background(Color.panel,in:RoundedRectangle(cornerRadius:14))
    }
}
struct RoundView: View {
    @EnvironmentObject var store: GameStore
    var body: some View {
        Page { Tag(text:"ROUND 01 · LOCAL SEASON"); Text("Make every\nanswer count.").font(.largeTitle.black()); Text("\(store.season.fixtures.filter { $0.isOpen(at:Date()) && store.season.picks[$0.id] == nil }.count) unanswered · 3 points for the outcome + 2 for an exact score").foregroundStyle(Color.muted)
            ForEach(store.season.fixtures) { f in NavigationLink { AnswerView(id:f.id) } label: { MatchCard(f:f,pick:store.season.picks[f.id]) }.buttonStyle(.plain).accessibilityIdentifier("match-\(f.id)") }
            NavigationLink("Round results") { ResultsView() }.font(.headline).padding(.vertical,12)
        }.navigationTitle("This round").safeAreaInset(edge:.bottom) { HStack { Text("My answers: \(store.season.picks.count)/5").font(.headline); Spacer(); NavigationLink("Review answers") { ResultsView() } }.padding(16).background(Color.panel) }
    }
}
struct AnswerView: View {
    @EnvironmentObject var store: GameStore; @Environment(\.dismiss) var dismiss; @Environment(\.accessibilityReduceMotion) var reduceMotion
    let id:Int; @State var outcome:Outcome?; @State var exact = false; @State var home = 0; @State var away = 0
    var f: Fixture { store.season.fixtures.first { $0.id == id }! }
    var body: some View {
        Page {
            MatchCard(f:f,pick:store.season.picks[id]); Text("Who will win?").font(.largeTitle.black())
            TimelineView(.periodic(from:.now,by:1)) { context in
                VStack(alignment:.leading,spacing:16) {
                    Text(f.isOpen(at:context.date) ? "Closes \(f.kickoff.formatted(date:.abbreviated,time:.shortened)) · your time" : "Answers closed").font(.subheadline).foregroundStyle(Color.muted)
                    ForEach(Outcome.allCases,id:\.self) { choice in
                        Button { withAnimation(reduceMotion ? nil : .easeInOut(duration:0.2)) { outcome = choice } } label: {
                            HStack { Text(choice == .home ? f.home : choice == .away ? f.away : "Draw"); Spacer(); Image(systemName:outcome == choice ? "checkmark.circle.fill" : "circle") }.font(.headline).foregroundStyle(Color.ink).padding(20).background(.white,in:RoundedRectangle(cornerRadius:10)).overlay(RoundedRectangle(cornerRadius:10).stroke(outcome == choice ? Color.pulse : .clear,lineWidth:3))
                        }.disabled(!f.isOpen(at:context.date)).accessibilityAddTraits(outcome == choice ? .isSelected : [])
                    }
                    Toggle("Add an exact score",isOn:$exact).padding(.vertical,8).disabled(!f.isOpen(at:context.date))
                    if exact { Stepper("\(f.home): \(home)",value:$home,in:0...20); Stepper("\(f.away): \(away)",value:$away,in:0...20) }
                    PrimaryButton(title:store.season.picks[id] == nil ? "Save answer" : "Update answer") { if let outcome, store.save(Pick(outcome:outcome,home:exact ? home : nil,away:exact ? away : nil),id:id) { dismiss() } }.disabled(outcome == nil || !f.isOpen(at:context.date)).opacity(outcome == nil || !f.isOpen(at:context.date) ? 0.45 : 1)
                    if !f.isOpen(at:context.date) { Text("Other answers: no other players in this local season.").foregroundStyle(Color.muted) }
                }
            }
            Text("Edit until kick-off. A wrong answer scores zero. Cancelled matches score zero. A postponed match reopens only when its new kick-off is confirmed; existing answers are kept.").font(.caption).foregroundStyle(Color.muted)
        }.navigationTitle("Your answer").navigationBarTitleDisplayMode(.inline).onAppear { if let p = store.season.picks[id] { outcome = p.outcome; exact = p.home != nil; home = p.home ?? 0; away = p.away ?? 0 } }
    }
}
struct ResultsView: View {
    @EnvironmentObject var store:GameStore; @State var confirm = false
    var body: some View { Page { Tag(text:"ROUND 01"); Text("The final whistle.").font(.largeTitle.black()); HStack { Stat(value:"\(store.season.points)",label:"Round points",icon:"bolt.fill"); Stat(value:"\(store.season.correct)",label:"Correct outcomes",icon:"checkmark.seal.fill") }
        ForEach(store.season.fixtures) { f in VStack(alignment:.leading,spacing:12) { MatchCard(f:f,pick:store.season.picks[f.id]); if let p = store.season.picks[f.id] { Text("Your answer: \(p.outcome == .home ? f.home : p.outcome == .away ? f.away : "Draw")" ); if let h = p.home, let a = p.away { Text("Exact score: \(h)–\(a)") } } else { Text("No answer saved") }; Text(f.finished ? "+\(f.points(store.season.picks[f.id])) points · outcome 3, exact score 2" : "Result pending").foregroundStyle(Color.gold) } }
        if !store.season.fixtures.allSatisfy(\.finished) { PrimaryButton(title:"Finish training round") { confirm = true } }
        Text("Training results are simulated. Scores are always recalculated from the latest result, never added twice.").font(.caption).foregroundStyle(Color.muted)
    }.navigationTitle("Round results").confirmationDialog("Finish this local round? Answers will close.",isPresented:$confirm,titleVisibility:.visible) { Button("Finish training round") { store.season.finishDemo(); store.persist() } } }
}
struct RankingView: View {
    @EnvironmentObject var store:GameStore
    var body: some View { Page { Tag(text:"PERSONAL LEAGUE"); Text("Set your standard.").font(.largeTitle.black()); HStack { Text("#1").font(.largeTitle.bold()); Text(store.season.name); Spacer(); Text("\(store.season.points) pts").monospacedDigit(); Text("—").accessibilityLabel("No position change") }.padding(24).background(Color.panel,in:RoundedRectangle(cornerRadius:14)); Text("Only you play in this local league. Connect a server in Leagues to compete with friends.").foregroundStyle(Color.muted); Text("How points work").font(.title2.bold()); Text("Correct outcome: 3 points\nExact score: 2 extra points\nIncorrect or cancelled: 0 points").lineSpacing(12); NavigationLink("See every point") { ResultsView() } }.navigationTitle("Leaderboard") }
}
struct LeaguesView: View {
    @StateObject var client = LeagueClient(); @State var group = ""; @State var code = ""; @State var selected:League?
    #if DEBUG && targetEnvironment(simulator)
    @State private var didPresentCaptureLeague = false
    init() {
        if let key = CaptureLaunch.key, key == "leagues" || key == "server-league" {
            _client = StateObject(wrappedValue: LeagueClient(captureDemo: true))
        }
    }
    #endif
    var body: some View { Page { Tag(text:client.token == nil ? "LOCAL MODE" : "CONNECTED SERVER"); Text("Better together.").font(.largeTitle.black()); NavigationLink { RankingView() } label: { Label("My personal league",systemImage:"trophy.fill").font(.headline).padding(20).frame(maxWidth:.infinity).background(Color.panel,in:RoundedRectangle(cornerRadius:14)) }
        Text("Friends' leagues").font(.title2.bold()); Text("Your local season stays on this device. Server leagues have their own fixtures and scores; local points are never uploaded.").foregroundStyle(Color.muted)
        if client.token == nil { TextField("Server URL",text:$client.base).textInputAutocapitalization(.never).keyboardType(.URL); TextField("Username",text:$client.username).textInputAutocapitalization(.never).autocorrectionDisabled(); SecureField("Password (at least 10 characters)",text:$client.password); HStack { Button("Create account") { Task { await client.auth(register:true) } }; Spacer(); Button("Sign in") { Task { await client.auth(register:false) } } }.frame(minHeight:44)
        } else { TextField("New league name",text:$group); PrimaryButton(title:"Create league") { Task { await client.group(name:group,join:false) } }; TextField("Invitation code",text:$code).textInputAutocapitalization(.characters); Button("Join with code") { Task { await client.group(name:code,join:true) } }.frame(minHeight:44)
            if client.leagues.isEmpty { ContentUnavailableView("Your team starts here",systemImage:"person.3",description:Text("Create a league or enter a friend's code.")) }
            ForEach(client.leagues) { league in Button { selected = league; Task { await client.ranking(league) } } label: { HStack { Text(league.name); Spacer(); Text(league.code).monospaced() }.padding(16).background(Color.panel,in:RoundedRectangle(cornerRadius:12)) } }
            Button("Sign out") { client.token = nil; client.leagues = []; client.standings = [] }.frame(minHeight:44)
        }
        if client.busy { ProgressView("Contacting your server…") }
        if let error = client.error { Label(error,systemImage:"exclamationmark.triangle").foregroundStyle(Color.gold); Text("Check the server address and connection, then try again. Your local season is available offline.").font(.caption) }
    }.textFieldStyle(.roundedBorder).disabled(client.busy).navigationTitle("Leagues")
    #if DEBUG && targetEnvironment(simulator)
    .onAppear {
        if CaptureLaunch.key == "server-league", !didPresentCaptureLeague, let league = client.leagues.first {
            didPresentCaptureLeague = true
            var transaction = Transaction(); transaction.disablesAnimations = true
            withTransaction(transaction) { selected = league }
        }
    }
    #endif
    .sheet(item:$selected) { league in NavigationStack { Page { Text(league.name).font(.largeTitle.bold()); ShareLink(item:league.code) { Label("Invite: \(league.code)",systemImage:"square.and.arrow.up") }; if client.busy { ProgressView() }; if let error = client.error { Text(error) }; ForEach(Array(client.standings.enumerated()),id:\.element.id) { i,row in HStack { Text("\(i+1)"); Text(row.name); Spacer(); Text("\(row.points) pts").monospacedDigit() }.padding(16).background(Color.panel,in:RoundedRectangle(cornerRadius:12)) }; ServerRound(client:client,league:league); Text("Server league · points from server fixtures only").font(.caption).foregroundStyle(Color.muted) }.toolbar { Button("Done") { selected = nil } } } } }
}
struct ProfileView: View {
    @EnvironmentObject var store:GameStore; @State var reset = false
    var body: some View { Page { Tag(text:"YOUR FAN ID"); Text("Keep the pulse.").font(.largeTitle.black()); TextField("Display name",text:$store.season.name).textFieldStyle(.roundedBorder).onSubmit { store.persist() }; HStack { Stat(value:String(format:"%02d",store.history.count + 1),label:"Local season",icon:"flag.fill"); Stat(value:store.season.completed == 0 ? "—" : "\(store.season.correct * 100 / store.season.completed)%",label:"Outcome accuracy",icon:"scope") }; Text("Achievements").font(.title2.bold()); Label(store.season.picks.isEmpty ? "First answer · not yet unlocked" : "First answer · unlocked",systemImage:store.season.picks.isEmpty ? "lock.fill" : "checkmark.seal.fill"); Label(store.season.picks.count == 5 ? "Full house · unlocked" : "Full house · answer all 5 matches",systemImage:"square.grid.2x2.fill"); PrimaryButton(title:store.notifications ? "Refresh match reminders" : "Enable match reminders") { Task { await store.remind() } }; Text("A reminder 30 minutes before each training match. All dates follow your device time zone.").font(.caption).foregroundStyle(Color.muted); NavigationLink("Season results") { ResultsView() }; Button("Start a fresh training season",role:.destructive) { reset = true }.frame(minHeight:44); ForEach(store.history) { season in HStack { Text(season.date.formatted(date:.abbreviated,time:.omitted)); Spacer(); Text("\(season.points) pts · \(season.correct)/\(season.completed) correct").monospacedDigit() }.font(.caption) }; Text("Fan Pulse • English (UK)\nLocal data is stored on this device. Friend accounts are stored on your configured server.").font(.caption).foregroundStyle(Color.muted) }.navigationTitle("Profile").confirmationDialog("Archive this season and start again?",isPresented:$reset,titleVisibility:.visible) { Button("Start new season") { store.resetSeason() } } }
}
