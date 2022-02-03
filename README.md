# monitoring-sandbox

## Getting started

```
vagrant up

# Login to Grafana
# URL:  http://localhost:3001

# Create API Key
# ref. https://grafana.com/docs/grafana/latest/http_api/auth/#create-api-token
# Role: Admin

# Set the generated API Key to GRAFANA_TOKEN
cd grafana
cp .env.sample .env
vim .env

# Create Grafana Resource
docker-compose build
docker-compose run --rm grr jb install
docker-compose run --rm grr grr apply grr.jsonnet
```

- Grafana: http://localhost:3001
- Sensu: http://localhost:3000
