# README.md

# Auralis x Moodify

**Auralis x Moodify** is a sophisticated multimodal intelligence engine designed to bridge the gap between human emotional states and acoustic environments. By leveraging Computer Vision, Natural Language Processing (NLP), and Acoustic Speech Analysis, the application performs a "consensus-based" fusion to determine the user's current mood and triggers automated, mood-synced music playback through the Spotify API.

---

## 🚀 Overview

The architecture implements a **Late Fusion Voting System**. Instead of relying on a single data point, Auralis samples input across three distinct channels to produce a robust emotional profile:

1. **Visual Modality:** Uses `DeepFace` to sample 10 consecutive frames via local camera, identifying facial expressions.
2. **Linguistic Modality:** Uses `distilbert-base-uncased-emotion` via `HuggingFace Transformers` to process manual text inputs.
3. **Acoustic Modality:** Uses `SpeechRecognition` to capture live vocal snippets and analyze emotional sentiment.

The final consensus command is then mapped to dynamic Spotify parameters (Valence and Energy) to curate and push tracks directly to your active hardware client.

---

## 🛠 Prerequisites

### Hardware/Software Requirements

* **Spotify Premium:** Mandatory for the `start_playback` API endpoint (Spotify restrictions on free accounts).
* **Active Spotify Client:** The app requires an open Spotify application (Desktop or Mobile) on the same network to intercept the signal.
* **Python 3.10+**

### API Setup

1. Navigate to the [Spotify Developer Dashboard](https://developer.spotify.com/).
2. Create a new application to obtain your `Client ID` and `Client Secret`.
3. Set your Redirect URI to `http://localhost:8888/callback`.

---

## ⚙️ Configuration

Create a file named `config.py` in the root directory to store your credentials:

```python
# config.py
SPOTIFY_CLIENT_ID = "YOUR_CLIENT_ID"
SPOTIFY_CLIENT_SECRET = "YOUR_CLIENT_SECRET"
SPOTIFY_REDIRECT_URI = "http://localhost:8888/callback"
SPOTIFY_SCOPE = "user-modify-playback-state user-read-playback-state"

# Maps Transformer output labels to simplified system moods
MOOD_MAPPING = {
    "joy": "happy",
    "sadness": "sad",
    "anger": "angry",
    "fear": "sad",
    "love": "happy",
    "surprise": "energetic"
}

```

---

## 💻 Installation

```bash
# Clone the repository
git clone [repository-url]

# Install required dependencies
pip install opencv-python speechrecognition spotipy deepface transformers customtkinter

```

---

## 🎨 Interface Blueprint

The application features a modern "Cyber-Dark" dashboard built with `customtkinter`:

* **Left Panel:** Emotion detection metrics and manual text entry.
* **Center Panel:** Interactive audio vinyl player UI.
* **Right Panel:** Real-time system pipeline trace logs for debugging model confidence.

---

## 💡 How It Works

The system follows a three-stage lifecycle:

1. **Sampling:** The system gathers data from all three modalities (Camera, Text, Microphone).
2. **Fusion:** The `Counter` logic performs a majority vote across the modalities to resolve the final mood state.
3. **Actuation:** The `trigger_spotify_playback` function dynamically generates a genre seed, valence, and energy target, then injects the stream into your active Spotify device.

---

## ⚠️ Troubleshooting

* **Device Not Found:** Ensure your Spotify app is open and you have played at least one song manually. The API cannot "wake up" a completely dormant account session.
* **Camera Lag:** The first launch may be slower as the `DeepFace` model downloads local weights.
* **Premium Restrictions:** If you are using a free Spotify account, the music injection will fail; consider modifying the `trigger_spotify_playback` function to open a URL in the browser instead.

---

*Built with Auralis Intelligence — Transforming Data into Atmosphere.*
