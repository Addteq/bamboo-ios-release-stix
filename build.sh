#!/bin/bash

/usr/bin/security unlock-keychain -p addteq2012

/usr/bin/xcodebuild -project Bamboo.xcodeproj -alltargets -configuration Debug
