imagr.dev
===

I don't use docker enough to remember all the steps. The result is this lazy wrapper script written in bash so all I have to remember is `./wrapper.sh`.

I owe you better docs but this will do for now....based off Graham's [MacTech 2015 Imagr lab](http://grahamgilbert.com/blog/2015/11/12/mactech-2015-hands-on-with-imagr/)

# Software
* [DockerToolbox](https://github.com/docker/toolbox/releases/)
* [AutoDMG](https://github.com/MagerValp/AutoDMG/releases/)
* [NBICreator](https://github.com/NBICreator/NBICreator/releases/)
* [VMWare Fusion v7 or v8](https://www.vmware.com/products/fusion)


# Process

Download and install the stuff above. 

Git Clone this repo to some directory under /Users/$username. (This is a limitation to docker's VMWare Fusion driver ATM.)

  ```bash
  $ git clone https://github.com/clburlison/imagr.dev
  $ cd imagr.dev
  ```

1. Create an image using AutoDMG. Place created dmg inside of `web_root`
1. Create Imagr NBI using NBICrator. Place created nbi inside of `web_root`
1. Copy files from `sample` directory to `web_root` 
1. Follow the yellow brick road below

  **Note:** the `adminUser.pkg` username and password are both "admin" 

1. Start our docker machine 

  ```bash
  $ ./wrapper.sh create
  ```

Keep track of your Virtual Machine's IP address. You'll need to modify your `imagr_config.plist` to match this IP.

1. Start our docker containers

  ```bash
  $ ./wrapper.sh start
  ```

#Stop

You will want to stop your docker virtual machine when not using it.

  ```bash
  $ ./wrapper.sh stop
  ```

#Remove
And when you are permanently done and want to save disk space.

  ```bash
  $ ./wrapper.sh remove
  ```



# Help NetBoot isn't working
Check your bsdpy logs

  ```bash
  $ ./wrapper.sh logs
  ```




# Resources
http://www.container42.com/2015/10/30/docker-networking-reborn/,  
http://grahamgilbert.com/blog/2015/11/12/mactech-2015-hands-on-with-imagr/  