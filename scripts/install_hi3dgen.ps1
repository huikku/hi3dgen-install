# Hi3DGen Fresh Installation Script
# This script sets up Hi3DGen from scratch on a new computer

# Ensure we're running with administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Please run this script as Administrator. Right-click the script and select 'Run with PowerShell as Administrator'." -ForegroundColor Red
    exit
}

# Set error action preference
$ErrorActionPreference = "Stop"

# Get the current directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$installDir = Join-Path $scriptPath "Hi3DGen"

# Create Hi3DGen directory if it doesn't exist
if (-not (Test-Path -Path $installDir -PathType Container)) {
    Write-Host "Creating Hi3DGen directory..." -ForegroundColor Cyan
    New-Item -Path $installDir -ItemType Directory -Force | Out-Null
    Write-Host "Hi3DGen directory created at: $installDir" -ForegroundColor Green
} else {
    Write-Host "Using existing Hi3DGen directory at: $installDir" -ForegroundColor Green
}

# Function to check Python installation
function Check-PythonInstallation {
    try {
        $pythonVersion = python --version
        Write-Host "Found Python: $pythonVersion" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "Python is not installed or not in PATH." -ForegroundColor Red
        Write-Host "Please install Python 3.10 from https://www.python.org/downloads/" -ForegroundColor Yellow
        Write-Host "Make sure to check 'Add Python to PATH' during installation." -ForegroundColor Yellow
        return $false
    }
}

# Function to check Git installation
function Check-GitInstallation {
    try {
        $gitVersion = git --version
        Write-Host "Found Git: $gitVersion" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "Git is not installed or not in PATH." -ForegroundColor Red
        Write-Host "Please install Git from https://git-scm.com/downloads" -ForegroundColor Yellow
        return $false
    }
}

# Function to install Python packages will be defined later

# Function to clone Hi3DGen repository
function Clone-Hi3DGenRepo {
    Set-Location -Path $scriptPath

    Write-Host "Getting Hi3DGen repository..." -ForegroundColor Cyan

    # First try downloading ZIP file (preferred method for most users)
    try {
        $zipUrl = "https://github.com/Stable-X/Hi3DGen/archive/refs/heads/main.zip"
        $zipPath = Join-Path $scriptPath "Hi3DGen.zip"
        $extractPath = Join-Path $scriptPath "Hi3DGen-main"

        Write-Host "Downloading Hi3DGen ZIP file..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath

        Write-Host "Extracting ZIP file..." -ForegroundColor Yellow
        Expand-Archive -Path $zipPath -DestinationPath $scriptPath -Force

        # Rename the extracted folder to Hi3DGen
        if (Test-Path -Path $extractPath -PathType Container) {
            if (Test-Path -Path $installDir -PathType Container) {
                Remove-Item -Path $installDir -Recurse -Force
            }
            Rename-Item -Path $extractPath -NewName "Hi3DGen"
            Write-Host "Hi3DGen files extracted successfully." -ForegroundColor Green
        }

        # Clean up ZIP file
        Remove-Item -Path $zipPath -Force
    }
    catch {
        Write-Host "Failed to download and extract Hi3DGen ZIP. Error: $_" -ForegroundColor Red
        Write-Host "Trying Git clone method..." -ForegroundColor Yellow

        # Try git clone as fallback
        try {
            # Check if Git is installed
            if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
                throw "Git is not installed or not in PATH."
            }

            git clone https://github.com/Stable-X/Hi3DGen.git
            if ($LASTEXITCODE -ne 0) {
                throw "Git clone failed with exit code $LASTEXITCODE"
            }
            Write-Host "Hi3DGen repository cloned successfully." -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to clone Hi3DGen repository. Error: $_" -ForegroundColor Red
            Write-Host "Please download Hi3DGen manually from https://github.com/Hi3DGen/Hi3DGen" -ForegroundColor Yellow
            exit
        }
    }
}

# Function to create a fixed app.py file
function Create-FixedAppPy {
    $appPyPath = Join-Path $installDir "app.py"
    $appFixedPyPath = Join-Path $installDir "app_fixed.py"

    if (-not (Test-Path -Path $appPyPath -PathType Leaf)) {
        Write-Host "app.py not found. Cannot create fixed version." -ForegroundColor Red
        return
    }

    Write-Host "Creating modified app.py with path fixes..." -ForegroundColor Cyan

    # Read the original app.py
    $appPyContent = Get-Content -Path $appPyPath -Raw

    # Add CURRENT_DIR definition at the top
    $importSection = @"
import os
import sys
import gradio as gr
import torch
import numpy as np
from typing import *

# Add the current directory to the Python path
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(CURRENT_DIR)

"@

    # Fix the examples section
    $examplesPattern = "examples = gr\.Examples\([\s\S]*?\)\s*\)"
    $newExamples = @"
examples = gr.Examples(
        examples=[
            os.path.join(CURRENT_DIR, 'assets', 'example_image', image)
            for image in os.listdir(os.path.join(CURRENT_DIR, 'assets', 'example_image'))
        ],
        inputs=image_prompt,
    )
"@

    # Replace the import section
    $appPyContent = $appPyContent -replace "import gradio as gr.*?from typing import \*", $importSection

    # Replace the examples section
    $appPyContent = $appPyContent -replace $examplesPattern, $newExamples

    # Save the modified app.py
    $appPyContent | Set-Content $appFixedPyPath -Force
    Write-Host "Created modified app.py at: $appFixedPyPath" -ForegroundColor Green
}

# Function to create a batch file to run the app
function Create-BatchFile {
    $appFixedPyPath = Join-Path $installDir "app_fixed.py"
    $batchFilePath = Join-Path $installDir "run_hi3dgen.bat"

    @"
@echo off
echo Starting Hi3DGen...
python "$appFixedPyPath"
"@ | Set-Content $batchFilePath -Force

    Write-Host "Created batch file at: $batchFilePath" -ForegroundColor Green
}

# Function to create a desktop shortcut
function Create-DesktopShortcut {
    $batchFilePath = Join-Path $installDir "run_hi3dgen.bat"
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = Join-Path $desktopPath "Hi3DGen.lnk"

    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = $batchFilePath
    $Shortcut.WorkingDirectory = $installDir
    $Shortcut.Description = "Run Hi3DGen 3D Model Generator"
    $Shortcut.Save()

    Write-Host "Created desktop shortcut: $shortcutPath" -ForegroundColor Green
}

# Function to create .env file with Hugging Face token
function Create-EnvFile {
    Write-Host "Setting up Hugging Face authentication..." -ForegroundColor Cyan

    # Ask for Hugging Face token
    Write-Host "A Hugging Face token is required to download some models." -ForegroundColor Yellow
    Write-Host "You can get your token from: https://huggingface.co/settings/tokens" -ForegroundColor Yellow
    $hfToken = Read-Host "Please enter your Hugging Face token (press Enter to skip if you don't have one)"

    # Create .env file
    $envFilePath = Join-Path $installDir ".env"
    if ($hfToken) {
        @"
HUGGINGFACE_TOKEN=$hfToken
"@ | Set-Content $envFilePath -Force
        Write-Host "Created .env file with Hugging Face token." -ForegroundColor Green
    } else {
        Write-Host "No token provided. Some models may not be accessible." -ForegroundColor Yellow
        @"
# Get your token from https://huggingface.co/settings/tokens and add it here:
# HUGGINGFACE_TOKEN=your_token_here
"@ | Set-Content $envFilePath -Force
    }
}

# Function to check CUDA installation
function Check-CudaInstallation {
    Write-Host "Checking CUDA installation..." -ForegroundColor Cyan

    try {
        $nvidiaSmiOutput = nvidia-smi
        Write-Host "NVIDIA GPU detected:" -ForegroundColor Green
        Write-Host $nvidiaSmiOutput -ForegroundColor Gray
        return $true
    } catch {
        Write-Host "NVIDIA GPU not detected or CUDA not installed." -ForegroundColor Yellow
        Write-Host "Hi3DGen requires a CUDA-capable GPU for optimal performance." -ForegroundColor Yellow
        Write-Host "You can download CUDA from: https://developer.nvidia.com/cuda-downloads" -ForegroundColor Yellow

        $continue = Read-Host "Continue installation anyway? (y/n)"
        if ($continue -ne "y" -and $continue -ne "Y") {
            return $false
        }
        return $true
    }
}

# Function to download model weights
function Download-ModelWeights {
    Write-Host "Preparing to download model weights..." -ForegroundColor Cyan

    # Create weights directory
    $weightsDir = Join-Path $installDir "weights"
    if (-not (Test-Path -Path $weightsDir -PathType Container)) {
        New-Item -Path $weightsDir -ItemType Directory -Force | Out-Null
    }

    # Check for Hugging Face token in .env file
    $envFilePath = Join-Path $installDir ".env"
    $hfToken = ""
    if (Test-Path -Path $envFilePath -PathType Leaf) {
        $envContent = Get-Content -Path $envFilePath -Raw
        if ($envContent -match "HUGGINGFACE_TOKEN=([^\r\n]+)") {
            $hfToken = $matches[1]
            Write-Host "Found Hugging Face token in .env file." -ForegroundColor Green
        }
    }

    # Create a simple Python script to download weights
    $downloadScriptPath = Join-Path $installDir "download_weights.py"
    @"
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
"@ | Set-Content $downloadScriptPath -Force

    # Run the download script
    Write-Host "Downloading model weights (this may take some time)..." -ForegroundColor Yellow
    Set-Location -Path $installDir
    python $downloadScriptPath

    Write-Host "Model weights downloaded successfully." -ForegroundColor Green
}

# Add python-dotenv to the packages list
function Install-PythonPackages {
    Write-Host "Installing required Python packages..." -ForegroundColor Cyan

    # Update pip first
    Write-Host "Updating pip..." -ForegroundColor Yellow
    python -m pip install --upgrade pip

    # List of required packages
    $packages = @(
        "torch torchvision --index-url https://download.pytorch.org/whl/cu118",
        "gradio",
        "numpy",
        "pillow",
        "trimesh",
        "huggingface_hub",
        "diffusers",
        "transformers",
        "accelerate",
        "xformers",
        "spconv-cu118",
        "opencv-python",
        "matplotlib",
        "python-dotenv"  # Added for .env file support
    )

    foreach ($package in $packages) {
        Write-Host "Installing $package..." -ForegroundColor Yellow
        try {
            python -m pip install $package
            if ($LASTEXITCODE -ne 0) {
                throw "Package installation failed with exit code $LASTEXITCODE"
            }
            Write-Host "$package installed successfully." -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to install $package. Error: $_" -ForegroundColor Red
            Write-Host "You may need to install this package manually." -ForegroundColor Yellow
        }
    }
}

# Main execution
try {
    Write-Host "=== Hi3DGen Fresh Installation Script ===" -ForegroundColor Cyan

    # Check prerequisites
    $pythonInstalled = Check-PythonInstallation
    $gitInstalled = Check-GitInstallation
    $cudaInstalled = Check-CudaInstallation

    if (-not $pythonInstalled) {
        Write-Host "Python is required. Please install Python and run this script again." -ForegroundColor Red
        exit
    }

    # Git is optional - we'll use direct download if Git is not available
    if (-not $gitInstalled) {
        Write-Host "Git is not installed. Will use direct download instead." -ForegroundColor Yellow
    }

    if (-not $cudaInstalled) {
        Write-Host "Installation canceled due to missing CUDA support." -ForegroundColor Red
        exit
    }

    # Clone Hi3DGen repository
    Clone-Hi3DGenRepo

    # Install required packages
    Install-PythonPackages

    # Create .env file with Hugging Face token
    Create-EnvFile

    # Create fixed app.py
    Create-FixedAppPy

    # Create batch file
    Create-BatchFile

    # Create desktop shortcut
    Create-DesktopShortcut

    # Download model weights
    Download-ModelWeights

    Write-Host "Installation completed successfully!" -ForegroundColor Green
    Write-Host "You can now run Hi3DGen by:" -ForegroundColor Green
    Write-Host "1. Double-clicking the desktop shortcut" -ForegroundColor Green
    Write-Host "2. Double-clicking the run_hi3dgen.bat file in the Hi3DGen folder" -ForegroundColor Green

    # Ask if user wants to run the app now
    $runNow = Read-Host "Do you want to run Hi3DGen now? (y/n)"
    if ($runNow -eq "y" -or $runNow -eq "Y") {
        Write-Host "Running Hi3DGen..." -ForegroundColor Cyan
        $appFixedPyPath = Join-Path $installDir "app_fixed.py"
        Set-Location -Path $installDir
        python $appFixedPyPath
    }
}
catch {
    Write-Host "An error occurred during installation: $_" -ForegroundColor Red
    Write-Host "Please check the error message and try again." -ForegroundColor Yellow
}
