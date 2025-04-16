import os
import sys
import re

def fix_app_py(app_py_path):
    """
    Fix path issues in app.py and create app_fixed.py
    """
    if not os.path.exists(app_py_path):
        print(f"Error: {app_py_path} not found")
        return False
    
    try:
        # Read the original app.py
        with open(app_py_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Add CURRENT_DIR definition at the top
        import_section = """import os
import sys
import gradio as gr
import torch
import numpy as np
from typing import *

# Add the current directory to the Python path
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(CURRENT_DIR)

"""
        
        # Replace the import section
        content = re.sub(r'import gradio as gr.*?from typing import \*', 
                         import_section, content, flags=re.DOTALL)
        
        # Fix the examples section
        examples_pattern = r'examples = gr\.Examples\([\s\S]*?\)\s*\)'
        new_examples = """examples = gr.Examples(
        examples=[
            os.path.join(CURRENT_DIR, 'assets', 'example_image', image)
            for image in os.listdir(os.path.join(CURRENT_DIR, 'assets', 'example_image'))
        ],
        inputs=image_prompt,
    )"""
        
        content = re.sub(examples_pattern, new_examples, content)
        
        # Save the modified app.py as app_fixed.py
        app_fixed_path = os.path.join(os.path.dirname(app_py_path), 'app_fixed.py')
        with open(app_fixed_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"Created fixed app.py at: {app_fixed_path}")
        return True
    
    except Exception as e:
        print(f"Error fixing app.py: {e}")
        return False

if __name__ == "__main__":
    # Get the app.py path from command line or use default
    if len(sys.argv) > 1:
        app_py_path = sys.argv[1]
    else:
        # Assume we're in the scripts directory
        current_dir = os.path.dirname(os.path.abspath(__file__))
        parent_dir = os.path.dirname(current_dir)
        app_py_path = os.path.join(parent_dir, 'app.py')
    
    if fix_app_py(app_py_path):
        print("Successfully fixed app.py paths")
    else:
        print("Failed to fix app.py paths")
