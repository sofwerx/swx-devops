
# Prepare the environment

    trousseau set environment:orange:GALERA_ROOT_PASSWORD $(dd if=/dev/random bs=512 count=1 2>/dev/null | md5sum | awk '{print $1}')
    trousseau set environment:orange:GALERA_XTRABACKUP_PASSWORD $(dd if=/dev/random bs=512 count=1 2>/dev/null | md5sum | awk '{print $1}')
    swx environment switch orange

# Converge

    ./converge.sh

