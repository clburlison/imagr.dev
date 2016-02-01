#!/bin/sh 

set -e

DRIVER="vmwarefusion"
VMNAME="imagr"
VMDISKSIZE="500000"
VMMEM="2048"
VMCPU="2"
# BRIDGED_IP="10.11.11.17"
# USE_BRIDGED=False

#################################################################################
# End user of variables - Functions be below
#################################################################################

RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# I literally can't even...
# So here is a hacky way to get around environment variables
ldock() {
  eval "$(docker-machine env ${VMNAME})"
  eval DATA_DIR=`pwd`/web_root
  if [[ ${USE_BRIDGED} = true ]] ; then
      msg "Using bridged IP address: ${BRIDGED_IP}" 
      eval IP=${BRIDGED_IP}
      export IP=${BRIDGED_IP} 
  else
      eval IP=$(docker-machine ip ${VMNAME})
      export IP=$(docker-machine ip ${VMNAME})
  fi
  export DATA_DIR=`pwd`/web_root
}

msg() {
  printf "${CYAN}$1 \n${NC}"
}

error() {
  printf "${RED}$1 \n${NC}"
}

# Work in progress
getBridgeAdapterIP() {
  msg "work in progress"
}

# Work in progress
createBridgedAdpater() {
  msg "work in progress"
}

check() {
  CHECKVAR=$(docker-machine ls | sed "s/\ \{2,\}/$(printf '\t')/g" | awk -F"\t" '/imagr/{print $4}')

  if [[ ${CHECKVAR} == 'Stopped' ]]; then
    msg "Starting your Docker VM"
    docker-machine start ${VMNAME}
  elif [[ ${CHECKVAR} == 'Running' ]]; then
    msg "Your docker VM is running."
  else
    msg "Your Docker VM doesn't appear to be created."
  fi    
}

create() {
  msg "Creating Docker Virtual Machine "
  if [[ ${DRIVER} == 'vmwarefusion' ]]; then
    msg "${DRIVER} has been selected as driver"
    docker-machine create --vmwarefusion-memory-size=${VMMEM} \
    --vmwarefusion-cpu-count=${VMCPU} \
    --vmwarefusion-disk-size=${VMDISKSIZE} \
    -d vmwarefusion ${VMNAME}
  elif [[ ${DRIVER} == 'virtualbox' ]]; then
    msg "${DRIVER} has been selected as driver"
    docker-machine create ----virtualbox-memory=${VMMEM} \
    --virtualbox-cpu-count=${VMCPU} \
    --virtualbox-disk-size=${VMDISKSIZE} \
    -d virtualbox ${VMNAME}
  else 
    msg "Invalid VM driver. Please use 'vmwarefusion' or 'virtualbox' "  
  fi
  
  # store the IP address of the docker virtual machine
  IP=$(docker-machine ip ${VMNAME})
  msg "***YOUR DOCKER IP IS "$IP" ***"

  wait
}

data() {
  DATA_DIR=`pwd`/web_root

  # see if we have a directory to store docker containers
  if [[ ! -e "$DATA_DIR" ]] ; then
      printf "${RED}'web_root' directory must be created manually "
      msg "Please run: "
      msg  "   mkdir `pwd`/docker "
      exit 1
  fi
}

pull() {
  msg "Pull docker container(s) "
  check
  ldock
  
  docker-compose pull
  wait
}

start() {
  msg "Start docker containers "
  check
  ldock
  data
  msg "${IP}"
  msg "${DATA_DIR}"
  
  docker-compose up -d
  wait
}

restart() {
  msg "Restart docker containers "
  check
  ldock
  data
  msg "${IP}"
  msg "${DATA_DIR}"
  
  docker-compose stop
  docker-compose rm -f
  docker-compose up -d
  wait
}

stop() {
  # check
  ldock
  msg "Do you want to stop your Docker VM, '${VMNAME}'? [yN]  "
  read ANSWER
  if [[ ${ANSWER} == 'y' ]]; then
    msg "Stopping your Docker VM"
    docker-machine stop ${VMNAME}
  else
    msg "Your Docker VM is still running."
  fi
  wait
}

remove() {
  msg "Removing docker-machine '${VMNAME}' "
  docker-machine rm ${VMNAME}

  wait
}

logs() {
  check
  ldock
  msg "Checking bsdpy logs "
  CONTAINER_NAME=$(docker ps | grep "bsdpy" | sed "s/\ \{2,\}/$(printf '\t')/g" | awk -F"\t" '/imagr/{print $7}')
  docker logs $CONTAINER_NAME
  
  wait
}

case $1 in
  create)
    create
    ;;
  pull)
    pull
    ;;
  start)
    start
    ;;
  restart)
    restart
    ;;
  stop)
    stop
    ;;
  remove)
    remove
    ;;
  logs)
    logs
    ;;  
  *)
    error "Unsupported argument!"
    msg "Supported arguments:"
    msg "  create - create your docker VM"
    msg "  pull - pull required containers"
    msg "  start - start docker containers from docker-compose.yml"
    msg "  restart - restart docker containers from scratch"
    msg "  stop - stop docker-machine vm"
    msg "  remove - remove docker-machine vm"
    msg "  logs - check bsdpy logs"
    exit 1
    ;;
esac