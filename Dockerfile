# Start with Roundcube's official Apache image.
FROM roundcube/roundcubemail:latest-apache as build

# Get rid of development tools & other packages that bloat the image.
RUN \
	apt-get -yq remove \
		cpp \
		dpkg-dev \
		g++ \
		gcc \
		linux-libc-dev \
		m4 \
		pkg-config \
		re2c \
	&& \
	apt-get -yq autoremove && \
	rm -rf /var/lib/apt/lists/*

# Squash our changes otherwise we get no space savings.
FROM scratch
COPY --from=build / /

# Expose the http port.
EXPOSE 80

# Export volumes.
VOLUME /var/roundcube/config

# Set the workdir, entrypoint & default command.
WORKDIR /var/www/html
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["apache2-foreground"]

# Check every once in a while to see if the server is still running.
HEALTHCHECK --interval=30m \
  CMD curl --silent --output /dev/null http://localhost/
