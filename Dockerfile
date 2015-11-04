FROM java:openjdk-8

COPY usr /usr

ADD https://s3.amazonaws.com/jruby.org/downloads/1.7.22/jruby-complete-1.7.22.jar /usr/share/java/zookeeper-util/

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

ENTRYPOINT ["/usr/bin/zkutil"]
