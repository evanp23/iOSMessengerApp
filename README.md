# iOS Messenger App

Chatting application with modifications and feature additions including Contacts List and Contact Search, leveraging Firebase and Cocoapods.

<br/>

## How to build

1. Download the source code by cloning this repository
2. In Firebase console, create a new application.
3. Set your firebase up with a ```users``` collection and a ```channels``` collection in the root.
4. Add at least two users as pictured. Make sure to have at least one friendship (two users in each other's friend lists) so that you can message someone.

<img src="https://i.imgur.com/ac3ZXDh.jpg"/>

6. Download the GoogleService-Info.plist file from your <a href="https://console.firebase.google.com">Firebase Console</a> and replace the existing file in ChatApp folder. This will connect the app to your own Firebase instance.
7. Install the pods by running
```
pod update
```
4. Open the xcworkspace file with the latest version of Xcode
