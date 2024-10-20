#!/bin/bash

set -e

# Check NVIDIA driver
echo "Checking NVIDIA driver..."
if ! command -v nvidia-smi &> /dev/null; then
    echo "NVIDIA driver is not installed or not in PATH."
else
    nvidia-smi
    echo "NVIDIA driver is verified."
fi

# Check CUDA installation
echo "Checking CUDA installation..."
if ! command -v nvcc &> /dev/null; then
    echo "CUDA is not installed or not in PATH."
    exit 1
else
    nvcc --version
    echo "CUDA installation is verified."
fi

# Check NCCL installation
echo "Checking NCCL installation..."
if ! ldconfig -p | grep -q "libnccl"; then
    echo "NCCL is not installed or not found."
    exit 1
else
    nccl_version=$(ldconfig -p | grep libnccl | awk '{print $1}' | sed 's/libnccl\.so\.//')
    echo "NCCL installation is verified. Version: $nccl_version"
fi

# Check PyTorch installation and CUDA availability
echo "Checking PyTorch installation and CUDA availability..."
python -c "
import torch
print('PyTorch version:', torch.__version__)
print('CUDA available:', torch.cuda.is_available())
print('CUDA version:', torch.version.cuda)
" || {
    echo "PyTorch is not installed or there was an error checking CUDA availability."
    exit 1
}

# Add a GPU availability check
echo "Checking GPU availability..."
python -c "
import torch
if torch.cuda.is_available():
    print(f'GPU is available. Device count: {torch.cuda.device_count()}')
    for i in range(torch.cuda.device_count()):
        print(f'Device {i}: {torch.cuda.get_device_name(i)}')
else:
    print('GPU is not available.')
"

# Test PyTorch distributed
echo "Testing PyTorch distributed..."
python -c "
import torch
if not torch.distributed.is_available():
    raise RuntimeError('PyTorch distributed is not available.')
else:
    print('PyTorch distributed is available.')
"


