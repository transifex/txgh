Implementing on Docker
======================

# Using a pre-made image

The quickest way to get started is to use an existing pre-made image.  Simply run `docker pull mjjacko/txgh` to get started.

This image is intended for developmental purposes as it sets up all of the OS and Ruby environment for you. All you need todo is complete the Txgh server configuration which includes authentication information for both Transifex and GitHub.

To enable easy configuration a mount point is set to '/tmp/txgh'. If this directory exists on the host, Docker will map it for you...otherwise you can always adjust it as needed.

The DockerHub page can be found [here](https://hub.docker.com/r/mjjacko/txgh/)

# Building from scratch

Alternatively you can build your own image. A good place to start is the [Dockerfile](https://github.com/transifex/txgh/blob/devel/Dockerfile) which is already part of the project.