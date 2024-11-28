* Управление проектом осуществляется с помощью командной строки makefile файлов, ознакомиться со всеми командами можно в самом низу
  
1) Для начала работы скопируем репозиторий
```
git clone https://github.com/Ezidal/MonitoringTask.git
```
2) Проваливаемся внутрь
```
cd MonitoringTask
```
3) Для запуска приложения используем команду
```
make up
```
4) Дождавшись загрузки контейнеров используем следующую команду для автоматической регистрации и настройки wordpress
```
make login
```
5) Приложение запущено и настроено, ознакомиться с работой можно по следующим ссылкам:
--------------------------------
Wordpress - http://localhost/wp-admin
Логин - test
Пароль - test

Grafana - http://localhost:3000/dashboards
Логин - admin
Пароль - admin

Prometheus - http://localhost:9090/targets

Keycloak - http://localhost:8771/admin/master/console/
Логин - admin
Пароль - admin

Promtail - http://localhost:9080/targets

---------------------------------
make up - запуск всех контейнеров
make login - автонастройка wordpress
make down - остановить и удалить все контейнеры
make ps - вывести информацию обо всех контейнерах
make prune - очистить volumes всех контейнеров, вернуть к изначальному виду окружение
make restart - полный перезапуск всех контейнеров, удаление volumes







