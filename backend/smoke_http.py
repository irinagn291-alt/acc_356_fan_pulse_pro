import json, os, subprocess, tempfile, time, urllib.request
from pathlib import Path
import sys
with tempfile.TemporaryDirectory() as folder:
    proc=subprocess.Popen([sys.executable,str(Path(__file__).with_name('server.py'))],env=dict(os.environ,FANPULSE_DB=folder+'/db',PORT='18765'),stdout=subprocess.PIPE)
    try:
        for _ in range(50):
            try:
                req=urllib.request.Request('http://127.0.0.1:18765/register',data=json.dumps({'name':'HTTP Test','password':'correct horse battery'}).encode(),headers={'Content-Type':'application/json'})
                token=json.load(urllib.request.urlopen(req))['token']; break
            except OSError: time.sleep(.1)
        else: raise RuntimeError('Server unavailable')
        req=urllib.request.Request('http://127.0.0.1:18765/leagues',data=b'{"name":"HTTP League"}',headers={'Content-Type':'application/json','Authorization':'Bearer '+token})
        league=json.load(urllib.request.urlopen(req)); assert league['code']
        req=urllib.request.Request('http://127.0.0.1:18765/leagues/'+str(league['id'])+'/standings',headers={'Authorization':'Bearer '+token})
        rows=json.load(urllib.request.urlopen(req)); assert rows[0]['name']=='HTTP Test'; assert rows[0]['points']==0
        print('PASS: real HTTP register, bearer authentication, create league, standings')
    finally: proc.terminate(); proc.wait()
