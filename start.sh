#!/bin/bash
docker system prune -f
docker compose up -d
docker exec -it app-semaphore /scripts/setup.sh
