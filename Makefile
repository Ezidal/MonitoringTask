# Определяем переменные для путей к Docker Compose файлам
DOCKER_COMPOSE_TASK = ./DockerComposeTask/docker-compose.yml
MONITORING = ./Monitoring/docker-compose.yml

# Цель по умолчанию
.PHONY: all prune up login down restart ps encrypt decrypt
all: up

up:
	docker compose -f $(DOCKER_COMPOSE_TASK) up -d
	docker compose -f $(MONITORING) up -d

login:
	docker exec -it wordpress /bin/sh -c "\
		docker-entrypoint.sh apache2-foreground & \
		sleep 7 && \
		curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
		chmod +x wp-cli.phar && \
		mv wp-cli.phar /usr/local/bin/wp && \
		wp core install --url=localhost --title=\"site\" --admin_user=test --admin_password=\"test\" --admin_email=test@test.test --allow-root && \
		echo 'Установка плагина Redis...' && \
		wp plugin install redis-cache --activate --allow-root && \
		echo 'Включение Redis...' && \
		wp redis enable --allow-root && \
		chown -R www-data:www-data /var/www/html/ && \
		wp plugin install daggerhart-openid-connect-generic --activate --allow-root && \
		echo 'Настройка завершена!' && \
		wait \
	"
	
down:
	docker compose down
	docker compose -f $(DOCKER_COMPOSE_TASK) down
	docker compose -f $(MONITORING) down

restart: down prune up login

ps:
	docker ps -a

prune:
	make down
	docker volume prune -a 

encrypt:
	docker run --rm -d --name ansible cytopia/ansible sleep infinity
	docker cp ./Monitoring/.env ansible:/data/.env1
	docker cp ./DockerComposeTask/.env ansible:/data/.env2
	docker cp ./.key ansible:/data/.key
	docker exec -it ansible sh -c "ansible-vault encrypt .env1 --vault-password-file .key"
	docker exec -it ansible sh -c "ansible-vault encrypt .env2 --vault-password-file .key"
	docker cp ansible:/data/.env1 ./Monitoring/.env-crypt
	docker cp ansible:/data/.env2 ./DockerComposeTask/.env-crypt
	rm ./Monitoring/.env
	rm ./DockerComposeTask/.env
	docker kill ansible

decrypt:
	docker run --rm -d --name ansible cytopia/ansible sleep infinity
	docker cp ./Monitoring/.env-crypt ansible:/data/.env1
	docker cp ./DockerComposeTask/.env-crypt ansible:/data/.env2
	docker cp ./.key ansible:/data/.key
	docker exec -it ansible sh -c "ansible-vault decrypt .env1 --vault-password-file .key"
	docker exec -it ansible sh -c "ansible-vault decrypt .env2 --vault-password-file .key"
	docker cp ansible:/data/.env1 ./Monitoring/.env
	docker cp ansible:/data/.env2 ./DockerComposeTask/.env
	rm ./Monitoring/.env-crypt
	rm ./DockerComposeTask/.env-crypt
	docker kill ansible

u:
	docker compose up -d

d:
	docker compose down

r:
	make d 
	make u