FROM nvidia/cuda:13.0.0-devel-ubuntu24.04

# Non-interactive frontend
ENV DEBIAN_FRONTEND=noninteractive
ENV TORCH_CUDA_ARCH_LIST="8.9" 

# Update system and install basic tools & Python
RUN apt-get update && apt-get install -y \
	supervisor \
    python3.12 python3.12-venv python3.12-dev python3-pip \
    git wget curl build-essential cmake libjpeg-dev zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*
	
# Make python3.12 the default python
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1 \
    && python --version
	
# Create a virtual environment for all Python packages
ENV VENV_PATH=/opt/venv
RUN python -m venv $VENV_PATH

# Ensure the virtual environment is used for all subsequent commands
ENV PATH="$VENV_PATH/bin:$PATH"

# Upgrade pip and install PyTorch + torchvision for CUDA 13
RUN pip install --upgrade pip

# Install PyTorch nightly compatible with CUDA 13
RUN pip install --pre torch --index-url https://download.pytorch.org/whl/nightly/cu130 \
    torchvision --pre --index-url https://download.pytorch.org/whl/nightly/cu130

RUN pip install https://github.com/mjun0812/flash-attention-prebuild-wheels/releases/download/v0.7.16/flash_attn-2.8.3%2Bcu130torch2.10-cp312-cp312-linux_x86_64.whl

# Clone ComfyUI repo
RUN git clone --recurse-submodules https://github.com/comfyanonymous/ComfyUI.git /root/ComfyUI

WORKDIR /root/ComfyUI

# Install Python dependencies
RUN pip install -r requirements.txt

WORKDIR /

# Install Jupyter Notebook inside venv for supervisord
RUN pip install notebook

#Copy supervisor
COPY supervisord.conf .

# Start ComfyUI
CMD ["/usr/bin/supervisord", "-c", "/supervisord.conf"]
