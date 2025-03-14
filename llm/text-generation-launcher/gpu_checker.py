#!/usr/bin/env python3
import torch
import logging

# Check if a GPU is available and select device
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
logging.info("##############################")
logging.info(f"Using device: {device}")
logging.info("##############################")
print("##################################", flush=True)
print(f"Using device: {device}")
print("##################################", flush=True)