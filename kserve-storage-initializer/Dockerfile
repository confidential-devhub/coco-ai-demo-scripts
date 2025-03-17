FROM quay.io/modh/kserve-storage-initializer:rhoai-2.16

USER 0

WORKDIR /storage-initializer/scripts

# RUN curl -L https://dl.fedoraproject.org/pub/fedora/linux/releases/41/Everything/x86_64/os/Packages/o/openssl-3.2.2-9.fc41.x86_64.rpm -o openssl-3.2.2-9.fc41.x86_64.rpm
RUN microdnf install -y openssl

RUN mkdir keys && chmod 777 keys

RUN mv initializer-entrypoint download-model

ADD decrypt.sh ./initializer-entrypoint

RUN chmod +x initializer-entrypoint