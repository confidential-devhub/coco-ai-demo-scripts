FROM ubuntu

USER 0

RUN apt-get update && apt-get -y install sudo tzdata

ADD cgpu-h100-auto-onboarding-linux /cgpu-h100-auto-onboarding-linux
WORKDIR /cgpu-h100-auto-onboarding-linux/cgpu-onboarding-package/
RUN chmod +x /cgpu-h100-auto-onboarding-linux/cgpu-onboarding-package/step-2-attestation.sh
# CMD /bin/bash -c /cgpu-h100-auto-onboarding-linux/cgpu-onboarding-package/step-2-attestation.sh
CMD /bin/bash -c "sleep infinity"