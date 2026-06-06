FROM mcr.microsoft.com/playwright/python:v1.51.0-noble

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

# Download geospatial data
RUN mkdir -p geography && cd geography && \
    wget -q https://download.geonames.org/export/dump/cities1000.zip && \
    unzip -q cities1000.zip && \
    rm cities1000.zip && \
    wget -q https://geodata.ucdavis.edu/gadm/gadm3.6/gpkg/gadm36_USA_gpkg.zip && \
    unzip -q gadm36_USA_gpkg.zip && \
    rm gadm36_USA_gpkg.zip

COPY pyproject.toml poetry.lock ./

RUN curl -sSL https://install.python-poetry.org | python3 - && \
    ln -s /root/.local/bin/poetry /usr/local/bin/poetry

RUN poetry config virtualenvs.in-project true

RUN poetry install --without dev --no-root

COPY . .

ENV PORT=8000
EXPOSE 8000

# Run the bot directly (environment variables are passed from Render)
CMD ["poetry", "run", "hyacinth"]
