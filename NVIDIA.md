# NVIDIA

When using NVIDIA on docker, it is best to install `nvidia-docker2`, and then setup `dockerd` to use `--default-runtime=nvidia`

With that enabled, all containers on that docker-engine will now be able to use the nVidia GPU hardware.

# Prepare the docker-engine host

To find the latest cuda library for the linux flavor and release you are using for your docker-engine host:

- https://developer.nvidia.com/cuda-downloads

For example, to install the the current latest `nvidia-410` driver and CUDA on ubuntu 18.04:

    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-repo-ubuntu1804_10.0.130-1_amd64.deb
    sudo dpkg -i cuda-repo-ubuntu1804_10.0.130-1_amd64.deb
    sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
    sudo apt-get update
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository -y ppa:graphics-drivers
    sudo apt-get update
    sudo apt-get install -y nvidia-driver-410 xserver-xorg-video-nvidia-410 libnvidia-cfg1-410 libnvidia-gl-410 nvidia-dkms-410 libnvidia-decode-410 libnvidia-encode-410 nvidia-kernel-source-410 nvidia-utils-410
    sudo apt-get install -y cuda

For nvidia-docker2:

    # Add the package repositories
    curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
    sudo apt-get update
    sudo apt-get install -y nvidia-docker2
    sudo pkill -SIGHUP dockerd

Now you should be able to run this and see your nvidia card:

    nvidia-smi

Before you install nvidia-docker2`, you will want to make sure your `docker-ce` is up to date as well:

    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce nvidia-docker2

Now you should be able to run this and see your nvidia card:

    docker run -ti --rm --runtime=nvidia nvidia/cuda nvidia-smi

The final remaning step to prepare your docker-engine is to edit your `dockerd` startup script and add this to the end:

    --default-runtime=nvidia

On a docker-machine generic driver provisioned ubuntu 16.04 host, I need to edit:

    sudo vi /etc/systemd/system/docker.service.d/10-machine.conf

Changing this line:

    ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:50376 -H unix:///var/run/docker.sock --storage-driver overlay2 --tlsverify --tlscacert /etc/docker/ca.pem --tlscert /etc/docker/server.pem --tlskey /etc/docker/server-key.pem --label provider=generic

To:

    ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:50376 -H unix:///var/run/docker.sock --storage-driver overlay2 --tlsverify --tlscacert /etc/docker/ca.pem --tlscert /etc/docker/server.pem --tlskey /etc/docker/server-key.pem --label provider=generic --default-runtime=nvidia

Now we tell systemd to reload the services from disk:

    systemctl daemon-reload

And then restart docker:

    systemctl restart docker

Now you should be able to run this and see your nvidia card:

    docker run -ti --rm nvidia/cuda nvidia-smi

Your docker-engine is now ready to run docker containers that use the nvidia GPU.
