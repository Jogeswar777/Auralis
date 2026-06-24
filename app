# app.py
import os
import cv2
import speech_recognition as sr
import spotipy
from spotipy.oauth2 import SpotifyOAuth
from deepface import DeepFace
from transformers import pipeline
import webbrowser
import customtkinter as ctk
import tkinter as tk
from tkinter import messagebox
from collections import Counter

# Load local system settings
import config

# Set default application styling theme to match the cyber-dark palette
ctk.set_appearance_mode("dark")
ctk.set_default_color_theme("blue")

print("Initializing Auralis Intelligence Multimodal Engine... Please wait...")

# Standardized fallback to the robust online repository configuration if your local D: model folder isn't generated yet
MODEL_PATH = "bhadresh-savani/distilbert-base-uncased-emotion"

# Check if your custom-built local model folder actually exists before pointing to it
if os.path.exists("D:\\auralis_custom_brain"):
    MODEL_PATH = os.path.abspath("D:\\auralis_custom_brain")

text_classifier = pipeline("text-classification", model=MODEL_PATH)


class AuralisApp(ctk.CTk):
    def __init__(self):
        super().__init__()
        
        self.title("Auralis x Moodify")
        self.geometry("1200x680")
        self.configure(fg_color="#0b0e14") 
        
        self.init_spotify()
        self.create_top_bar()
        self.create_main_layout()

    def init_spotify(self):
        """Authenticates with Spotify Developer Portal Credentials."""
        try:
            self.sp = spotipy.Spotify(auth_manager=SpotifyOAuth(
                client_id=config.SPOTIFY_CLIENT_ID,
                client_secret=config.SPOTIFY_CLIENT_SECRET,
                redirect_uri=config.SPOTIFY_REDIRECT_URI,
                scope=config.SPOTIFY_SCOPE
            ))
            print("Auralis Spotify Link Client Configured!")
        except Exception as e:
            print(f"Spotify Framework Exception: {e}")

    def create_top_bar(self):
        top_frame = ctk.CTkFrame(self, height=50, fg_color="#10141d", corner_radius=0)
        top_frame.pack(fill="x", side="top")
        
        logo = ctk.CTkLabel(top_frame, text="Auralis  ", font=("Arial", 22, "bold"), text_color="#a855f7")
        logo.pack(side="left", padx=20, pady=10)
        
        sub_logo = ctk.CTkLabel(top_frame, text="×  Moodify", font=("Arial", 13), text_color="#64748b")
        sub_logo.pack(side="left", pady=15)
        
        status_badge = ctk.CTkLabel(top_frame, text="● Models ready ✓", font=("Arial", 11, "bold"), 
                                     fg_color="#14532d", text_color="#4ade80", corner_radius=12, width=120)
        status_badge.pack(side="right", padx=20, pady=12)

    def create_main_layout(self):
        # --- LEFT PANEL (EMOTION SIGNALS & INPUT) ---
        self.left_panel = ctk.CTkFrame(self, width=320, fg_color="#10141d", corner_radius=8)
        self.left_panel.pack(side="left", fill="y", padx=15, pady=15)
        self.left_panel.pack_propagate(False)
        
        left_title = ctk.CTkLabel(self.left_panel, text="EMOTION DETECTION", font=("Arial", 11, "bold"), text_color="#64748b")
        left_title.pack(anchor="w", padx=15, pady=(15, 5))
        
        self.cam_box = ctk.CTkFrame(self.left_panel, height=160, fg_color="#1a1f2c", border_color="#334155", border_width=1)
        self.cam_box.pack(fill="x", padx=15, pady=5)
        self.cam_icon_lbl = ctk.CTkLabel(self.cam_box, text="📷\nCamera Ready", font=("Arial", 13), text_color="#64748b")
        self.cam_icon_lbl.place(relx=0.5, rely=0.5, anchor="center")
        
        sig_title = ctk.CTkLabel(self.left_panel, text="LIVE EMOTION SIGNALS", font=("Arial", 11, "bold"), text_color="#64748b")
        sig_title.pack(anchor="w", padx=15, pady=(20, 5))
        
        self.bars = {}
        for mood in ["happy", "sad", "angry", "energetic"]:
            row = ctk.CTkFrame(self.left_panel, fg_color="transparent")
            row.pack(fill="x", padx=15, pady=4)
            lbl = ctk.CTkLabel(row, text=mood.capitalize(), font=("Arial", 12), text_color="#94a3b8", width=70, anchor="w")
            lbl.pack(side="left")
            
            bar_color = "#4ade80" if mood=="happy" else "#3b82f6" if mood=="sad" else "#f87171" if mood=="angry" else "#fbbf24"
            bar = ctk.CTkProgressBar(row, progress_color=bar_color, fg_color="#1e293b", height=8)
            bar.set(0.1)
            bar.pack(side="left", fill="x", expand=True, padx=10)
            self.bars[mood] = bar
            
        txt_title = ctk.CTkLabel(self.left_panel, text="MANUAL INPUT TEXT", font=("Arial", 11, "bold"), text_color="#64748b")
        txt_title.pack(anchor="w", padx=15, pady=(20, 5))
        
        self.text_entry = ctk.CTkEntry(self.left_panel, placeholder_text="Describe your mood here...", 
                                       fg_color="#1a1f2c", border_color="#334155", text_color="white", height=50)
        self.text_entry.pack(fill="x", padx=15, pady=5)
        self.text_entry.insert(0, "I feel incredibly awesome")
        
        self.scan_btn = ctk.CTkButton(self.left_panel, text="Analyze mood →", font=("Arial", 13, "bold"),
                                      fg_color="#a855f7", hover_color="#9333ea", text_color="white", height=40,
                                      command=self.execute_pipeline)
        self.scan_btn.pack(fill="x", padx=15, pady=25)

        # --- RIGHT PANEL (LOGS Terminal Screen) ---
        self.right_panel = ctk.CTkFrame(self, width=320, fg_color="#10141d", corner_radius=8)
        self.right_panel.pack(side="right", fill="y", padx=15, pady=15)
        self.right_panel.pack_propagate(False)
        
        right_title = ctk.CTkLabel(self.right_panel, text="AURALIS PIPELINE TRACE LOGS", font=("Arial", 11, "bold"), text_color="#64748b")
        right_title.pack(anchor="w", padx=15, pady=15)
        
        self.log_box = tk.Text(self.right_panel, font=("Courier", 10), bg="#1a1f2c", fg="#1DB954", 
                               borderwidth=0, highlightthickness=0, state="disabled")
        self.log_box.pack(fill="both", expand=True, padx=15, pady=(0, 15))

        # --- CENTER PANEL ---
        self.center_panel = ctk.CTkFrame(self, fg_color="transparent")
        self.center_panel.pack(side="left", fill="both", expand=True, pady=15)
        
        self.disc_frame = ctk.CTkFrame(self.center_panel, width=220, height=220, corner_radius=110, 
                                       fg_color="#1a1f2c", border_color="#a855f7", border_width=2)
        self.disc_frame.pack(pady=(60, 20))
        self.disc_frame.pack_propagate(False)
        
        disc_core = ctk.CTkLabel(self.disc_frame, text="🎵", font=("Arial", 40))
        disc_core.place(relx=0.5, rely=0.5, anchor="center")
        
        self.track_title_lbl = ctk.CTkLabel(self.center_panel, text="Auralis Dynamic Ambient", font=("Arial", 18, "bold"), text_color="white")
        self.track_title_lbl.pack(pady=5)
        
        self.track_subtitle_lbl = ctk.CTkLabel(self.center_panel, text="Consensus Processing Status...", font=("Arial", 12), text_color="#64748b")
        self.track_subtitle_lbl.pack()
        
        self.playback_bar = ctk.CTkProgressBar(self.center_panel, width=320, progress_color="#a855f7", fg_color="#1e293b", height=4)
        self.playback_bar.set(0.4)
        self.playback_bar.pack(pady=25)
        
        ctrl_strip = ctk.CTkFrame(self.center_panel, fg_color="transparent")
        ctrl_strip.pack()
        prev_btn = ctk.CTkButton(ctrl_strip, text="⏮", width=40, font=("Arial", 16), fg_color="transparent", hover=False)
        prev_btn.pack(side="left", padx=10)
        self.play_btn = ctk.CTkButton(ctrl_strip, text="⏸", width=50, height=50, corner_radius=25, font=("Arial", 18), fg_color="#a855f7", hover_color="#9333ea")
        self.play_btn.pack(side="left", padx=10)
        next_btn = ctk.CTkButton(ctrl_strip, text="⏭", width=40, font=("Arial", 16), fg_color="transparent", hover=False)
        next_btn.pack(side="left", padx=10)

    def write_log(self, text_string):
        self.log_box.configure(state='normal')
        self.log_box.insert(tk.END, text_string + "\n")
        self.log_box.configure(state='disabled')
        self.log_box.see(tk.END)
        self.update()

    def update_interface_bars(self, final_mood):
        for mood in self.bars:
            if mood == final_mood:
                self.bars[mood].set(0.9)
            else:
                self.bars[mood].set(0.1)

    def optimize_camera_modality(self):
        self.write_log("[CAMERA] Booting active streaming matrix scan... Look at the lens!")
        cap = cv2.VideoCapture(0)
        sampled_emotions = []
        frame_counter = 0
        
        while frame_counter < 10:
            ret, frame = cap.read()
            if not ret:
                continue
            frame_counter += 1
            try:
                evaluation = DeepFace.analyze(frame, actions=['emotion'], enforce_detection=False)
                raw_emotion = evaluation[0]['dominant_emotion']
                all_emotions = evaluation[0]['emotion']
                if all_emotions['surprise'] > 25 and all_emotions['happy'] > 25:
                    sampled_emotions.append("energetic")
                else:
                    mapped = config.MOOD_MAPPING.get(raw_emotion, 'neutral')
                    sampled_emotions.append(mapped)
            except Exception:
                pass
                
        cap.release()
        mode_consensus = Counter(sampled_emotions).most_common(1)[0][0] if sampled_emotions else "neutral"
        self.write_log(f"-> Camera Modality Result: {mode_consensus.upper()}")
        return mode_consensus

    def execute_pipeline(self):
        """Calculates mood consensus using a Weighted Decision Matrix to stop Neutral dominance."""
        self.log_box.configure(state='normal')
        self.log_box.delete('1.0', tk.END)
        self.log_box.configure(state='disabled')
        
        self.write_log("=== MULTIMODAL WEIGHTED MATRIX ANALYSIS INITIALIZING ===")
        
        # 1. Capture Camera Modality
        camera_vote = self.optimize_camera_modality()
        
        # 2. Capture Text Modality
        user_text = self.text_entry.get().strip()
        text_vote = "neutral"
        if user_text:
            raw_txt = text_classifier(user_text)[0]['label']
            text_vote = config.MOOD_MAPPING.get(raw_txt, 'neutral')
            if raw_txt in ['joy', 'surprise'] and ("awesome" in user_text or "energetic" in user_text or "excited" in user_text):
                text_vote = "energetic"
            self.write_log(f"-> Text Modality: {text_vote.upper()}")

        # 3. Capture Audio Modality
        recog = sr.Recognizer()
        microphone_vote = "neutral"
        with sr.Microphone() as vocal_source:
            self.write_log("[AUDIO] Tuning ambient stream filters... speak now!")
            recog.adjust_for_ambient_noise(vocal_source, duration=0.8)
            try:
                captured_buffer = recog.listen(vocal_source, timeout=3, phrase_time_limit=3)
                translated_string = recog.recognize_google(captured_buffer)
                self.write_log(f"-> Audio Voice Text: \"{translated_string}\"")
                raw_aud = text_classifier(translated_string)[0]['label']
                microphone_vote = config.MOOD_MAPPING.get(raw_aud, 'neutral')
                if "excited" in translated_string or "energy" in translated_string:
                    microphone_vote = "energetic"
            except Exception:
                self.write_log("-> Audio Stream Empty (Defaulted to Neutral).")

        # --- WEIGHTED MATRIX SCORING SYSTEM ---
        score_board = {"happy": 0.0, "sad": 0.0, "angry": 0.0, "energetic": 0.0, "neutral": 0.0}
        score_board[camera_vote] += 0.60     
        score_board[text_vote] += 0.25       
        score_board[microphone_vote] += 0.15 
        
        final_consensus = max(score_board, key=score_board.get)
        
        self.write_log(f"\n[WEIGHTED CONFIDENCE MATRIX]:")
        for mood, score in score_board.items():
            if score > 0:
                self.write_log(f" - {mood.capitalize()}: {int(score*100)}% reliability weight")
                
        self.write_log(f"\n🧠 Definitive Fusion Consensus: {final_consensus.upper()}")
        
        self.update_interface_bars(final_consensus)
        self.track_title_lbl.configure(text=f"{final_consensus.capitalize()} Flow Station")
        self.track_subtitle_lbl.configure(text=f"Auralis Streaming Context — {final_consensus.upper()}")
        
        self.trigger_spotify_playback(final_consensus)

    def trigger_spotify_playback(self, final_mood):
        """Forces browser fallback to open an official web search query to eliminate 404 blocks."""
        if final_mood == "happy":
            target_val, target_nrg = 0.85, 0.65
            genres_seeds = ['pop', 'happy']
            search_string = "happy%20hits"
        elif final_mood == "energetic":
            target_val, target_nrg = 0.75, 0.95
            genres_seeds = ['edm', 'electro']
            search_string = "energy%20boost"
        elif final_mood == "sad":
            target_val, target_nrg = 0.12, 0.15
            genres_seeds = ['acoustic', 'rainy-day']
            search_string = "sad%20songs"
        elif final_mood == "angry":
            target_val, target_nrg = 0.20, 0.95
            genres_seeds = ['rock', 'metal']
            search_string = "rock%20classics"
        else:
            target_val, target_nrg = 0.50, 0.35
            genres_seeds = ['chill', 'ambient']
            search_string = "chill%20lofi%20beats"

        # Direct official global search query URL - completely immune to account level limitations
        fallback_url = f"https://open.spotify.com/search/{search_string}"

        try:
            recommendation_payload = self.sp.recommendations(seed_genres=genres_seeds, target_valence=target_val, target_energy=target_nrg, limit=5)
            active_targets = self.sp.devices()
            if active_targets['devices']:
                target_device_id = active_targets['devices'][0]['id']
                track_uris_list = [track['uri'] for track in recommendation_payload['tracks']]
                self.sp.start_playback(device_id=target_device_id, uris=track_uris_list)
                self.write_log(f"\n[SPOTIFY] Synced on platform active app node!")
            else:
                self.write_log("\n[FALLBACK] App connection offline. Launching clean web browser search matrix...")
                webbrowser.open(fallback_url)
        except Exception:
            self.write_log(f"\n[FALLBACK] Launching clean web browser search matrix directly...")
            webbrowser.open(fallback_url)


if __name__ == "__main__":
    app = AuralisApp()
    app.mainloop()
