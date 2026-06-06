FROM mcr.microsoft.com/playwright/python:v1.51.0-noble

RUN apt-get update && apt-get install -y \
    build-essential \
    python3-dev \
    curl \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY pyproject.toml poetry.lock ./

RUN curl -sSL https://install.python-poetry.org | python3 - && \
    ln -s /root/.local/bin/poetry /usr/local/bin/poetry

RUN poetry config virtualenvs.in-project true

RUN poetry install --without dev --no-root

COPY . .

# Create .env file without DATABASE_URL – only the individual POSTGRES_* variables
RUN echo '#!/bin/bash\n\
echo "HYACINTH_TZ=$HYACINTH_TZ" > .env\n\
echo "HYACINTH_DISCORD_TOKEN=$HYACINTH_DISCORD_TOKEN" >> .env\n\
echo "POSTGRES_USER=$POSTGRES_USER" >> .env\n\
echo "POSTGRES_PASSWORD=$POSTGRES_PASSWORD" >> .env\n\
echo "POSTGRES_HOST=$POSTGRES_HOST" >> .env\n\
echo "POSTGRES_PORT=$POSTGRES_PORT" >> .env\n\
echo "POSTGRES_DB=$POSTGRES_DB" >> .env\n\
echo "HYACINTH_USE_LOCAL_GEOCODER=true" >> .env\n\
poetry run hyacinth' > start.sh && chmod +x start.sh

ENV PORT=8000
EXPOSE 8000

CMD ["./start.sh"]
