# Chat for Spotify

An iOS social app I designed, developed, and released in 2023. It used Spotify listening data to help people find others with similar music taste, explore music, and chat directly or in groups.

<p>
  <img src="docs/previews/profile-preview.gif" width="320" alt="Profile and music preview">
  <img src="docs/previews/discovery-preview.gif" width="320" alt="Recommendations and user discovery preview">
</p>

## Implementation

- Spotify OAuth for sign-in and token refresh, with Web API support for profiles, top artists and tracks, recommendations, followed artists, and saved songs.
- User matching based on top artists, tracks, genres, and short-term listening data, using OpenAI embeddings and Pinecone vector search.
- Personalized track recommendations through Spotify's recommendation API, refreshed weekly.
- Spotify accounts linked to Firebase Authentication through custom tokens, with Realtime Database, Storage, and Cloud Functions supporting profiles, messaging, presence, invitations, moderation, and account management.
- Music taste summaries generated with OpenAI, plus premium access through verified StoreKit purchases and usage limits stored in Firebase.
- A SwiftUI client with UIKit where needed, AVKit track previews, remote image caching, colors sampled from album artwork, and a customized local version of SwiftyChat.

## Stack

Swift · SwiftUI · UIKit · AVKit · StoreKit · Spotify Web API · Firebase Authentication · Realtime Database · Storage · Cloud Functions · OpenAI API · Pinecone
