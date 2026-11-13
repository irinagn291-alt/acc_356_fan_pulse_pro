import os,sys,subprocess,time
from pathlib import Path
root=Path(__file__).resolve().parents[4]; sys.path.insert(0,str(root))
from gf.genesis.build_slot import build_slot
result_path=root/"output/FanPulse-implementation/UITests.xcresult"
if result_path.exists(): result_path=result_path.with_name("UITests-"+str(int(time.time()))+".xcresult")
with build_slot():
    code=subprocess.call(['xcodebuild','-project',str(root/'ios/apps/FanPulse/FanPulse.xcodeproj'),'-scheme','FanPulse','-derivedDataPath',str(root/'output/FanPulse-implementation/DerivedData'),'-destination','id='+os.environ['GF_SIMULATOR_UDID'],'-parallel-testing-enabled','NO','-resultBundlePath',str(result_path),'CODE_SIGNING_ALLOWED=NO','test'])
sys.exit(code)
