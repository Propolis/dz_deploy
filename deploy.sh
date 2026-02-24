#!/bin/bash

# читаем аргументы
for i in "$@"; do
  case $i in
    --app=*) APP="${i#*=}" ;;
    --version=*) VER="${i#*=}" ;;
    --env=*) ENV="${i#*=}" ;;
  esac
done



#проверяем что есть нужные утилиты
for util in git docker nginx curl; do
  command -v $util >/dev/null || { echo "нету $util"; exit 1; }
done

# бэкап
[ -d "app" ] && cp -r app "app_backup_$(date +%s)"

# обнлвляем 
git pull origin main

# пересобераем с новым кодом
docker-compose down
docker-compose up -d --build || {
  echo "ошибка, откатываем"
  git reset --hard ORIG_HEAD
  docker-compose up -d --build
  exit 1
}

# проверяем жив ли сервис
sleep 5
curl -f http://localhost:8000/health || { echo "сервис мертв"; exit 1; }

echo "Готово!"
