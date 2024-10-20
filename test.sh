#!/bin/bash

set -e

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
    echo "NCCL installation is verified."
fi

# Check PyTorch installation
echo "Checking PyTorch installation..."
python -c "import torch; print('PyTorch version:', torch.__version__)" || {
    echo "PyTorch is not installed."
    exit 1
}

# Check if PyTorch can access CUDA
if ! python -c "import torch; print('CUDA available:', torch.cuda.is_available())"; then
    echo "CUDA is not available in PyTorch."
    exit 1
fi

# Test PyTorch distributed
echo "Testing PyTorch distributed..."
python -c "
import torch
if not torch.distributed.is_available():
    raise RuntimeError('PyTorch distributed is not available.')
else:
    print('PyTorch distributed is available.')
"

echo "All tests passed successfully."
