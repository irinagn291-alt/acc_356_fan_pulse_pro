import os, sys, subprocess
from pathlib import Path
root=Path(__file__).resolve().parents[4]
sys.path.insert(0,str(root))
from gf.genesis.build_slot import build_slot
env=dict(os.environ,DEVELOPER_DIR='/Applications/Xcode.app/Contents/Developer')
with build_slot():
    result=subprocess.run(['xcodebuild','-project',str(root/'ios/apps/FanPulse/FanPulse.xcodeproj'),'-scheme','FanPulse','-configuration','Debug','-sdk','iphonesimulator','-derivedDataPath',str(root/'output/FanPulse-implementation/DerivedData'),'CODE_SIGNING_ALLOWED=NO','build'],env=env)
sys.exit(result.returncode)
