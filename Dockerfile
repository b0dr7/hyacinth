FROM mcr.microsoft.com/playwright/python:v1.51.0-noble

# Install build essentials, wget, unzip, and postgres libs
RUN apt-get update && apt-get install -y \
    build-essential \
    python3-dev \
    curl \
    libpq-dev \
    wget \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Create geography folder and download/extract the required files
RUN mkdir -p geography && cd geography && \
    # Download and extract cities1000.txt (smaller file)
    wget -q https://download.geonames.org/export/dump/cities1000.zip && \
    unzip -q cities1000.zip && \
    rm cities1000.zip && \
    # Download and extract gadm36_USA.gpkg using a working mirror
    wget -q https://geodata.ucdavis.edu/gadm/gadm3.6/gpkg/gadm36_USA_gpkg.zip && \
    unzip -q gadm36_USA_gpkg.zip && \
    rm gadm36_USA_gpkg.zip && \
    cd ..

# Copy dependency files
COPY pyproject.toml poetry.lock ./

# Install Poetry and dependencies
RUN curl -sSL https://install.python-poetry.org | python3 - && \
    ln -s /root/.local/bin/poetry /usr/local/bin/poetry

RUN poetry config virtualenvs.in-project true

RUN poetry install --without dev --no-root

# Copy the rest of the code
COPY . .

# Create .env file from environment variables
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
