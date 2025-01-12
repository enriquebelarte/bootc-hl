ARG BASEIMAGE="quay.io/centos-bootc/centos-bootc:stream9"
FROM ${BASEIMAGE}

ARG OS_VERSION_MAJOR=''
ARG DRIVER_VERSION=1.15.1-15
ARG TARGET_ARCH=''
ARG KERNEL_VERSION=''
ARG REDHAT_VERSION='el9'

RUN if [ "${OS_VERSION_MAJOR}" == "" ]; then \
        . /etc/os-release \
        && export OS_VERSION_MAJOR="$(echo ${VERSION} | cut -d'.' -f 1)" ;\
       fi \
    && if [ "${TARGET_ARCH}" == "" ]; then \
       export TARGET_ARCH=$(arch) ;\
       fi \
    && if [ "${KERNEL_VERSION}" == "" ]; then \
       KERNEL_VERSION=$(dnf info kernel | awk '/Version/ {v=$3} /Release/ {r=$3} END {print v"-"r}') ;\
       && export KERNEL_VERSION ;\
       fi \
       # Workaround for missing ninja-build package
    && if [ -f /etc/redhat-release ]; then \
       dnf install -y https://mirror.stream.centos.org/9-stream/CRB/x86_64/os/Packages/ninja-build-1.10.2-6.el9.x86_64.rpm ;\
       fi \
    && dnf install -y make git kmod kernel-headers-${KERNEL_VERSION} \
       http://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
    && if [ -f /etc/centos-release ]; then \
       dnf -y install ninja-build ;\
       fi 
# Create the repository configuration file
RUN echo "[vault]" > /etc/yum.repos.d/vault.repo \
    && echo "name=Habana Vault" >> /etc/yum.repos.d/vault.repo \
    && echo "baseurl=https://vault.habana.ai/artifactory/rhel/9/9.2" >> /etc/yum.repos.d/vault.repo \
    && echo "enabled=1" >> /etc/yum.repos.d/vault.repo \
    && echo "gpgcheck=0" >> /etc/yum.repos.d/vault.repo
# Install habanalabs modules,firmware and libraries
RUN dnf install -y libarchive* pandoc habanalabs-firmware-${DRIVER_VERSION}.${REDHAT_VERSION} \     habanalabs-${DRIVER_VERSION}.${REDHAT_VERSION} habanalabs-rdma-core-${DRIVER_VERSION}.${REDHAT_VERSION} \
    habanalabs-firmware-tools-${DRIVER_VERSION}.${REDHAT_VERSION} habanalabs-thunk-${DRIVER_VERSION}.${REDHAT_VERSION} && \
    dnf clean all
RUN depmod -a 

# Include growfs service
COPY build/usr /usr

ARG INSTRUCTLAB_IMAGE
ARG VLLM_IMAGE

# Prepull the instructlab image
RUN IID=$(podman --root /usr/lib/containers/storage pull oci:/run/.input/vllm) && \
    podman --root /usr/lib/containers/storage image tag ${IID} ${VLLM_IMAGE}
#RUN IID=$(podman --root /usr/lib/containers/storage pull oci:/run/.input/instructlab-intel) && \
#    podman --root /usr/lib/containers/storage image tag ${IID} ${INSTRUCTLAB_IMAGE}
# 
