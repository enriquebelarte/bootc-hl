text
network --bootproto=static --device=ens99f0 --ip=10.253.231.147 --netmask=255.255.255.192 --gateway=10.253.231.129 --nameserver=10.255.0.1
zerombr
clearpart --all --initlabel --disklabel=gpt
reqpart --add-boot
part / --grow --fstype xfs

#ostreecontainer --no-signature-verification --url quay.io/ebelarte/rhel-bootc:mytag
ostreecontainer --url=/run/install/repo/habana-oci --transport=oci --no-signature-verification

firewall --disabled
services --enabled=sshd

rootpw --plaintext foobars --allow-ssh

