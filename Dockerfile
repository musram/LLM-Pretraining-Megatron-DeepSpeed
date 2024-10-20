ARG BASE_IMAGE=nvcr.io/nvidia/pytorch:24.09-py3
FROM ${BASE_IMAGE}
# 
# Set environment variables
ENV HOME_DIR=/home/user
ENV BASE_SRC_PATH=${HOME_DIR}/Megatron-DeepSpeed
ENV BASE_DATA_PATH=${BASE_SRC_PATH}/dataset

# Install system dependencies including sudo
RUN apt-get update --yes && \
    apt-get upgrade --yes && \
    apt-get install --yes --no-install-recommends \
    build-essential \
    zlib1g-dev \
    libncurses5-dev \
    libgdbm-dev \
    libnss3-dev \
    libssl-dev \
    libsqlite3-dev \
    libreadline-dev \
    libffi-dev \
    liblzma-dev \
    libbz2-dev \
    nano \
    curl \
    wget \
    net-tools \
    iputils-ping \
    pdsh \
    git \
    bash \
    openssh-server \
    sudo \
    xz-utils \
    libaio-dev \
    rustc \
    cargo && \
    echo "user ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/user && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install NVIDIA utilities inside the container
# RUN apt-get update && \
#     apt-get install -y openmpi-bin libopenmpi-dev libibverbs-dev && \
#     apt-get install -y --no-install-recommends nvidia-utils-555 && \
#     rm -rf /var/lib/apt/lists/*

# Install PyTorch using conda (conda is pre-installed in the PyTorch base image)
# RUN conda install -y -v pytorch==2.4.0 torchvision==0.19.0 torchaudio==2.4.0 pytorch-cuda=12.4 -c pytorch -c nvidia 

# Upgrade pip and install Python packages
RUN python -m pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    deepspeed transformers pybind11 nltk ipython matplotlib 
# RUN pip install --no-cache-dir torch-scatter torch-sparse torch-cluster 
# # Clone and install NVIDIA Apex
# RUN git clone https://github.com/NVIDIA/apex && \
#     cd apex && \
#     pip install -v --disable-pip-version-check --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./ && \
#     cd .. && \
#     rm -rf apex

# Clone Megatron-DeepSpeed
RUN git clone https://github.com/microsoft/Megatron-DeepSpeed.git ${BASE_SRC_PATH}

# # Download and preprocess dataset
# WORKDIR ${BASE_DATA_PATH}
# RUN wget https://huggingface.co/bigscience/misc-test-data/resolve/main/stas/oscar-1GB.jsonl.xz && \
#     xz -d oscar-1GB.jsonl.xz && \
#     bash download_vocab.sh

# # Preprocess data for oscar dataset
# RUN python3 ${BASE_SRC_PATH}/tools/preprocess_data.py \
#     --input ${BASE_DATA_PATH}/oscar-1GB.jsonl \
#     --output-prefix ${BASE_DATA_PATH}/my-gpt2 \
#     --vocab-file ${BASE_DATA_PATH}/gpt2-vocab.json \
#     --dataset-impl mmap \
#     --tokenizer-type GPT2BPETokenizer \
#     --merge-file ${BASE_DATA_PATH}/gpt2-merges.txt \
#     --append-eod \
#     --workers 8

# Install FlashAttention (optional)
WORKDIR ${BASE_SRC_PATH}
RUN git clone --recursive https://github.com/ROCmSoftwarePlatform/flash-attention.git && \
    cd flash-attention && \
    py_version=$(python -V | grep -oP '(?<=[.])\w+(?=[.])')
RUN cd ${BASE_SRC_PATH}/flash-attention && python setup.py install

# Set working directory
WORKDIR ${HOME_DIR}

COPY test.sh /usr/local/bin/test.sh
RUN chmod +x /usr/local/bin/test.sh

# Command to run when the container starts
CMD ["/usr/local/bin/test.sh"]
