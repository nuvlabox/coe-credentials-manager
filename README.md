# NuvlaBox Kubernetes Credential Manager

[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg?style=for-the-badge)](https://github.com/nuvlabox/kubernetes-credential-manager/graphs/commit-activity)


[![CI](https://img.shields.io/travis/com/nuvlabox/kubernetes-credential-manager?style=for-the-badge&logo=travis-ci&logoColor=white)](https://travis-ci.com/nuvlabox/kubernetes-credential-manager)
[![GitHub issues](https://img.shields.io/github/issues/nuvlabox/kubernetes-credential-manager?style=for-the-badge&logo=github&logoColor=white)](https://GitHub.com/nuvlabox/kubernetes-credential-manager/issues/)
[![Docker pulls](https://img.shields.io/docker/pulls/nuvlabox/kubernetes-credential-manager?style=for-the-badge&logo=Docker&logoColor=white)](https://cloud.docker.com/u/nuvlabox/repository/docker/nuvlabox/kubernetes-credential-manager)
[![Docker image size](https://img.shields.io/microbadger/image-size/nuvlabox/kubernetes-credential-manager?style=for-the-badge&logo=docker&logoColor=white)](https://cloud.docker.com/u/nuvlabox/repository/docker/nuvlabox/kubernetes-credential-manager)


**This repository contains the source code for the NuvlaBox Kubernetes Credential Manager - the microservice which is responsible for generating and approving the credentials that are used by Nuvla to connect to the CaaS infrastructure.**

This microservice is an integral component of the NuvlaBox Engine.

---

**NOTE:** this microservice is part of a loosely coupled architecture, thus when deployed by itself, it might not provide all of its functionalities. Please refer to https://github.com/nuvlabox/deployment for a fully functional deployment

---

## Build the NuvlaBox Kubernetes Credential Manager

This repository is already linked with GitHub CI, so with every commit, a new Docker image is released. 


## Deploy the NuvlaBox Kubernetes Credential Manager

### Prerequisites 

 - *Docker (version 18 or higher)*
 - *Docker Compose (version 1.23.2 or higher)*
 - *Kubernetes*
 
## Contributing

This is an open-source project, so all community contributions are more than welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md)
 
## Copyright

Copyright &copy; 2021, SixSq Sàrl
