# Chat for Spotify

An iOS social app I designed and developed in SwiftUI. It used Spotify listening data to help people discover others with similar music taste, explore profiles and music, and talk through direct or group chats.

The app was live in 2023 and is now archived. This repository is kept as a record of the implementation rather than as a maintained product.

<p align="center">
  <img src="docs/previews/profile-preview.gif" width="280" alt="Profile and music preview">
  <img src="docs/previews/discovery-preview.gif" width="280" alt="Recommendations and user discovery preview">
</p>

## Implementation

- Spotify's OAuth authorization-code flow and token refresh, with `URLSession` and `Codable` clients for profile, top-artist, top-track, playlist, follow, and saved-track data.
- Firebase Authentication, Realtime Database, and Cloud Functions for Spotify-linked identity, real-time messaging, group invitations, direct messages, presence, unread state, blocking, and account cleanup.
- Music-based discovery backed by a database index that connects users through their top artist and track names.
- A primarily SwiftUI interface with UIKit bridges, `AVPlayer` track previews, a SpriteKit login animation, remote-image caching, artwork-derived colors, and a customized local SwiftUI chat package.

**Core stack:** Swift, SwiftUI, UIKit, SpriteKit, AVFoundation/AVKit, Spotify Web API, Firebase Authentication, Firebase Realtime Database, Firebase Cloud Functions, and Swift Package Manager.
