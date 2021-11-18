FROM debian:buster-slim

# culr (optional) for downloading/browsing stuff
# openssh-client (required) for creating ssh tunnel
# net-tools (optional) I needed it to test port binding after ssh tunnel (eg: netstat -ntlp | grep 6443)
# nano (required) buster-slim doesn't even have less. so I needed an editor to view/edit file (eg: /etc/hosts) 
# jq for parsing json (output of az commands, kubectl output etc)
# build-essential needed for wrk
# libssl-dev needed for wrk
RUN apt-get update && apt-get install -y \
	apt-transport-https \
	ca-certificates \
	openssh-client \
    net-tools \
	curl \
	build-essential \
	libssl-dev

COPY binaries/wrk /usr/local/bin/wrk
RUN chmod +x /usr/local/bin/wrk

COPY binaries/init.sh /usr/local/init.sh
RUN chmod +x /usr/local/init.sh

ENTRYPOINT [ "/usr/local/init.sh" ]