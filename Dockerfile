FROM alpine:3.6

ARG GIT_BRANCH
ARG GIT_COMMIT_ID
ARG GIT_BUILD_TIME
ARG GITHUB_RUN_NUMBER
ARG GITHUB_RUN_ID
ARG PROJECT_URL

LABEL git.branch=${GIT_BRANCH}
LABEL git.commit.id=${GIT_COMMIT_ID}
LABEL git.build.time=${GIT_BUILD_TIME}
LABEL git.run.number=${GITHUB_RUN_NUMBER}
LABEL git.run.id=${GITHUB_RUN_ID}
LABEL org.opencontainers.image.authors="support@sixsq.com"
LABEL org.opencontainers.image.created=${GIT_BUILD_TIME}
LABEL org.opencontainers.image.url=${PROJECT_URL}
LABEL org.opencontainers.image.vendor="SixSq SA"
LABEL org.opencontainers.image.title="NuvlaEdge Kubernetes Credentials Manager"
LABEL org.opencontainers.image.description="Manages the Kubernetes credentials necessary for managing the NuvlaEdge from Nuvla"

RUN apk update && apk --no-cache add curl openssl

RUN set -eux; \
    	\
    	apkArch="$(apk --print-arch)"; \
    	case "$apkArch" in \
    		x86_64) kubectlArch='amd64' ;; \
    		armv7) kubectlArch='arm' ;; \
    		armhf) kubectlArch='arm' ;; \
        aarch64) kubectlArch='amd64' ;; \
    		*) echo >&2 "error: unsupported architecture ($apkArch) for kubectl"; exit 1 ;;\
    	esac; \
    	\
    	curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/${kubectlArch}/kubectl && \
    	chmod +x ./kubectl && \
    	mv ./kubectl /usr/local/bin/kubectl && \
        which kubectl

EXPOSE 8001

WORKDIR /opt/nuvlaedge

ADD code/ LICENSE ./

ONBUILD RUN ./license.sh

ENTRYPOINT ["./kubernetes-credential-manager.sh"]
