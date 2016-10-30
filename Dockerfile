FROM alpine:3.4
COPY install.sh run.sh post-commit.sh /opt/git-flux/
RUN ["/bin/sh", "/opt/git-flux/install.sh"]
ENTRYPOINT ["/bin/sh", "/opt/git-flux/run.sh"]
CMD []