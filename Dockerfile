FROM alpine:3.6

ARG GIT_BRANCH
ARG GIT_COMMIT_ID
ARG GIT_BUILD_TIME
ARG GITHUB_RUN_NUMBER
ARG GITHUB_RUN_ID

LABEL git.branch=${GIT_BRANCH}
LABEL git.commit.id=${GIT_COMMIT_ID}
LABEL git.build.time=${GIT_BUILD_TIME}
LABEL git.run.number=${GITHUB_RUN_NUMBER}
LABEL git.run.id=${TRAVIS_BUILD_WEB_URL}

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
    	kubectl version --client=true

EXPOSE 8001

WORKDIR /opt/nuvlabox

ENTRYPOINT ["./kubernetes-credential-manager.sh"]