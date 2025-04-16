# Hi3DGen Installation Package

This repository contains everything needed to install and run Hi3DGen, a high-fidelity 3D geometry generation tool that creates 3D models from images using normal map bridging.

## Prerequisites

- **Windows 10/11** with PowerShell
- **Python 3.10** or newer
- **NVIDIA GPU** with CUDA support (recommended)
- **Git** (optional, the installer can download files directly)
- **Hugging Face account** with an authentication token (for accessing model weights)

## Quick Installation

1. **Download this repository** or clone it using Git:
   ```
   git clone https://github.com/huikku/hi3dgen-install.git
   ```

2. **Run the installer**:
   - Double-click `Install_Hi3DGen.bat`
   - Follow the on-screen prompts
   - Provide your Hugging Face token when asked (get one from https://huggingface.co/settings/tokens)

3. **Launch Hi3DGen**:
   - After installation completes, a desktop shortcut will be created
   - Double-click the shortcut or run `run_hi3dgen.bat` in the installation folder

## Manual Installation

If you prefer to install manually, follow these steps:

1. Install Python 3.10 or newer
2. Clone the Hi3DGen repository: `git clone https://github.com/Hi3DGen/Hi3DGen.git`
3. Install required packages: `pip install -r requirements.txt`
4. Create a `.env` file with your Hugging Face token:
   ```
   HUGGINGFACE_TOKEN=your_token_here
   ```
5. Run the application: `python app_fixed.py`

## Usage Tips

### Optimizing for Smooth Models

To create smoother 3D models while maintaining high quality:

1. Increase sampling steps in both stages (50 for Stage 1, 25-30 for Stage 2)
2. Slightly reduce guidance strength (2-2.5) for smoother surfaces
3. Use a consistent seed value for reproducible results

### Advanced Settings

- **Seed**: Controls randomness (set specific value for reproducible results)
- **Guidance Strength**: How closely the model follows the input image (0-10)
- **Sampling Steps**: Number of iterations (more steps = higher quality but slower)

## Troubleshooting

- **Model download issues**: Verify your Hugging Face token is correct in the `.env` file
- **CUDA errors**: Ensure you have compatible NVIDIA drivers installed
- **Path errors**: Make sure to run the application from its installation directory

## Files Included

- `Install_Hi3DGen.bat` - One-click installer
- `install_hi3dgen.ps1` - PowerShell installation script
- `requirements.txt` - List of required Python packages
- `app_fixed.py` - Fixed application file with proper path handling

## Acknowledgments

Hi3DGen is built on the shoulders of giants:
- **3D Modeling:** Based on the SOTA open-source 3D foundation model [Trellis](https://github.com/microsoft/TRELLIS)
- **Normal Estimation:** Builds on leading normal estimation research such as [StableNormal](https://github.com/hugoycj/StableNormal)

## License

This installer is provided under the MIT License. The Hi3DGen model itself may have its own licensing terms.
