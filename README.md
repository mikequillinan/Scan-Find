Scan & Find
==============

Scan & Find - Sample project with ZXing scanner doing lookups against various web sources.

Purpose
==============
This is a quick project that I'll be using to test and demonstrate the latest techniques in iOS and Objective-C development. Some techniques planned to be included are Storyboards, Grand Central Dispatch, Collection Literals and non-synthesized properties. Maybe some collection views later on.

Platform Support
==============
This project since its purpose is to test and demonstrate the latest techniques in iOS and Objective-C development will only be tested on the latest versions on Xcode and the latest full iOS version. Currently Xcode 4.5 and iOS 5.1-6 are the supported platforms. iPhone 5 support is included as well.

Setup
==============
Download the code from github. ZXing is included as a git submodule, so be sure to initialize it. Otherwise, you can download the forked copy here. Be sure to place it in the project's root under Submodules/zxing. If you put it somewhere else, just update the target's Header search paths for ZXingWidget's Classes folder and the cpp/core/src paths to point to your new path.

JSONKit is another submodule included. Be sure to initialize it.

Enter your own Google Shopping APIs key in Scan&Find_prefix.pch Get one at https://code.google.com/apis

ARC
==============
The main project is ARC compliant. ZXing 2.0 is being used for scanning and has not been updated to support ARC. This might be a cool thing to work on at some point.

Todo List
==============
- Make some use of the Storyboard. I still prefer old school xibs, although for a small project like this storyboards might be worth it.
- Review the conversions of my old boiler plate classes like WebViewController for ARC and modern Objective-C usage.
- Add the StoreLookup VC after conversion.
- Add Facebook/Twitter sharing of scanned items. Tell the world what you want! or something like that :-)

Acknowledgments
==============
ZXing for their great opensource scanning library. (https://github.com/zxing/zxing)
JSONKit for the high performance json parsing engine. (https://github.com/johnezang/JSONKit)
ShareKit for the use of their well-done activity indicator. (https://github.com/ShareKit/ShareKit)
The Working Group (http://www.theworkinggroup.ca) for their brightness icon. You can find it at  http://blog.twg.ca/2010/11/retina-display-icon-set/

License
==============
Copyright © 2012, AMTM Studios, LLC

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.