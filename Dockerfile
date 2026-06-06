FROM mcr.microsoft.com/playwright/python:v1.51.0-noble

# Install build essentials (gcc, etc.) and Python dev headers
RUN apt-get update && apt-get install -y \
    build-essential \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY pyproject.toml poetry.lock ./
RUN pip install poetry && \
    poetry config virtualenvs.create false && \
    poetry install --without dev
COPY . .
ENV PORT=8000
EXPOSE 8000
CMD ["poetry", "run", "hyacinth"]
