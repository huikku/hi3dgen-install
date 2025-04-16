# Hi3DGen Installation Guide

This document provides detailed instructions for installing Hi3DGen on a Windows system.

## System Requirements

- **Operating System**: Windows 10 or Windows 11
- **CPU**: Intel Core i5/i7/i9 or AMD Ryzen 5/7/9 (8th gen or newer recommended)
- **RAM**: 16GB minimum, 32GB recommended
- **GPU**: NVIDIA GPU with at least 8GB VRAM (RTX 2070 or better recommended)
- **Storage**: At least 10GB of free disk space
- **Internet**: Broadband connection for downloading model weights

## Prerequisites Installation

### 1. Install Python 3.10

1. Download Python 3.10 from [python.org](https://www.python.org/downloads/release/python-3109/)
2. Run the installer
3. **Important**: Check "Add Python to PATH" during installation
4. Choose "Customize installation" and ensure pip is selected
5. Complete the installation

Verify installation by opening Command Prompt and typing:
```
python --version
```

### 2. Install Git (Optional)

1. Download Git from [git-scm.com](https://git-scm.com/download/win)
2. Run the installer with default options
3. Verify installation:
```
git --version
```

### 3. Install CUDA Toolkit

Hi3DGen requires CUDA for GPU acceleration:

1. Check your NVIDIA driver version in NVIDIA Control Panel
2. Download CUDA Toolkit 11.8 from [NVIDIA's website](https://developer.nvidia.com/cuda-11-8-0-download-archive)
3. Run the installer with default options
4. Verify installation:
```
nvcc --version
```

### 4. Get a Hugging Face Token

1. Create an account on [Hugging Face](https://huggingface.co/join)
2. Go to [Settings → Access Tokens](https://huggingface.co/settings/tokens)
3. Create a new token with "read" access
4. Copy the token for use during installation

## Automatic Installation

The easiest way to install Hi3DGen is using our automatic installer:

1. Download this repository
2. Double-click `Install_Hi3DGen.bat`
3. When prompted, enter your Hugging Face token
4. Wait for the installation to complete (this may take 15-30 minutes depending on your internet speed)

## Manual Installation

If you prefer to install manually:

### 1. Clone the Repository

```
git clone https://github.com/Hi3DGen/Hi3DGen.git
cd Hi3DGen
```

### 2. Create a Virtual Environment (Optional but Recommended)

```
python -m venv venv
venv\Scripts\activate
```

### 3. Install Dependencies

```
pip install --upgrade pip
pip install -r requirements.txt
```

### 4. Create .env File

Create a file named `.env` in the Hi3DGen directory with the following content:
```
HUGGINGFACE_TOKEN=your_token_here
```
Replace `your_token_here` with your actual Hugging Face token.

### 5. Download Model Weights

Create and run a Python script to download the required model weights:

```python
import os
import sys
import torch
from huggingface_hub import snapshot_download
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Add the current directory to the Python path
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(CURRENT_DIR)

# Create weights directory
WEIGHTS_DIR = os.path.join(CURRENT_DIR, "weights")
os.makedirs(WEIGHTS_DIR, exist_ok=True)

# Get Hugging Face token from environment variable
hf_token = os.getenv("HUGGINGFACE_TOKEN")
if hf_token:
    print("Using Hugging Face token from .env file")
else:
    print("No Hugging Face token found. Some models may not be accessible.")

def download_model(repo_id, local_dir):
    print(f"Downloading {repo_id}...")
    try:
        snapshot_download(repo_id=repo_id, local_dir=local_dir, local_dir_use_symlinks=False, token=hf_token)
        print(f"Successfully downloaded {repo_id} to {local_dir}")
    except Exception as e:
        print(f"Error downloading {repo_id}: {e}")
        print("If this is a private model, make sure you have provided a valid Hugging Face token.")

# Download required models
download_model("Stable-X/trellis-normal-v0-1", os.path.join(WEIGHTS_DIR, "trellis-normal-v0-1"))
download_model("Stable-X/yoso-normal-v1-8-1", os.path.join(WEIGHTS_DIR, "yoso-normal-v1-8-1"))
download_model("ZhengPeng7/BiRefNet", os.path.join(WEIGHTS_DIR, "BiRefNet"))

# Pre-download DINOv2 model
print("Downloading DINOv2 model...")
try:
    torch.hub.load('facebookresearch/dinov2', 'dinov2_vitl14', pretrained=True)
    print("Successfully downloaded DINOv2 model")
except Exception as e:
    print(f"Error downloading DINOv2 model: {e}")

# Pre-download StableNormal model
print("Downloading StableNormal model...")
try:
    # Try with the token if available
    if hf_token:
        torch.hub.load("hugoycj/StableNormal", "StableNormal_turbo", trust_repo=True, yoso_version='yoso-normal-v0-3', token=hf_token)
    else:
        torch.hub.load("hugoycj/StableNormal", "StableNormal_turbo", trust_repo=True, yoso_version='yoso-normal-v0-3')
    print("Successfully downloaded StableNormal model")
except Exception as e:
    print(f"Error downloading StableNormal model: {e}")
    print("Trying alternative version...")
    try:
        # Try with a different version
        if hf_token:
            torch.hub.load("hugoycj/StableNormal", "StableNormal_turbo", trust_repo=True, yoso_version='yoso-normal-v1-8-1', token=hf_token)
        else:
            torch.hub.load("hugoycj/StableNormal", "StableNormal_turbo", trust_repo=True, yoso_version='yoso-normal-v1-8-1')
        print("Successfully downloaded alternative StableNormal model")
    except Exception as e2:
        print(f"Error downloading alternative StableNormal model: {e2}")

print("All model weights downloaded successfully!")
```

Save this as `download_weights.py` and run:
```
python download_weights.py
```

### 6. Fix Path Issues in app.py

Create a fixed version of app.py with proper path handling:

```
import os
import sys
import gradio as gr
import torch
import numpy as np
from typing import *

# Add the current directory to the Python path
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(CURRENT_DIR)

# Rest of the original app.py content...
```

Make sure to fix the examples section to use the correct paths:

```
examples = gr.Examples(
    examples=[
        os.path.join(CURRENT_DIR, 'assets', 'example_image', image)
        for image in os.listdir(os.path.join(CURRENT_DIR, 'assets', 'example_image'))
    ],
    inputs=image_prompt,
)
```

### 7. Run the Application

```
python app_fixed.py
```

## Troubleshooting

### Common Issues

1. **"No module named 'xxx'"**
   - Solution: Install the missing package with `pip install xxx`

2. **CUDA errors**
   - Solution: Make sure you have the correct NVIDIA drivers and CUDA version installed

3. **Model download failures**
   - Solution: Check your Hugging Face token and internet connection

4. **Path errors**
   - Solution: Make sure you're running the application from the Hi3DGen directory

### Getting Help

If you encounter issues not covered here, please:
1. Check the [GitHub Issues](https://github.com/Hi3DGen/Hi3DGen/issues) for similar problems
2. Create a new issue with detailed information about your problem

## Updating

To update Hi3DGen to the latest version:

1. Pull the latest changes:
```
git pull origin main
```

2. Update dependencies:
```
pip install -r requirements.txt --upgrade
```

3. Re-run the application:
```
python app_fixed.py
```
