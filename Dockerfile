FROM amazoncorretto:11

# Create application volume
RUN mkdir /opt/app

# Install required packages
RUN yum -y update && yum -y install bash curl openssl-devel

# Define environment arguments
ARG APP_NAME
ARG JVM_MIN
ARG JVM_MAX

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
CMD ["/bin/bash","-c","java $JVM_MIN $JVM_MAX -jar $JAR_FILENAME"]
