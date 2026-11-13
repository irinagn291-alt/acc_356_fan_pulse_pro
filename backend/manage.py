"""Local operator controls. No remote administrative endpoint or embedded secret."""
import argparse, datetime
import server
p=argparse.ArgumentParser(); p.add_argument('action',choices=['result','cancel','postpone']); p.add_argument('fixture',type=int); p.add_argument('--home',type=int); p.add_argument('--away',type=int); p.add_argument('--kickoff',help='ISO 8601 with timezone')
a=p.parse_args(); server.init()
with server.connect() as db:
    if not db.execute('SELECT 1 FROM fixtures WHERE id=?',(a.fixture,)).fetchone(): p.error('Unknown fixture')
    if a.action=='result':
        if a.home is None or a.away is None or min(a.home,a.away)<0: p.error('Provide non-negative --home and --away')
        db.execute('UPDATE fixtures SET h=?,a=?,cancelled=0 WHERE id=?',(a.home,a.away,a.fixture))
    elif a.action=='cancel': db.execute('UPDATE fixtures SET cancelled=1 WHERE id=?',(a.fixture,))
    else:
        if not a.kickoff: p.error('--kickoff required')
        date=datetime.datetime.fromisoformat(a.kickoff)
        if date.tzinfo is None: p.error('Timezone required')
        if date.timestamp()<=datetime.datetime.now().timestamp(): p.error('New kickoff must be in the future')
        db.execute('UPDATE fixtures SET kickoff=?,h=NULL,a=NULL,cancelled=0 WHERE id=?',(date.timestamp(),a.fixture))
print('Updated; standings recalculate immediately.')
