# Chat for Spotify

An iOS social app I designed, developed, and released in 2023. It used Spotify listening data to help people find others with similar music taste, explore music, and chat directly or in groups.

<p>
  <img src="docs/previews/profile-preview.gif" width="320" alt="Profile and music preview">
  <img src="docs/previews/discovery-preview.gif" width="320" alt="Recommendations and user discovery preview">
</p>

## Implementation

- Integrated Spotify's OAuth authorization-code flow and token refresh, then used profile, top-artist, top-track, recommendation, follow, and saved-track APIs throughout the app.
- Built user matching by turning top and short-term listening data into OpenAI embeddings and querying Pinecone for similar profiles. Track recommendations used Spotify's recommendation API and refreshed weekly.
- Used Firebase Authentication, Realtime Database, Storage, and Cloud Functions for Spotify-linked accounts, profiles, direct and group chat, invitations, presence, unread state, blocking, reporting, and account cleanup.
- Added AI-generated music-taste bios and a StoreKit premium upgrade with verified transactions and per-user refresh limits.
- Built the interface in SwiftUI with UIKit bridges, AVKit track previews, cached remote artwork, artwork-derived colors, and a customized local SwiftyChat package.

## Stack

Swift · SwiftUI · UIKit · AVKit · StoreKit · Spotify Web API · Firebase Authentication · Realtime Database · Storage · Cloud Functions · OpenAI API · Pinecone · SDWebImageSwiftUI · UIImageColors · SwiftyChat
