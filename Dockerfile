FROM gradle:8.5-jdk17 AS build
WORKDIR /app
COPY . .
RUN echo 'allprojects { buildscript { repositories { all { ArtifactRepository repo -> if (repo instanceof MavenArtifactRepository && repo.url.toString().contains("repo.maven.apache.org")) { remove repo } } maven { url "https://googleapis.com" } } } repositories { all { ArtifactRepository repo -> if (repo instanceof MavenArtifactRepository && repo.url.toString().contains("repo.maven.apache.org")) { remove repo } } maven { url "https://googleapis.com" } } }' > init.gradle
RUN gradle buildFatJar --init-script init.gradle --no-daemon

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/build/libs/*-all.jar app.jar
CMD ["java", "-jar", "app.jar"]
