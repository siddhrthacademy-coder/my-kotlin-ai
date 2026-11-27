FROM eclipse-temurin:17-jdk AS build
WORKDIR /app

# Install curl and unzip
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# Download Kotlin Compiler directly from GitHub (Full URL)
RUN curl -fL -o kotlin.zip "https://github.com" && \
    unzip kotlin.zip -d /opt && \
    rm kotlin.zip

# Download Ktor & Netty JARs directly from Google Maven Mirror
RUN mkdir -p libs && \
    BASE="https://googleapis.com" && \
    curl -fL "$BASE/io/ktor/ktor-server-core-jvm/2.3.8/ktor-server-core-jvm-2.3.8.jar" -o libs/ktor-server-core-jvm.jar && \
    curl -fL "$BASE/io/ktor/ktor-server-netty-jvm/2.3.8/ktor-server-netty-jvm-2.3.8.jar" -o libs/ktor-server-netty-jvm.jar && \
    curl -fL "$BASE/io/ktor/ktor-server-host-common-jvm/2.3.8/ktor-server-host-common-jvm-2.3.8.jar" -o libs/ktor-server-host-common-jvm.jar && \
    curl -fL "$BASE/io/ktor/ktor-http-jvm/2.3.8/ktor-http-jvm-2.3.8.jar" -o libs/ktor-http-jvm.jar && \
    curl -fL "$BASE/io/ktor/ktor-utils-jvm/2.3.8/ktor-utils-jvm-2.3.8.jar" -o libs/ktor-utils-jvm.jar && \
    curl -fL "$BASE/io/ktor/ktor-io-jvm/2.3.8/ktor-io-jvm-2.3.8.jar" -o libs/ktor-io-jvm.jar && \
    curl -fL "$BASE/io/ktor/ktor-events-jvm/2.3.8/ktor-events-jvm-2.3.8.jar" -o libs/ktor-events-jvm.jar && \
    curl -fL "$BASE/io/ktor/ktor-network-jvm/2.3.8/ktor-network-jvm-2.3.8.jar" -o libs/ktor-network-jvm.jar && \
    curl -fL "$BASE/org/jetbrains/kotlinx/kotlinx-coroutines-core-jvm/1.7.3/kotlinx-coroutines-core-jvm-1.7.3.jar" -o libs/coroutines-core.jar && \
    curl -fL "$BASE/org/jetbrains/kotlinx/kotlinx-coroutines-jdk8/1.7.3/kotlinx-coroutines-jdk8-1.7.3.jar" -o libs/coroutines-jdk8.jar && \
    curl -fL "$BASE/org/slf4j/slf4j-api/2.0.9/slf4j-api-2.0.9.jar" -o libs/slf4j-api.jar && \
    curl -fL "$BASE/org/slf4j/slf4j-simple/2.0.9/slf4j-simple-2.0.9.jar" -o libs/slf4j-simple.jar && \
    curl -fL "$BASE/io/netty/netty-all/4.1.104.Final/netty-all-4.1.104.Final.jar" -o libs/netty-all.jar

COPY src ./src

# Compile Application.kt directly
RUN /opt/kotlinc/bin/kotlinc src/main/kotlin/Application.kt -cp "libs/*" -d app.jar

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/libs ./libs
COPY --from=build /opt/kotlinc/lib/kotlin-stdlib.jar ./libs/
COPY --from=build /app/app.jar ./app.jar

CMD ["java", "-cp", "app.jar:libs/*", "ApplicationKt"]
