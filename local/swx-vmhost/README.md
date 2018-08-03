# swx-vmhost

This is a system76 silverback in the NerdHerd room, with two nVidia GPU cards.

## dm creation

    docker-machine create -d generic --generic-ip-address 172.109.143.82 --generic-ssh-port 10022 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --generic-engine-port 10376 --engine-storage-driver zfs swx-u-ub-vmhost
    swx dm import swx-u-ub-vmhost

##Kanboard Creation
 
	1. Kanboard can be found at https://kanboard.com
		a. Docker file can be found in the kanboard github
	2. Clone Kanboard into directory
		a. #git submodule add https://github.com/kanboard/kanboard.git
	3. Add lines from docker-compose.yml to existing swx-vmhost.yml
		a. Move volumes entries up to the existing Volumes section
		b. Remove ports section
		c. Copy labels from section above
		d. Replace copied name with kanboard
		e. Replace port with 80 in labels
	4. Set SUBDOMAIN Variable
		a. #swx enviornment show
		b. Add kanboard.vmhost.devwerx.org to the existing enviornment
		c. #swx environment set SUBDOMAINS '"traefik.vmhost.devwerx.org","glo-services.vmhost.devwerx.org","glo.vmhost.devwerx.org","glo-demo.vmhost.devwerx.org","neo4j.vmhost.devwerx.org","kanboard.vmhost.devwerx.org"'
	5. Recreate traefik container
		a. #docker-compose up -d traefik
	6. Start kanboard container
		a. #docker-compose up -d kanboard
	7. Update github
		a. #git status
		b. #git add "file" 
		c. #git commit -m "text with what you did"
		d. #git push
