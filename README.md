# Easy Docker

[Easy Docker](https://github.com/trsouz/easy-docker) is a simple command line tools to use the [docker](https://www.docker.com) on day-by-day writen in [bash](http://en.wikipedia.org/wiki/Bash_\(Unix_shell\)).

## Dependencies

- [Docker](https://docs.docker.com/installation/)
- [Docker-compose](http://docs.docker.com/compose/install/)


## Installation

By default Docker Easy is installed with alias `d`, but you can specify it during the installation process.

### Install using curl:

    source <(curl -s https://raw.githubusercontent.com/trsouz/easy-docker/master/install_remote.sh)

### Install using wget:

    source <(wget --no-check-certificate https://raw.githubusercontent.com/trsouz/easy-docker/master/install_remote.sh -O -)

### Install using git:

    git clone https://github.com/trsouz/easy-docker.git $HOME/.easydocker
    source $HOME/.easydocker/install.sh

## Usage

    Usage:
    d [options] command [command options]

    Options:
     -f, --force                    Skip user interaction
     -h, --help                     Display this help and exit
     -q, --quiet                    Quiet (no output)
     -v, --verbose                  Print debug messages
     -V, --version                  Output version information and exit

    Commands:
     clean                          Cleanup images or containers
     run                            Run a platform in a new container and remove after exit

### Example

    d run python
    d run node:0.10 -v

## TODO

- Check if `docker` and `docker-compose` are installed and install if not there
- Command `alias` to specific `run` for directly use. Something like `d alias python python:2.7.9` or `d alias npm node:0.10 --entrypoint npm`
- Command `ls` to list platforms and versions available for download and already downloaded


What do you need? Let me know or fork.