# Chat for Spotify

An iOS social app I designed, developed, and released in 2023. It used Spotify listening data to help people find others with similar music taste, explore music, and chat directly or in groups.

<p>
  <img src="docs/previews/profile-preview.gif" width="320" alt="Profile and music preview">
  <img src="docs/previews/discovery-preview.gif" width="320" alt="Recommendations and user discovery preview">
</p>

## Technical Overview

- Spotify authentication and Web API integration for profiles, listening data, recommendations, saved tracks, and following users.
- OpenAI embeddings and Pinecone similarity search to match users with similar listening preferences.
- Firebase Authentication, Realtime Database, Storage, and Cloud Functions for accounts, chat, presence, invitations, reporting, and moderation.
- StoreKit for premium access, with transaction verification and limits on recommendation and profile bio refreshes.
- SwiftUI interface with UIKit where needed, AVKit for track previews, remote image caching, and a customized version of SwiftyChat.

## Stack

Swift · SwiftUI · UIKit · AVKit · StoreKit · Spotify Web API · Firebase Authentication · Realtime Database · Storage · Cloud Functions · OpenAI API · Pinecone · SDWebImageSwiftUI · UIImageColors · SwiftyChat
