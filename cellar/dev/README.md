# dev

This is how I spawn my local "dev" docker-engine virtual machine on my mac under VMWare fusion:

    docker-machine create --driver vmwarefusion --vmwarefusion-cpu-count=2 --vmwarefusion-disk-size 40000 --vmwarefusion-memory-size 4096 dev

