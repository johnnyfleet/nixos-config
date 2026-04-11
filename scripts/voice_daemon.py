"""Voice Dictate daemon — persistent RealtimeSTT service controlled via named pipe."""

import os
import subprocess
import threading
import time

from RealtimeSTT import AudioToTextRecorder

PIPE_PATH = "/tmp/voice-dictate.pipe"
STATE_PATH = "/tmp/voice-dictate.state"
YDOTOOL_SOCKET = "/run/ydotoold/socket"


def set_state(state):
    with open(STATE_PATH, "w") as f:
        f.write(state)
    print(f"[state] {state}", flush=True)


TERMINAL_CLASSES = {"org.kde.konsole", "org.kde.yakuake", "Alacritty", "kitty", "foot"}


def is_terminal_focused():
    """Check if the focused window is a terminal using kdotool."""
    try:
        result = subprocess.run(
            ["kdotool", "getactivewindow", "getwindowclassname"],
            capture_output=True, text=True, timeout=2,
        )
        window_class = result.stdout.strip()
        return window_class in TERMINAL_CLASSES
    except Exception:
        return False


def inject_text(text):
    """Copy text to clipboard and paste it into the focused window."""
    env = os.environ.copy()
    env["YDOTOOL_SOCKET"] = YDOTOOL_SOCKET

    # Copy to clipboard (trailing space so consecutive sentences don't merge)
    subprocess.run(["wl-copy", text + " "], check=True)
    time.sleep(0.1)

    if is_terminal_focused():
        # Ctrl+Shift+V for terminals — keycodes: 29=ctrl, 42=shift, 47=v
        subprocess.run(["ydotool", "key", "29:1", "42:1", "47:1", "47:0", "42:0", "29:0"], env=env, check=True)
    else:
        # Ctrl+V for everything else
        subprocess.run(["ydotool", "key", "29:1", "47:1", "47:0", "29:0"], env=env, check=True)


def notify(message, urgency="normal"):
    subprocess.run(
        ["notify-send", "-u", urgency, "-a", "Voice Dictate", "Voice Dictate", message],
        check=False,
    )


def main():
    print("[daemon] Starting Voice Dictate daemon...", flush=True)
    print("[daemon] Loading models (tiny.en realtime, base.en final)...", flush=True)

    t0 = time.time()

    recorder = None
    listening = False
    current_text = ""

    def on_realtime_update(text):
        nonlocal current_text
        current_text = text
        print(f"  [live] {text}", flush=True)

    def process_final(text):
        text = text.strip()
        if not text:
            print("[daemon] No speech detected", flush=True)
            return

        print(f"  [FINAL] {text}", flush=True)
        # Run injection in a thread so the recorder loop keeps listening
        threading.Thread(target=_do_inject, args=(text,), daemon=True).start()

    def _do_inject(text):
        inject_text(text)
        notify(f"Typed: {text[:80]}")

    recorder = AudioToTextRecorder(
        model="base.en",
        realtime_model_type="tiny.en",
        compute_type="int8",
        device="cpu",
        enable_realtime_transcription=True,
        realtime_processing_pause=0.3,
        post_speech_silence_duration=1.2,
        on_realtime_transcription_update=on_realtime_update,
        on_recording_stop=lambda: print("[daemon] Recording stopped", flush=True),
    )

    load_time = time.time() - t0
    print(f"[daemon] Models loaded in {load_time:.1f}s", flush=True)

    # Create named pipe
    if os.path.exists(PIPE_PATH):
        os.remove(PIPE_PATH)
    os.mkfifo(PIPE_PATH)
    print(f"[daemon] Listening on {PIPE_PATH}", flush=True)

    set_state("idle")

    # Run recorder.text() in a background thread when listening
    recorder_thread = None

    def recorder_loop():
        """Continuously process speech until listening is toggled off."""
        while listening:
            result = recorder.text()
            if result and result.strip():
                process_final(result)

    try:
        while True:
            # Open pipe (blocks until a writer connects)
            with open(PIPE_PATH, "r") as pipe:
                for line in pipe:
                    cmd = line.strip().lower()
                    if not cmd:
                        continue

                    print(f"[daemon] Command: {cmd}", flush=True)

                    if cmd == "start" and not listening:
                        listening = True
                        set_state("listening")
                        notify("Listening...")
                        recorder_thread = threading.Thread(target=recorder_loop, daemon=True)
                        recorder_thread.start()

                    elif cmd == "stop" and listening:
                        listening = False
                        recorder.stop()
                        set_state("idle")
                        notify("Stopped")
                        if recorder_thread:
                            recorder_thread.join(timeout=5)
                            recorder_thread = None

                    elif cmd == "quit":
                        print("[daemon] Shutting down...", flush=True)
                        listening = False
                        recorder.stop()
                        recorder.shutdown()
                        set_state("stopped")
                        return

    except KeyboardInterrupt:
        print("\n[daemon] Interrupted, shutting down...", flush=True)
        listening = False
        recorder.stop()
        recorder.shutdown()
        set_state("stopped")
    finally:
        if os.path.exists(PIPE_PATH):
            os.remove(PIPE_PATH)
        if os.path.exists(STATE_PATH):
            os.remove(STATE_PATH)


if __name__ == "__main__":
    main()
