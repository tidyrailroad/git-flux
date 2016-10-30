FROM alpine:3.4
RUN ["/bin/sh", "/opt/git-flux/install.sh"]
ENTRYPOINT ["/bin/sh", "/opt/git-flux/run.sh"]
CMD []