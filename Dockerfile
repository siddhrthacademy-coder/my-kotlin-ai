FROM gradle:8.5-jdk17 AS build
WORKDIR /app
COPY . .

RUN printf 'allprojects {\n\
    buildscript {\n\
        repositories {\n\
            all { ArtifactRepository repo ->\n\
                if (repo instanceof MavenArtifactRepository && repo.url.toString().contains("repo.maven.apache.org")) {\n\
                    remove repo\n\
                }\n\
            }\n\
            maven { url "https://googleapis.com" }\n\
        }\n\
    }\n\
    repositories {\n\
        all { ArtifactRepository repo ->\n\
            if (repo instanceof MavenArtifactRepository && repo.url.toString().contains("repo.maven.apache.org")) {\n\
                remove repo\n\
            }\n\
        }\n\
        maven { url "https://googleapis.com" }\n\
    }\n\
}\n' > init.gradle

RUN gradle buildFatJar --init-script init.gradle --no-daemon

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/build/libs/*-all.jar app.jar
CMD ["java", "-jar", "app.jar"]
