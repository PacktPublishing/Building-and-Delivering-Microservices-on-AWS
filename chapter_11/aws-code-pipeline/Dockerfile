FROM public.ecr.aws/docker/library/openjdk:11.0.16
ARG JAR_FILE=aws-code-pipeline*.jar 
COPY ${JAR_FILE} app.jar 
ENTRYPOINT ["java","-jar","/app.jar"] 
EXPOSE 80 
CMD ["echo" "AWS code pipeline appplication executed successfully!"] 