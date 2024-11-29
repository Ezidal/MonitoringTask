# Определяем переменные для путей к Docker Compose файлам
DOCKER_COMPOSE_TASK = ./DockerComposeTask/docker-compose.yml
MONITORING = ./Monitoring/docker-compose.yml

# Цель по умолчанию
.PHONY: all
all: up

# Запуск всех сервисов из обоих Docker Compose файлов
.PHONY: up
up:
	docker-compose -f $(DOCKER_COMPOSE_TASK) up -d
	docker-compose -f $(MONITORING) up -d

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
	docker exec -it wordpress wp option update openid_connect_generic_settings 'a:26:{s:10:\"login_type\";s:4:\"auto\";s:9:\"client_id\";s:7:\"wpadmin\";s:13:\"client_secret\";s:32:\"**********\";s:5:\"scope\";s:20:\"openid profile email\";s:14:\"endpoint_login\";s:70:\"http://localhost:8771/realms/wp/protocol/openid-connect/auth\";s:17:\"endpoint_userinfo\";s:70:\"http://keycloak:8771/realms/wp/protocol/openid-connect/userinfo\";s:14:\"endpoint_token\";s:67:\"http://keycloak:8771/realms/wp/protocol/openid-connect/token\";s:20:\"endpoint_end_session\";s:72:\"http://localhost:8771/realms/wp/protocol/openid-connect/logout\";s:10:\"acr_values\";s:0:\"\";s:12:\"identity_key\";s:18:\"preferred_username\";s:12:\"no_sslverify\";s:1:\"1\";s:20:\"http_request_timeout\";s:1:\"5\";s:15:\"enforce_privacy\";s:1:\"0\";s:22:\"alternate_redirect_uri\";s:1:\"0\";s:12:\"nickname_key\";s:18:\"preferred_username\";s:12:\"email_format\";s:7:\"{email}\";s:18:\"displayname_format\";s:0:\"\";s:22:\"identify_with_username\";s:1:\"0\";s:16:\"state_time_limit\";s:3:\"180\";s:20:\"token_refresh_enable\";s:1:\"1\";s:19:\"link_existing_users\";s:1:\"1\";s:24:\"create_if_does_not_exist\";s:1:\"1\";s:18:\"redirect_user_back\";s:1:\"1\";s:18:\"redirect_on_logout\";s:1:\"1\";s:14:\"enable_logging\";s:1:\"0\";s:9:\"log_limit\";s:4:\"1000\";}' --allow-root
	
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