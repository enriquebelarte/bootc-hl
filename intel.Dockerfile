FROM quay.io/centos-bootc/centos-bootc:stream9 
RUN dnf -y install yum-utils kernel-headers \
    http://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
    https://mirror.stream.centos.org/9-stream/CRB/x86_64/os/Packages/ninja-build-1.10.2-6.el9.x86_64.rpm

# Create the repository configuration file
RUN echo "[vault]" > /etc/yum.repos.d/vault.repo \
    && echo "name=Habana Vault" >> /etc/yum.repos.d/vault.repo \
    && echo "baseurl=https://vault.habana.ai/artifactory/rhel/9/9.2" >> /etc/yum.repos.d/vault.repo \
    && echo "enabled=1" >> /etc/yum.repos.d/vault.repo \
    && echo "gpgcheck=0" >> /etc/yum.repos.d/vault.repo
RUN crb enable && \
    dnf install -y libarchive* pandoc habanalabs-firmware habanalabs \
    habanalabs-rdma-core habanalabs-firmware-tools habanalabs-thunk \
    habanatools   
RUN depmod -a

