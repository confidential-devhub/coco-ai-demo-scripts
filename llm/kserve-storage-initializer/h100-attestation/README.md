# Important

This is a copy of https://github.com/Azure/az-cgpu-onboarding/blob/main/Confidential-GPU-H100-Onboarding-(CMK-for-Linux).md

I just modified `step-2-attestation.sh` because it was not fully working in this ubuntu image.

## Build

`docker build -t quay.io/<your_user>/h100-attestation .`
`docker push quay.io/<your_user>/h100-attestation`


## Run

1. Change/delete `runtimeClassName` in `attester.yaml`
1. `oc apply -f attester.yaml`
2. When the h100 machine is booted, simply exec in the container and go to `cgpu-h100-auto-onboarding-linux/cgpu-onboarding-package/` and run `bash step-2-attestation.sh`