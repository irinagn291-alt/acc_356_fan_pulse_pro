from gf.web.catalog import create_manual
from gf import run
bundle='app.fanpulse.local'
if run.load(bundle):
    print('Existing Fan Pulse record; no changes made.')
else:
    result=create_manual(bundle=bundle,title='Fan Pulse',domain='',project_path='/Users/belzephyrus/Documents/gambling_factory/ios/apps/FanPulse',account_id='358',aso_request_id='cmwf13j5l00psfdfth643er0b')
    print('Imported into Scratch:',result.bundle_id,'account:',result.account_id)
