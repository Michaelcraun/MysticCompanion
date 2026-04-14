# MysticCompanion

MysticCompanion is a native iOS companion app for **Mystic Vale**. It helps players host or join nearby games, track turn resources and victory points, sync multiplayer state through Firebase, and save finished-game history and player stats.

## Features

- Host or join local multiplayer games using Firebase Realtime Database
- Match nearby players using device location
- Choose a faction deck before the game starts
- Track turn resources, spoil state, box victory, and total victory points
- Sync turn order and live game state between players
- Save completed games and review past results
- View player statistics such as wins, losses, win percentage, and best turns
- Sign in with email/password, Google, Facebook, or Twitter
- Unlock premium features for saved game history and custom victory point goals

## Tech Stack

- Swift
- UIKit
- Firebase Auth
- Firebase Realtime Database
- Google Mobile Ads
- StoreKit
- CocoaPods

## Project Structure

- `MysticCompanion/Controller`: app screens and game flow
- `MysticCompanion/Uitlities`: Firebase, game, location, mail, and purchase helpers
- `MysticCompanion/Model`: shared constants and player state
- `MysticCompanion/View`: table cells and custom UI components
- `MysticCompanion/Extensions`: UIKit convenience extensions

## Running The Project

1. Install CocoaPods if needed.
2. Run `pod install`.
3. Open `MysticCompanion.xcworkspace` in Xcode.
4. Provide valid Firebase and sign-in configuration for your environment.
5. Build and run on an iOS simulator or device.

## Notes

- This codebase was originally written in 2017-2018 and uses older Firebase and social login SDK APIs.
- The repo currently includes the `Pods/` directory and workspace files.
- If you plan to revive or publish the app, expect dependency, signing, and SDK migration work on modern Xcode versions.

## GitHub Description

Native iOS companion app for Mystic Vale with Firebase multiplayer sync, score tracking, saved game history, and player stats.

## Suggested GitHub Topics

`ios`, `swift`, `uikit`, `mystic-vale`, `board-game`, `board-game-companion`, `firebase`, `firebase-auth`, `firebase-realtime-database`, `cocoapods`
