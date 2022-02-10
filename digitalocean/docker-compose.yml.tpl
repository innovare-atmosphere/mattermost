version: "2.4"

services:
  postgres:
    container_name: postgres_mattermost
    image: postgres:13-alpine
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    pids_limit: 100
    read_only: true
    tmpfs:
      - /tmp
      - /var/run/postgresql
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      # timezone inside container
      - TZ=UTC
      # necessary Postgres options/variables
      - POSTGRES_USER=mmuser
      - POSTGRES_PASSWORD=${database_password}
      - POSTGRES_DB=mattermost

  mattermost:
    depends_on:
      - postgres
    container_name: mattermost
    image: mattermost/mattermost-team-edition:5.39
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    pids_limit: 200
    read_only: false
    tmpfs:
      - /tmp
    volumes:
      - ./config:/mattermost/config:rw
      - ./data:/mattermost/data:rw
      - ./logs:/mattermost/logs:rw
      - ./plugins:/mattermost/plugins:rw
      - ./client_plugins:/mattermost/client/plugins:rw
    environment:
      # timezone inside container
      - TZ=UTC

      # necessary Mattermost options/variables (see env.example)
      - MM_SQLSETTINGS_DRIVERNAME=postgres
      - MM_SQLSETTINGS_DATASOURCE=postgres://mmuser:${database_password}@postgres:5432/mattermost?sslmode=disable&connect_timeout=10

      # additional settings
      #- MM_SERVICESETTINGS_SITEURL
    ports:
      - 8065:8065

volumes:
  postgres_data:
    driver: local