import Foundation
var s = Season.demo(now: Date(timeIntervalSince1970: 10000))
let p = Pick(outcome:.home,home:2,away:1)
try s.save(p,for:0,now:Date(timeIntervalSince1970:10001))
s.fixtures[0].resultHome=2; s.fixtures[0].resultAway=1
assert(s.points == 5); assert(s.points == 5)
s.fixtures[0].resultHome=3; assert(s.points == 3)
s.fixtures[0].cancelled=true; assert(s.points == 0)
do { try s.save(p,for:0,now:Date()); fatalError("Closed save accepted") } catch {}
s.fixtures[0].cancelled=false; s.fixtures[0].resultHome=nil; s.fixtures[0].resultAway=nil
s.fixtures[0].kickoff=Date().addingTimeInterval(100)
try s.save(p,for:0,now:Date())
do { try s.save(Pick(outcome:.draw,home:2,away:1),for:0,now:Date()); fatalError("Inconsistent score accepted") } catch {}
let bytes=try JSONEncoder().encode(s); let restored=try JSONDecoder().decode(Season.self,from:bytes)
assert(restored.picks[0]==p)
assert(!s.fixtures[0].isOpen(at:s.fixtures[0].kickoff))
print("PASS: scoring, correction, cancellation, deadlines, reopening, validation, persistence")
