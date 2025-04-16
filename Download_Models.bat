@echo off
echo Starting Hi3DGen model download...
echo This will download all required model weights.
echo Please make sure you have a .env file with your Hugging Face token.
python scripts\download_weights.py
pause
