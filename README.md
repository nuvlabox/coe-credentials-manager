# NuvlaEdge Kubernetes Credential Manager

[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg?style=for-the-badge)](https://github.com/nuvlaedge/kubernetes-credentials-manager/graphs/commit-activity)

[![GitHub issues](https://img.shields.io/github/issues/nuvlaedge/kubernetes-credentials-manager?style=for-the-badge&logo=github&logoColor=white)](https://GitHub.com/nuvlaedge/kubernetes-credentials-manager/issues/)
[![Docker pulls](https://img.shields.io/docker/pulls/nuvlaedge/kubernetes-credentials-manager?style=for-the-badge&logo=Docker&logoColor=white)](https://cloud.docker.com/u/nuvlaedge/repository/docker/nuvlaedge/kubernetes-credentials-manager)
[![Docker image size](https://img.shields.io/docker/image-size/nuvladev/kubernetes-credentials-manager/main?logo=docker&logoColor=white&style=for-the-badge)](https://cloud.docker.com/u/nuvlaedge/repository/docker/nuvladev/kubernetes-credentials-manager)


![CI Build](https://github.com/nuvlaedge/kubernetes-credentials-manager/actions/workflows/main.yml/badge.svg)
![CI Release](https://github.com/nuvlaedge/kubernetes-credentials-manager/actions/workflows/release.yml/badge.svg)


**This repository contains the source code for the NuvlaEdge Kubernetes Credential Manager - the microservice which is responsible for generating and approving the credentials that are used by Nuvla to connect to the CaaS infrastructure.**

This microservice is an integral component of the NuvlaEdge software.

---

**NOTE:** this microservice is part of a loosely coupled architecture, thus when deployed by itself, it might not provide all of its functionalities. Please refer to https://github.com/nuvlaedge/deployment for a fully functional deployment

---

## Build the NuvlaEdge Kubernetes Credential Manager

This repository is already linked with GitHub CI, so with every commit, a new Docker image is released.


## Deploy the NuvlaEdge Kubernetes Credential Manager

### Prerequisites

 - *Docker (version 18 or higher)*
 - *Docker Compose (version 1.23.2 or higher)*
 - *Kubernetes*

## Contributing

This is an open-source project, so all community contributions are more than welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md)

## Copyright

Copyright &copy; 2021, SixSq SA
