#! /bin/bash

echo "params "
echo $@

/bin/bash -c /cgpu-h100-auto-onboarding-linux/cgpu-onboarding-package/step-2-attestation.sh > attestation_log 2>&1
echo "############################################"
echo "Attestation results"
head -n 1 attestation_log
cat attestation_log | awk 'END{print}'
echo "############################################"

./original-initializer-entrypoint $@