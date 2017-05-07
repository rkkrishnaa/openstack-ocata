Openstack-ocata bash script installation:
-----------------------------------------

* Openstack ocata bash script deploys openstack ocata software in a fresh ubuntu 16.04 server.
* You can install the required openstack services based on your usecase. Keystone and supporting services are mandatory. 
* For example: 
* If you wish to install openstack only for object storage, you can install openstack swift alone without installing the remaining services.
* If you wish to install only basic services like openstack glance, nova, neutron and horizon, you can install these services alone.

Hardware and Software Requirements:
-----------------------------------

1. A physical or virtual machine with minimum RAM 4GB, HDD 50GB, PROCESSOR 2 Cores and NIC 1 10Gbps.
2. Ubuntu 16.04 operating system.
3. Internet connection without firewall restictions to download openstack software packages from ubuntu official repository.

Installation Script Folder structure:
-------------------------------------

![openstack-ocata](openstack-ocata.png?raw=true)

Steps to run the installer script:
-----------------------------------
On controller node
------------------
* `apt install git`
* `git clone https://github.com/thrinethratechhara/openstack-ocata.git`
* `cd openstack-ocata`
* All input parameters required for installation is available in "userinput.sh". Here you can select the services you want to deploy in your machine. Edit the user input file carefully.
* `bash installer.sh`

To add compute nodes:
---------------------
On compute node
---------------

* `apt install git`
* `git clone https://github.com/thrinethratechhara/openstack-ocata.git`
* `cd openstack-ocata`
* All input parameters required for installation is available in "userinput.sh". Edit the user input file carefully.
* `bash addcomputenode.sh`


Currently, This repo contains only scripts to install basic openstack services. I will update the installation script for the remaining services in future.
