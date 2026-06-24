# 🎵 Auralis × Moodify

> A multimodal AI-powered mood detection system that analyzes your emotions in real-time and automatically plays matching music on Spotify.

---

## 🧠 How It Works

Auralis uses a **Weighted Multimodal Decision Matrix** to fuse three independent emotion signals into a single confident mood verdict:

| Modality | Weight | Technology |
|---|---|---|
| 📷 Facial Expression (Camera) | 60% | DeepFace |
| 💬 Text Input (Manual) | 25% | DistilBERT (HuggingFace) |
| 🎙️ Voice / Speech | 15% | SpeechRecognition + Google STT |

The final mood consensus (`happy`, `sad`, `angry`, `energetic`, or `neutral`) is used to fetch and play a curated Spotify playlist — automatically.

---

## ✨ Features

- **Real-time facial emotion detection** via webcam (10-frame consensus sampling)
- **NLP text sentiment analysis** using a fine-tuned DistilBERT model
- **Live voice recognition** with Google Speech-to-Text
- **Weighted fusion engine** that prevents any single modality from dominating
- **Spotify integration** — auto-plays mood-matched tracks on your active device
- **Browser fallback** — opens Spotify web search if no device is connected
- **Custom model support** — drop in your own fine-tuned brain at `D:\auralis_custom_brain`
- **Sleek dark UI** built with CustomTkinter

---

## 🖥️ Screenshots

> *(Add your screenshots here)*

---

## 🚀 Getting Started

### Prerequisites

- Python 3.10+
- A webcam and microphone
- A [Spotify Developer](https://developer.spotify.com/dashboard) account with an app created
- (Optional) A CUDA-capable GPU for faster model inference

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/auralis-moodify.git
cd auralis-moodify
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

<details>
<summary>Manual install (if no requirements.txt)</summary>

```bash
pip install opencv-python deepface speechrecognition spotipy transformers customtkinter torch
```

</details>

### 3. Configure Spotify Credentials

Create a `.env` file in the root directory (never commit this):

```env
SPOTIFY_CLIENT_ID=your_client_id_here
SPOTIFY_CLIENT_SECRET=your_client_secret_here
SPOTIFY_REDIRECT_URI=http://127.0.0.1:3000
```

Then update `config.py` to load from environment variables:

```python
import os
SPOTIFY_CLIENT_ID = os.environ.get("SPOTIFY_CLIENT_ID")
SPOTIFY_CLIENT_SECRET = os.environ.get("SPOTIFY_CLIENT_SECRET")
SPOTIFY_REDIRECT_URI = os.environ.get("SPOTIFY_REDIRECT_URI", "http://127.0.0.1:3000")
```

### 4. Run the App

```bash
python app.py
```

---

## 🏋️ Training Your Own Emotion Model (Optional)

Auralis ships with `bhadresh-savani/distilbert-base-uncased-emotion` by default but supports a custom fine-tuned model.

### Option A — Train on the Kaggle Emotions Dataset

1. Download the dataset from Kaggle and save it as `emotions.csv` in the project root.
2. Run:

```bash
python train_text.py
```

The trained model will be saved to `./custom_emotion_model`.

### Option B — Train on Your Own CSV

Your CSV must have `text` and `label` columns. Place it at `D:/custom_training_data/new_dataset.csv`, then run:

```bash
python train_engine.py
```

The model will be saved to `D:/auralis_custom_brain` and auto-detected by `app.py` on next launch.

---

## 📁 Project Structure

```
auralis-moodify/
├── app.py               # Main application & UI
├── config.py            # Spotify credentials & mood mapping
├── train_text.py        # Fine-tuning script (Kaggle dataset)
├── train_engine.py      # Fine-tuning script (custom dataset)
├── test_imports.py      # Dependency health check
├── requirements.txt     # Python dependencies
└── README.md
```

---

## 🎭 Mood → Music Mapping

| Mood | Genres | Valence | Energy |
|---|---|---|---|
| 😄 Happy | Pop, Happy | 0.85 | 0.65 |
| ⚡ Energetic | EDM, Electro | 0.75 | 0.95 |
| 😢 Sad | Acoustic, Rainy Day | 0.12 | 0.15 |
| 😠 Angry | Rock, Metal | 0.20 | 0.95 |
| 😐 Neutral | Chill, Ambient | 0.50 | 0.35 |

---

## ⚠️ Security Notice

Never commit your Spotify `client_id` or `client_secret` to version control. Use environment variables or a `.env` file with `python-dotenv`. Add `.env` to your `.gitignore`:

```
.env
D:/auralis_custom_brain/
./training_snapshots/
./custom_emotion_model/
__pycache__/
*.pyc
```

---

## 🤝 Contributing

Pull requests are welcome! For major changes, open an issue first to discuss what you'd like to change.

---

## 📄 License

[MIT](LICENSE)

---

<p align="center">Built with 💜 using Python, HuggingFace Transformers, DeepFace & Spotify API</p>
