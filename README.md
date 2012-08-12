Scan & Find
==============

Scan & Find - Sample project with Zxing scanner doing lookups against various web sources.

Purpose
==============
This is a quick project that I'll be using to test and demonstrate the latest techniques in iOS and Objective-C development. Some techniques planned to be included are Storyboards, Grand Central Dispatch, Collection Literals and non-synthesized properties. Maybe some collection views later on.

Platform Support
==============
This project since its purpose is to test and demonstrate the latest techniques in iOS and Objective-C development will only be tested on the latest versions on Xcode and the latest full iOS version. Currently Xcode 4.4.1 and iOS 5 are the supported platforms.

ARC
==============
The main project is ARC compliant. Zxing 2.0 is being used for scanning and has not been updated to support ARC. This might be a cool thing to work on at some point.

Setup
==============
Download the code from github. Zxing is included as a git submodule, so be sure to initialize it. Otherwise, you can download the forked copy here. Be sure to place it in the project's root under Submodules/zxing. If you put it somewhere else, just update the target's Header search paths for ZXingWidget's Classes folder and the cpp/core/src paths to point to your new path.

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