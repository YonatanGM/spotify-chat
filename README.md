# Chat for Spotify

An iOS social app I designed, developed, and released in 2023. It used Spotify listening data to help people find others with similar music taste, explore music, and chat directly or in groups.

<p>
  <img src="docs/previews/profile-preview.gif" width="320" alt="Profile and music preview">
  <img src="docs/previews/discovery-preview.gif" width="320" alt="Recommendations and user discovery preview">
</p>

## How it worked

Users signed in with Spotify, and the app refreshed their access tokens automatically. Spotify data powered profiles, follows, saved tracks, and recommendations.

To suggest people with similar taste, the app created OpenAI embeddings from each person's top and recent listening data, then used Pinecone to retrieve the most similar profiles. Spotify supplied a separate set of track recommendations that refreshed weekly.

Firebase kept profiles, direct and group conversations, invitations, online presence, unread message counts, blocks, reports, and profile deletion in sync. OpenAI also created short profile bios. A StoreKit purchase unlocked extra refreshes, with transactions verified before premium access was stored for the account.

The interface was built mainly in SwiftUI, with UIKit where needed, AVKit for track previews, SDWebImage for artwork caching, UIImageColors for colors taken from cover art, and a customized copy of SwiftyChat.

## Stack

Swift · SwiftUI · UIKit · AVKit · StoreKit · Spotify Web API · Firebase Authentication · Realtime Database · Storage · Cloud Functions · OpenAI API · Pinecone · SDWebImageSwiftUI · UIImageColors · SwiftyChat
