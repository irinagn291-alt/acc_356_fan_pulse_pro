"""Fan Pulse development server. Standard library only. Bind to localhost by default."""
import hashlib, hmac, json, os, secrets, sqlite3, time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
DB = os.environ.get('FANPULSE_DB', str(Path(__file__).with_name('fanpulse.sqlite')))

def connect():
    db = sqlite3.connect(DB, timeout=10); db.row_factory = sqlite3.Row
    db.execute('PRAGMA foreign_keys=ON'); return db

def init():
    with connect() as db:
        db.executescript('''
        CREATE TABLE IF NOT EXISTS users(id INTEGER PRIMARY KEY,name TEXT UNIQUE NOT NULL,salt TEXT,hash TEXT);
        CREATE TABLE IF NOT EXISTS sessions(token TEXT PRIMARY KEY,user INTEGER REFERENCES users(id),expires REAL);
        CREATE TABLE IF NOT EXISTS leagues(id INTEGER PRIMARY KEY,name TEXT,code TEXT UNIQUE);
        CREATE TABLE IF NOT EXISTS members(league INTEGER REFERENCES leagues(id),user INTEGER REFERENCES users(id),PRIMARY KEY(league,user));
        CREATE TABLE IF NOT EXISTS fixtures(id INTEGER PRIMARY KEY,home TEXT,away TEXT,kickoff REAL,h INTEGER,a INTEGER,cancelled INTEGER DEFAULT 0);
        CREATE TABLE IF NOT EXISTS picks(user INTEGER REFERENCES users(id),fixture INTEGER REFERENCES fixtures(id),outcome TEXT,h INTEGER,a INTEGER,PRIMARY KEY(user,fixture));
        ''')
        if not db.execute('SELECT 1 FROM fixtures').fetchone():
            db.execute('INSERT INTO fixtures VALUES(1,?,?,?,?,?,0)',('North London','Merseyside',time.time()+86400,None,None))

def points(row):
    if row['cancelled'] or row['h'] is None or row['a'] is None: return 0
    outcome = 'draw' if row['h']==row['a'] else 'home' if row['h']>row['a'] else 'away'
    return 3*(row['outcome']==outcome)+2*(row['ph']==row['h'] and row['pa']==row['a'])

def api(method,path,data,token=''):
    with connect() as db:
        if path in ('/register','/login') and method=='POST':
            name = data.get('name','').strip(); password=data.get('password','')
            if not 2<=len(name)<=40 or not 10<=len(password)<=200: raise ValueError('Use a 2–40 character name and a 10–200 character password.')
            if path=='/register':
                salt=secrets.token_hex(16); hashed=hashlib.pbkdf2_hmac("sha256",password.encode(),salt.encode(),600000).hex()
                try: uid=db.execute('INSERT INTO users(name,salt,hash) VALUES(?,?,?)',(name,salt,hashed)).lastrowid
                except sqlite3.IntegrityError: raise ValueError('Username already exists.')
            else:
                user=db.execute('SELECT * FROM users WHERE name=?',(name,)).fetchone()
                if not user or not hmac.compare_digest(user['hash'],hashlib.pbkdf2_hmac('sha256',password.encode(),user['salt'].encode(),600000).hex()): raise PermissionError('Invalid credentials.')
                uid=user['id']
            token=secrets.token_urlsafe(32); db.execute('INSERT INTO sessions VALUES(?,?,?)',(hashlib.sha256(token.encode()).hexdigest(),uid,time.time()+86400))
            return {'token':token}
        session=db.execute('SELECT user FROM sessions WHERE token=? AND expires>?',(hashlib.sha256(token.encode()).hexdigest(),time.time())).fetchone()
        if not session: raise PermissionError('Sign in to continue.')
        uid=session['user']
        if path=='/leagues' and method=='GET': return [dict(r) for r in db.execute('SELECT l.* FROM leagues l JOIN members m ON l.id=m.league WHERE m.user=? ORDER BY l.id',(uid,))]
        if path in ('/leagues','/join') and method=='POST':
            if path=='/leagues':
                name=data.get('name','').strip()
                if not 1<=len(name)<=50: raise ValueError('Enter a league name (1–50 characters).')
                code=secrets.token_hex(4).upper(); lid=db.execute('INSERT INTO leagues(name,code) VALUES(?,?)',(name,code)).lastrowid
            else:
                league=db.execute('SELECT * FROM leagues WHERE code=?',(data.get('code','').strip().upper(),)).fetchone()
                if not league: raise ValueError('Invitation code not found.')
                lid=league['id']
            db.execute('INSERT OR IGNORE INTO members VALUES(?,?)',(lid,uid)); return dict(db.execute('SELECT * FROM leagues WHERE id=?',(lid,)).fetchone())
        parts=path.strip('/').split('/')
        if len(parts)>=3 and parts[0]=='leagues':
            lid=int(parts[1])
            if not db.execute('SELECT 1 FROM members WHERE league=? AND user=?',(lid,uid)).fetchone(): raise PermissionError('League membership required.')
            if parts[2]=='standings' and method=='GET':
                rows=[]
                for u in db.execute('SELECT u.id,u.name FROM users u JOIN members m ON u.id=m.user WHERE m.league=?',(lid,)):
                    total=sum(points(r) for r in db.execute('SELECT f.*,p.outcome,p.h ph,p.a pa FROM fixtures f JOIN picks p ON p.fixture=f.id WHERE p.user=?',(u['id'],)))
                    rows.append(dict(id=u['id'],name=u['name'],points=total))
                return sorted(rows,key=lambda r:(-r['points'],r['id']))
            if parts[2]=='fixtures' and method=='GET':
                return [dict(r) for r in db.execute('SELECT f.*,p.outcome,p.h pickHome,p.a pickAway FROM fixtures f LEFT JOIN picks p ON p.fixture=f.id AND p.user=?',(uid,))]
            if parts[2]=='picks' and len(parts)==4:
                fid=int(parts[3]); f=db.execute('SELECT * FROM fixtures WHERE id=?',(fid,)).fetchone()
                if not f: raise ValueError('Match not found.')
                if method=='POST':
                    if f['cancelled'] or f['h'] is not None or time.time()>=f['kickoff']: raise ValueError('Answers are closed.')
                    outcome=data.get('outcome'); h=data.get('home'); a=data.get('away')
                    if outcome not in ('home','draw','away'): raise ValueError('Choose an outcome.')
                    if h is not None or a is not None:
                        try: h=int(h); a=int(a)
                        except (TypeError,ValueError): raise ValueError('Enter both scores.')
                        if not 0<=h<=20 or not 0<=a<=20 or outcome!=('draw' if h==a else 'home' if h>a else 'away'): raise ValueError('Score must agree with outcome.')
                    db.execute('INSERT INTO picks VALUES(?,?,?,?,?) ON CONFLICT(user,fixture) DO UPDATE SET outcome=excluded.outcome,h=excluded.h,a=excluded.a',(uid,fid,outcome,h,a)); return {'status':'saved'}
                if method=='GET':
                    if time.time()<f['kickoff'] and f['h'] is None and not f['cancelled']: raise PermissionError('Other answers remain private until kick-off.')
                    return [dict(r) for r in db.execute('SELECT u.name,p.outcome,p.h,p.a FROM picks p JOIN users u ON u.id=p.user JOIN members m ON m.user=p.user WHERE m.league=? AND p.fixture=?',(lid,fid))]
        raise ValueError('Route not found.')

class Handler(BaseHTTPRequestHandler):
    def do_GET(self): self.handle_api('GET')
    def do_POST(self): self.handle_api('POST')
    def handle_api(self,method):
        try:
            size=int(self.headers.get('Content-Length','0'))
            if size>16384: raise ValueError('Request too large.')
            data=json.loads(self.rfile.read(size)) if size else {}
            result=api(method,self.path,data,self.headers.get('Authorization','').removeprefix('Bearer ')); status=200
        except PermissionError as e: result={'error':str(e)}; status=403
        except (ValueError,TypeError,KeyError) as e: result={'error':str(e)}; status=400
        except Exception: result={'error':'Server error. Please retry.'}; status=500
        body=json.dumps(result).encode(); self.send_response(status); self.send_header('Content-Type','application/json'); self.send_header('Content-Length',str(len(body))); self.end_headers(); self.wfile.write(body)
    def log_message(self,*args): pass
if __name__=='__main__':
    init(); server=ThreadingHTTPServer(('127.0.0.1',int(os.environ.get('PORT','8765'))),Handler)
    print('Fan Pulse server: http://127.0.0.1:%s'%server.server_port,flush=True); server.serve_forever()
