#!/usr/bin/env bash

#################################
# include the -=magic=-
# you can pass command line args
#
# example:
# to disable simulated typing
# . ../demo-magic.sh -d
#
# pass -h to see all options
#################################
. ./demo-magic.sh

########################
# Configure the options
########################

#
# speed at which to simulate typing. bigger num = faster
#
# TYPE_SPEED=20

#
# custom prompt
#
# see http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/bash-prompt-escape-sequences.html for escape sequences
#
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

# text color
# DEMO_CMD_COLOR=$BLACK

# hide the evidence
clear

# enters interactive mode and allows newly typed command to be executed
cmd

# here's a program we made earlier
pe "less ./bpf/xdp_counter.c"

# we'll package this in a container to make it easy to deploy using bpfman
pe "less ./Containerfile"

# build the container and push to quay - ensure this is done ahead of time
p "podman build --target userspace -t quay.io/bpfman/fosdem24:latest . "
p "podman build --target bpf -t quay.io/bpfman/fosdem24:bpf-latest . "
p "podman push quay.io/bpfman/fosdem24:latest"
p "podman push quay.io/bpfman/fosdem24:bpf-latest"

# no programs loaded
pe "sudo bpfman list"

# load our program - remember to do this ahead of time (once) also to avoid network
pe "sudo bpfman load image --image-url quay.io/bpfman/fosdem24:bpf-latest xdp --iface eth0 --priority 10"

# 1 programs loaded
pe "sudo bpfman list"

# Run the userspace program, no sudo required
pe "sudo ./bpfman-fosdem24 -iface eth0 -id $id"

# load another program, ahead of the first one
pe "sudo bpfman load image xdp --image-url quay.io/bpfman-bytecode/xdp_pass:latest --iface eth0 --priority 1"

# 2 programs loaded
pe "sudo bpfman list"

# enters interactive mode and allows newly typed command to be executed
cmd

# show a prompt so as not to reveal our true nature after
# the demo has concluded
p ""
