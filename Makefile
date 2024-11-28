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

# Остановка всех сервисов из обоих Docker Compose файлов
.PHONY: down
down:
	docker-compose -f $(DOCKER_COMPOSE_TASK) down
	docker-compose -f $(MONITORING) down

# Пересборка и перезапуск всех сервисов
.PHONY: restart
restart: down up

# Проверка статуса контейнеров
.PHONY: ps
ps:
	docker-compose -f $(DOCKER_COMPOSE_TASK) ps -a
	docker-compose -f $(MONITORING) ps -a

.PHONY: prune
prune:
	docker-compose -f $(DOCKER_COMPOSE_TASK) down
	docker-compose -f $(MONITORING) down
	docker volume prune -a
	docker system prune -a