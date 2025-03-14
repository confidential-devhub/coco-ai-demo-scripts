FROM quay.io/modh/text-generation-inference@sha256:792e1500548c293eae428cf079fce836e68fbf7d4f7a53b5958c5158a70edfbf

USER 0

ADD gpu_checker.py /usr/local/bin/gpu_checker
ADD run.sh /usr/local/bin/run
RUN chmod +x /usr/local/bin/gpu_checker
RUN chmod +x /usr/local/bin/run