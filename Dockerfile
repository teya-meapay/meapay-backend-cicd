FROM amazoncorretto:11-alpine-jdk

# Create application volume
RUN mkdir /opt/app

# Install required packages
RUN echo "http://nl.alpinelinux.org/alpine/latest-stable/main/" >> /etc/apk/repositories && \
    apk add --no-cache --update bash curl

# Define environment arguments
ARG APP_NAME
ARG JVM_OPTS

# Define environments
ENV WORKDIR_PATH /opt/app
ENV JVM_OPTIONS $JVM_OPTS
ENV JAR_FILENAME "${APP_NAME}.jar"
ENV BUILD_ROOT softpos-buildstack

# Copy application binary
WORKDIR $WORKDIR_PATH
COPY $JAR_FILENAME $WORKDIR_PATH
COPY $BUILD_ROOT/healthcheck.sh $WORKDIR_PATH

# Set default command arguments
CMD ["/bin/bash","-c","java $JVM_OPTIONS -jar $JAR_FILENAME"]
