#!/bin/bash

# Check if WANDB_API_KEY and HF_TOKEN are set in the environment
if [ -z "$WANDB_API_KEY" ] || [ -z "$HF_TOKEN" ]; then
  echo "WANDB_API_KEY or HF_TOKEN is not set in the environment."
  exit 1
else
  # Write the WANDB_API_KEY and HF_TOKEN to a .env file
  echo "WANDB_API_KEY=$WANDB_API_KEY" > .env
  echo "HF_TOKEN=$HF_TOKEN" >> .env
  echo "WANDB_API_KEY and HF_TOKEN were written to .env file."
fi