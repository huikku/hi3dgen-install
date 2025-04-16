import os
import sys
import torch
from huggingface_hub import snapshot_download
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Add the current directory to the Python path
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
PARENT_DIR = os.path.dirname(CURRENT_DIR)
sys.path.append(PARENT_DIR)

# Create weights directory
WEIGHTS_DIR = os.path.join(PARENT_DIR, "weights")
os.makedirs(WEIGHTS_DIR, exist_ok=True)

# Get Hugging Face token from environment variable
hf_token = os.getenv("HUGGINGFACE_TOKEN")
if hf_token:
    print("Using Hugging Face token from .env file")
else:
    print("No Hugging Face token found. Some models may not be accessible.")
    print("Please create a .env file with your token: HUGGINGFACE_TOKEN=your_token_here")

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
