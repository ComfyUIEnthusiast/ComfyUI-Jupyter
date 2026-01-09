# Use the base ComfyUI image
FROM yanwk/comfyui-boot:cu128-slim

# Set environment variables for Jupyter
ENV PYTHONUNBUFFERED=1
ENV JUPYTER_PORT=8888

# Install Jupyter Notebook
RUN pip install --no-cache-dir notebook

# Expose ports for ComfyUI (default 8188) and Jupyter
EXPOSE 8188 8888

CMD ["bash", "-c", "python3 ./ComfyUI/main.py & jupyter notebook --ip=0.0.0.0 --port=8888 --allow-root --no-browser --ServerApp.token=pass"]
