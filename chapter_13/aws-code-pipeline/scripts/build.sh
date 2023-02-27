mvn clean install
mkdir artifact
cp target/aws-code-pipeline*.jar artifact
cp scripts/* artifact/
cp appspec.yml artifact/appspec.yml