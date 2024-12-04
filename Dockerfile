# Stage 1: Build the WAR file
FROM maven:3.8.3-openjdk-17 AS build


# Copy the custom settings.xml
COPY settings.xml /root/.m2/settings.xml

COPY . /www/p_prj/p_lom/web2023/

WORKDIR /www/p_prj/p_lom/web2023/java_web
RUN mvn clean install


# Stage 2: Create the final image with Tomcat 8 and JDK 17
FROM registry-it.fg.cz:4567/fgit/tomcat:9.0-openjdk17
COPY --from=build /www/p_prj/p_lom/web2023/java_web/web_web2023/target/*.war /usr/local/tomcat/webapps/app.war
COPY --from=build /www/p_prj/p_lom/web2023/ /www/p_prj/p_lom/web2023/
COPY server.xml /usr/local/tomcat/conf/server.xml
COPY keystore /usr/local/tomcat/conf/.keystore

ENV CATALINA_BASE="/usr/local/tomcat"
ENV CATALINA_HOME="/usr/local/tomcat"

# Set environment variables for Tomcat
ENV CATALINA_OPTS="-Dfg.server.xml.docbase=/www/p_prj/p_lom/web2023/java_web/web_web2023/target/web_web2023/ -Dfg.server.xml.cps_config=/www/p_prj/p_lom/web2023/config/sitemap.xml --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.util.concurrent=ALL-UNNAMED --add-opens=java.rmi/sun.rmi.transport=ALL-UNNAMED"

EXPOSE 8080
CMD ["catalina.sh", "run"]


## Stage 2: Create the final image
#FROM eclipse-temurin:17-jdk-alpine
#ARG JAR_FILE=target/*.jar
#COPY --from=build /app/target/*.jar app.jar
#COPY copy /copy
#EXPOSE 8099
#ENTRYPOINT ["java","-jar","/app.jar"]
