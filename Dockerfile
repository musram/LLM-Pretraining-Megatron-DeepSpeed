# Use a PyTorch base image with CUDA support
ARG PYTORCH_IMAGE=nvcr.io/nvidia/pytorch:24.09-py3
FROM ${PYTORCH_IMAGE} as dev-base

# Use bash shell with pipefail option
#SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    SHELL=/bin/bash \
    WORKSPACE=/home/user

# Create a user 'user' and prepare the workspace
RUN useradd -m user && \
    mkdir -p $WORKSPACE/data $WORKSPACE/.ssh && \
    mkdir -p $WORKSPACE/run/secrets/user_ssh_key && \
    chmod 700 $WORKSPACE/.ssh && \
    chown -R user:user $WORKSPACE

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
    sudo && \
    echo "user ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/user && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# **Install NVIDIA utilities inside the container**

# Copy the requirements file and install Python dependencies
COPY requirements.txt $WORKSPACE/
RUN pip install -r $WORKSPACE/requirements.txt

# Set the working directory
WORKDIR $WORKSPACE

# Clone Megatron-DeepSpeed
RUN git clone https://github.com/microsoft/Megatron-DeepSpeed.git 

# Clone the transformers repository
RUN git clone https://github.com/huggingface/transformers.git

# # Change directory into the cloned repository
WORKDIR $WORKSPACE/transformers

# # Install the package in editable mode
RUN pip install -e .

# Set the working directory
WORKDIR $WORKSPACE

# Copy necessary scripts to the workspace
# COPY start.sh entrypoint.sh write-env.sh $WORKSPACE/
#RUN chmod +x $WORKSPACE/start.sh $WORKSPACE/entrypoint.sh $WORKSPACE/write-env.sh

COPY test.sh $WORKSPACE/
RUN chmod +x $WORKSPACE/test.sh


# Set the entrypoint script to run when the container starts (uncomment if needed)
# ENTRYPOINT ["/home/user/entrypoint.sh"]
# CMD ["/home/user/test.sh"]