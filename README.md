# Chat for Spotify

An iOS social app I designed, developed, and released in 2023. It used Spotify listening data to help people find others with similar music taste, explore music, and chat directly or in groups.

<p>
  <img src="docs/previews/profile-preview.gif" width="320" alt="Profile and music preview">
  <img src="docs/previews/discovery-preview.gif" width="320" alt="Recommendations and user discovery preview">
</p>

## Overview

Spotify OAuth handles sign-in and token refresh, while the Spotify Web API provides profile information, top artists and tracks, recommendations, followed artists, and saved songs.

The app uses top artists, top tracks, and short-term listening data to generate OpenAI embeddings. Pinecone similarity search then helps users discover people with related music taste. Spotify's recommendation API provides personalized track suggestions.

Spotify accounts are linked to Firebase Authentication through custom tokens. Firebase also supports user profiles, direct and group conversations, invitations, presence, unread messages, blocking, reporting, and backend tasks through Cloud Functions.

The app also includes music taste summaries generated with OpenAI and premium features unlocked through verified StoreKit purchases.

The iOS client is built mainly with SwiftUI, with UIKit where needed, AVKit for track previews, and a customized version of SwiftyChat for messaging.

## Stack

Swift · SwiftUI · UIKit · AVKit · StoreKit · Spotify Web API · Firebase Authentication · Realtime Database · Storage · Cloud Functions · OpenAI API · Pinecone
