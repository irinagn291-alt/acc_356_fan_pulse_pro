import unittest, tempfile, os, time
import server
class APITests(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory(); server.DB=os.path.join(self.temp.name,'test.db'); server.init()
        self.a=server.api('POST','/register',{'name':'Alice','password':'long-password'})['token']
        self.b=server.api('POST','/register',{'name':'Bob','password':'long-password'})['token']
        self.l=server.api('POST','/leagues',{'name':'Friends'},self.a); self.path='/leagues/'+str(self.l['id'])
    def tearDown(self): self.temp.cleanup()
    def test_membership_and_join(self):
        with self.assertRaises(PermissionError): server.api('GET',self.path+'/standings',{},self.b)
        server.api('POST','/join',{'code':self.l['code']},self.b)
        server.api('POST','/join',{'code':self.l['code']},self.b)
        self.assertEqual(len(server.api('GET',self.path+'/standings',{},self.a)),2)
    def test_deadline_privacy_correction_cancel(self):
        server.api('POST',self.path+'/picks/1',{'outcome':'home','home':'2','away':'1'},self.a)
        with self.assertRaises(PermissionError): server.api('GET',self.path+'/picks/1',{},self.a)
        with server.connect() as db: db.execute('UPDATE fixtures SET kickoff=?,h=2,a=1',(time.time()-1,))
        with self.assertRaises(ValueError): server.api('POST',self.path+'/picks/1',{'outcome':'away'},self.a)
        for _ in range(2): self.assertEqual(server.api('GET',self.path+'/standings',{},self.a)[0]['points'],5)
        with server.connect() as db: db.execute('UPDATE fixtures SET h=3')
        self.assertEqual(server.api('GET',self.path+'/standings',{},self.a)[0]['points'],3)
        with server.connect() as db: db.execute('UPDATE fixtures SET cancelled=1')
        self.assertEqual(server.api('GET',self.path+'/standings',{},self.a)[0]['points'],0)
    def test_auth_and_reopen(self):
        with self.assertRaises(PermissionError): server.api('POST','/login',{'name':'Alice','password':'wrong-password'})
        with server.connect() as db: db.execute('UPDATE fixtures SET kickoff=?',(time.time()-1,))
        with self.assertRaises(ValueError): server.api('POST',self.path+'/picks/1',{'outcome':'draw'},self.a)
        with server.connect() as db: db.execute('UPDATE fixtures SET kickoff=?',(time.time()+3600,))
        self.assertEqual(server.api('POST',self.path+'/picks/1',{'outcome':'draw'},self.a)['status'],'saved')
if __name__=='__main__': unittest.main()
