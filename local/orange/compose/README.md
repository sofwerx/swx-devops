
# Prepare the environment

    trousseau set environment:orange:ETCD_DISCOVERY $(curl -sw "\n" 'https://discovery.etcd.io/new?size=7' | sed -e 's/^https/http/')
    swx environment switch orange

