# Hi3DGen Usage Guide

This guide provides tips and best practices for using Hi3DGen to create high-quality 3D models from images.

## Getting Started

1. Launch Hi3DGen by double-clicking the desktop shortcut or running `run_hi3dgen.bat`
2. The web interface will open in your browser at `http://localhost:7860`

## Basic Workflow

### 1. Upload an Image

- Click the "Upload" button or drag and drop an image into the input area
- For best results, use images with:
  - Clear, well-lit subjects
  - Simple backgrounds
  - Good contrast
  - Single objects (rather than complex scenes)

### 2. Generate the 3D Model

- Click the "Generate Shape" button
- Wait for the process to complete (typically 1-3 minutes depending on your hardware)
- The process happens in two stages:
  1. Sparse Structure Generation
  2. Structured Latent Generation

### 3. View and Export the Result

- The 3D model will appear in the viewer on the right
- Use your mouse to rotate, pan, and zoom the model
- Select an export format (GLB, OBJ, STL, etc.) from the dropdown
- Click "Export Mesh" to download the 3D model

## Advanced Settings

Hi3DGen provides several advanced settings to fine-tune the generation process:

### Seed

- Controls the randomness of the generation process
- Setting a specific seed value allows you to reproduce the same results
- Range: -1 to 2147483647
- Default: 0
- Tips:
  - Use -1 for a random seed each time
  - Note down seed values for successful generations

### Stage 1: Sparse Structure Generation

**Guidance Strength**:
- Controls how closely the generated 3D structure follows the input image
- Range: 0-10
- Default: 3
- Tips:
  - Higher values (4-6): More faithful to the input image
  - Lower values (1-2): Smoother results with less detail
  - Very high values (7+): May introduce artifacts

**Sampling Steps**:
- Controls how many iterations the algorithm performs
- Range: 1-50
- Default: 50
- Tips:
  - Higher values: Better quality but slower
  - For smooth results: Use maximum (50)
  - For quick tests: Use 20-30

### Stage 2: Structured Latent Generation

**Guidance Strength**:
- Controls detail refinement in the final model
- Range: 0-10
- Default: 3
- Tips:
  - Higher values: More detailed but potentially noisier
  - Lower values: Smoother but may lose some details

**Sampling Steps**:
- Controls the number of refinement iterations
- Range: 1-50
- Default: 16
- Tips:
  - For high quality: Use 25-30
  - For maximum quality: Use 50 (but significantly slower)
  - For quick tests: Use 10-15

## Optimization Strategies

### For Smoother Models

To create smoother 3D models while maintaining high quality:

1. **Stage 1 Settings**:
   - Guidance Strength: 2-2.5 (slightly lower than default)
   - Sampling Steps: 50 (maximum)

2. **Stage 2 Settings**:
   - Guidance Strength: 2.5-3
   - Sampling Steps: 25-30 (higher than default)

### For More Detailed Models

To capture more details from the input image:

1. **Stage 1 Settings**:
   - Guidance Strength: 4-5 (higher than default)
   - Sampling Steps: 50 (maximum)

2. **Stage 2 Settings**:
   - Guidance Strength: 3.5-4
   - Sampling Steps: 30-40 (much higher than default)

### For Faster Generation

For quicker results (at the cost of some quality):

1. **Stage 1 Settings**:
   - Guidance Strength: 3 (default)
   - Sampling Steps: 30 (lower than default)

2. **Stage 2 Settings**:
   - Guidance Strength: 3 (default)
   - Sampling Steps: 10 (lower than default)

## Best Practices for Different Object Types

### Organic Objects (People, Animals, Plants)

- Guidance Strength: 2.5-3
- Sampling Steps: High (40-50)
- Tips: Slightly lower guidance strength creates smoother, more natural surfaces

### Mechanical/Hard-Surface Objects

- Guidance Strength: 3.5-4
- Sampling Steps: High (40-50)
- Tips: Higher guidance strength preserves sharp edges and mechanical details

### Architectural Objects

- Guidance Strength: 3-3.5
- Sampling Steps: High (40-50)
- Tips: Use images with clear perspective for better results

## Post-Processing

Hi3DGen generates 3D models that may benefit from additional processing:

1. **Mesh Cleanup**: Use tools like Blender or MeshLab to:
   - Remove isolated vertices
   - Fill holes
   - Smooth surfaces

2. **Texture Improvement**: The generated models include basic textures, but you can:
   - Re-project the original image as a texture
   - Create custom UV maps
   - Add materials in Blender or other 3D software

3. **Decimation**: Reduce polygon count for web/game use:
   - Use Blender's Decimate modifier
   - Aim for 50-80% reduction while preserving shape

## Troubleshooting

### Common Issues

1. **Incomplete or Distorted Models**
   - Try a different seed value
   - Ensure the input image has good contrast and lighting
   - Try increasing guidance strength

2. **Slow Generation**
   - Reduce sampling steps for faster results
   - Check that your GPU is being utilized properly
   - Close other GPU-intensive applications

3. **Missing Details**
   - Increase guidance strength
   - Use higher sampling steps
   - Try a different seed value

4. **Crashes During Generation**
   - Your GPU may be running out of memory
   - Try reducing sampling steps
   - Restart the application

## Examples

Here are some example settings for different types of images:

| Image Type | Stage 1 Guidance | Stage 1 Steps | Stage 2 Guidance | Stage 2 Steps |
|------------|------------------|---------------|------------------|---------------|
| Portrait   | 2.5              | 50            | 2.5              | 25            |
| Product    | 3.5              | 50            | 3.5              | 30            |
| Sculpture  | 3.0              | 50            | 3.0              | 30            |
| Vehicle    | 4.0              | 50            | 3.5              | 35            |
| Furniture  | 3.0              | 40            | 3.0              | 25            |

## Advanced Tips

- **Multiple Images**: Use the "Multiple Images" tab for generating models from different angles
- **Batch Processing**: For multiple models, run separate instances or process sequentially
- **Memory Management**: Close and restart the application between complex generations to free GPU memory
- **Export Formats**: GLB is best for preserving materials, OBJ for compatibility, STL for 3D printing
