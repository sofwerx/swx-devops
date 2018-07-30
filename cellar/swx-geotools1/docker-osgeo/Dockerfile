FROM ubuntu:16.04

ADD converge.sh /converge.sh

VOLUME /chroot

CMD bash -xc 'cp /converge.sh /chroot/root/converge.sh; chroot /chroot /root/converge.sh'

