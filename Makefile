# Определяем переменные для путей к Docker Compose файлам
DOCKER_COMPOSE_TASK = ./DockerComposeTask/docker-compose.yml
MONITORING = ./Monitoring/docker-compose.yml

# Цель по умолчанию
.PHONY: all
all: up

# Запуск всех сервисов из обоих Docker Compose файлов
.PHONY: up
up:
	docker compose -f $(DOCKER_COMPOSE_TASK) up -d
	docker compose -f $(MONITORING) up -d

.PHONY: login

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
	
# Остановка всех сервисов из обоих Docker Compose файлов
.PHONY: down
down:
	docker-compose -f $(DOCKER_COMPOSE_TASK) down
	docker-compose -f $(MONITORING) down

# Пересборка и перезапуск всех сервисов
.PHONY: restart
restart: down prune up login

# Проверка статуса контейнеров
.PHONY: ps
ps:
	docker ps -a

.PHONY: prune
prune:
	docker volume prune -a 