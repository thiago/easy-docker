# Easy Docker

[Easy Docker](https://github.com/trsouz/easy-docker) is a simple command line tools to use the [docker](https://www.docker.com) on day-by-day writen in [bash](http://en.wikipedia.org/wiki/Bash_\(Unix_shell\)).

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

    d [options] command [command options]

    Options:
     -v, --verbose                  Print debug messages
     -f, --force                    Skip user interaction
     -q, --quiet                    Quiet (no output)
     -h, --help                     Display this help and exit
         --version                  Output version information and exit

    Commands:
     ls                             List installed alias
     clean                          Clean images or containers
     install                        Pull a image and create alias

### Example

    d install python
    python -V

## TODO

What do you need? Let me know or fork.