# FROM quay.io/modh/kserve-storage-initializer@sha256:8be80149e2a41c89bae4ef69a2d18333e2f16afea559c19cdcb664594898a557

FROM ubuntu

USER 0

RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-dev \
    python3 \
    sudo \
    tzdata \
    curl \
    libgl1 \
    binutils \
    xserver-xorg-core \
    && rm -rf /var/lib/apt/lists/*

RUN pip install pip --break-system-packages
RUN pip3 install kserve boto3 urllib3 pydantic numpy pandas --break-system-packages

ADD fenc /bin
ADD h100-attestation/cgpu-h100-auto-onboarding-linux /cgpu-h100-auto-onboarding-linux
RUN chmod +x /cgpu-h100-auto-onboarding-linux/cgpu-onboarding-package/step-2-attestation.sh

WORKDIR /storage-initializer/scripts

RUN mkdir keys && chmod 777 keys

RUN mkdir logs
RUN mkdir local_gpu_verifier
RUN touch logs/current-operation.log
RUN chmod 777 logs/current-operation.log
RUN touch logs/all-operation.log
RUN chmod 777 logs/all-operation.log

# get rid of old entrypoint
# RUN rm initializer-entrypoint

# This is a modified version of original script called by the entrypoint.
# This is enhanced to perform attestation & decryption
ADD original-initializer-entrypoint.py ./original-initializer-entrypoint
RUN chmod +x original-initializer-entrypoint

# Add the main script: must be called like this to replace the entrypoint.
# This script calls:
# - step-2-attestation.sh: the Azure script to attest Nvidia gpus
# - original-initializer-entrypoint: the original entrypoint that perform attestation
ADD run.sh ./initializer-entrypoint
RUN chmod +x initializer-entrypoint

RUN touch ./attestation_log
RUN chmod 777 ./attestation_log

ENTRYPOINT ["/storage-initializer/scripts/initializer-entrypoint"]

