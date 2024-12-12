import os
import asyncio
import subprocess
from playwright.async_api import async_playwright

# Directory to save recorded CAPTCHA files
OUTPUT_DIR = "recorded_audio_captchas"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# BotDetect CAPTCHA URL
BOTDETECT_URL = "https://captcha.com/audio-captcha-examples.html"

# FFmpeg command template for recording audio
FFMPEG_CMD = [
    "ffmpeg",
    "-y",  # Overwrite output files
    "-f", "gdigrab",  # Windows screen capture (adjust for other OS)
    "-i", "desktop",
    "-vn",  # No video
    "-acodec", "pcm_s16le",
    "-ar", "44100",
    "-ac", "2",
]

async def record_audio(file_path, duration=10):
    """Record system audio for a given duration."""
    cmd = FFMPEG_CMD + [file_path]
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    await asyncio.sleep(duration)
    process.terminate()
    print(f"Saved: {file_path}")

async def capture_audio_captchas():
    async with async_playwright() as p:
        # Launch browser
        browser = await p.chromium.launch()
        page = await browser.new_page()

        # Navigate to the CAPTCHA page
        await page.goto(BOTDETECT_URL)

        # Locate audio play buttons (adjust selector if necessary)
        audio_buttons = await page.locator("audio").all()

        # Process each audio
        for index, button in enumerate(audio_buttons):
            file_path = os.path.join(OUTPUT_DIR, f"captcha_{index + 1}.wav")
            print(f"Playing and recording audio #{index + 1}...")

            # Play the audio
            await button.evaluate("audio => audio.play()")

            # Record the audio while it plays
            await record_audio(file_path, duration=10)

        await browser.close()

if __name__ == "__main__":
    asyncio.run(capture_audio_captchas())
