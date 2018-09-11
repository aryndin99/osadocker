# Docker Image: Services Base  

**Pre-requisite:** [Docker Service installed and running](../README.md)

This image is primarily used as a base image to build other images.  
This contains the most important software components of the OSA runtime infrastrucure:

| Component | Version |
| ------- | ----------- |
| druid | 0.10.0 | 
| kafka | 0.9.0.0 (scala 2.11) | 
| hadoop | 2.4.1 |
| spark | 2.1.1 (for hadoop 2.4) |
 
The image is automatically built if this is necessary because of dependencies.   
You can manage this image using the `infra/docker/services-base/manage.sh` script, although you are usually not required to manage this image manually. 

## How to start

	./manage.sh start

## Get more options
 
	./manage.sh help

## Dependencies 

* `jdk` 
