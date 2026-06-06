FROM mcr.microsoft.com/playwright/python:v1.51.0-noble

RUN apt-get update && apt-get install -y \
    build-essential \
    python3-dev \
    curl \
    libpq-dev \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Download geospatial data (required for local geocoding)
RUN mkdir -p geography && \
    cd geography && \
    wget -q https://download.geonames.org/export/dump/cities1000.zip && \
    unzip -q cities1000.zip && \
    rm cities1000.zip && \
    wget -q https://biogeo.ucdavis.edu/data/gadm3.6/gpkg/gadm36_USA_gpkg.zip && \
    unzip -q gadm36_USA_gpkg.zip && \
    rm gadm36_USA_gpkg.zip && \
    cd ..

COPY pyproject.toml poetry.lock ./

RUN curl -sSL https://install.python-poetry.org | python3 - && \
    ln -s /root/.local/bin/poetry /usr/local/bin/poetry

RUN poetry config virtualenvs.in-project true

RUN poetry install --without dev --no-root

COPY . .

# Create .env file using the HYACINTH_ prefixed variables
RUN echo '#!/bin/bash\n\
echo "HYACINTH_TZ=$HYACINTH_TZ" > .env\n\
echo "HYACINTH_DISCORD_TOKEN=$HYACINTH_DISCORD_TOKEN" >> .env\n\
echo "HYACINTH_POSTGRES_USER=$HYACINTH_POSTGRES_USER" >> .env\n\
echo "HYACINTH_POSTGRES_PASSWORD=$HYACINTH_POSTGRES_PASSWORD" >> .env\n\
echo "HYACINTH_POSTGRES_HOST=$HYACINTH_POSTGRES_HOST" >> .env\n\
echo "HYACINTH_POSTGRES_PORT=$HYACINTH_POSTGRES_PORT" >> .env\n\
echo "HYACINTH_POSTGRES_DB=$HYACINTH_POSTGRES_DB" >> .env\n\
echo "HYACINTH_USE_LOCAL_GEOCODER=true" >> .env\n\
poetry run hyacinth' > start.sh && chmod +x start.sh

ENV PORT=8000
EXPOSE 8000

CMD ["./start.sh"]
