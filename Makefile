include .env

create-repo:
	aws ecr create-repository --repository-name ${CHAINLINK_IMAGE_NAME} --profile ${AWS_PROFILE} --region ${AWS_REGION}
	aws ecr create-repository --repository-name ${EXTERNAL_ADAPTER_IMAGE_NAME} --profile ${AWS_PROFILE} --region ${AWS_REGION}

build-chainlink:
	docker build -t $(CHAINLINK_IMAGE_NAME) .
build-external-adapter:
	docker build -t ${EXTERNAL_ADAPTER_IMAGE_NAME} --platform=linux/amd64 -f ../external-adapter/Dockerfile ../external-adapter

build:
	make build-chainlink
# make build-external-adapter

login:
	aws ecr get-login-password --region ${AWS_REGION} --profile ${AWS_PROFILE}| docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
tag:
	docker tag ${CHAINLINK_IMAGE_NAME} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${CHAINLINK_IMAGE_NAME}:latest
	
# docker tag ${EXTERNAL_ADAPTER_IMAGE_NAME} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${EXTERNAL_ADAPTER_IMAGE_NAME}:latest
push:
	docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${CHAINLINK_IMAGE_NAME}:latest
# docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${EXTERNAL_ADAPTER_IMAGE_NAME}:latest
list:
	aws ecr list-images --repository-name ${CHAINLINK_IMAGE_NAME} --profile ${AWS_PROFILE} --region ${AWS_REGION}
# aws ecr list-images --repository-name ${EXTERNAL_ADAPTER_IMAGE_NAME} --profile ${AWS_PROFILE} --region ${AWS_REGION}


# ECS context: $docker context use {$ecs_context}
dev-deploy:
	 docker compose -f docker-compose-dev.yml up