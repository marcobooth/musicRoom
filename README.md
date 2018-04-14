# Music Room

## Summary

Music Room is a 42 project created in partnership with [Deezer](https://www.deezer.com). With Music Room, you can create both public and private collaborative playlists that play music using the Deezer SDK. You can also create events where users add tracks and vote for their favorites, the most popular of which is played next on a single phone connected to the speakers. We implemented a pretty cool feature with events where specified people can play and pause the music on the master phone remotely.

Our team was composed of Marco Booth ([@marcobooth](https://github.com/marcobooth)), Teo Fleming ([@mokolodi1](https://github.com/mokolodi1)), and Antoine Leblanc ([@Leblantoine](https://github.com/Leblantoine)).

We opted to develop the app in Swift with [Firebase](https://firebase.google.com/) as the backend. We also developed a simple Android app in React Native with limited features so that our friends who don't have iPhones could still vote on public events. (That app lives in a different repo.)

## Installation

```sh
git clone https://github.com/marcobooth/musicRoom
cd musicRoom/iOS

# install CocoaPods - like NPM but for iOS
sudo gem install cocoapods

# install dependencies (this might take a while)
pod install

# open Xcode (note .xcworkspace not .xcodeproj to access pods)
open musicRoom.xcworkspace
```

Before you start the project, you'll have to change the project's team to your personal development team.

![Before changing the team](screenshots/change_team_before.png?raw=true)

![After changing the team](screenshots/change_team_after.png?raw=true)

If your `Pods` folder shows up in red you skipped the `pod install` step in the installation. Do that, reopen Xcode, and you should be all good.

Note that you won't be able to login to Deezer when you change the Bundle Identifier. Honestly this isn't too much of a problem because unless you have a paid Deezer account you'll only be able to listen to 30 second samples anyways. (You can always go create your own Deezer app and make it work, but that's beyond the scope of this README.)

Now you can plug in your phone or fire up a simulator to try it out! The music delegation is way cooler to see if you have multiple devices running at the same time.

## About this repo

This repo has now been made public so the secret keys have been change and removed. Please contact us directly if you'd like to test out the application directly
