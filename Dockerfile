FROM mcr.microsoft.com/playwright/python:v1.51.0-noble

# Install build tools, PostgreSQL client libs (for psycopg2), and curl
RUN apt-get update && apt-get install -y \
    build-essential \
    python3-dev \
    curl \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy dependency files first
COPY pyproject.toml poetry.lock ./

# Install Poetry using the official installer
RUN curl -sSL https://install.python-poetry.org | python3 - && \
    ln -s /root/.local/bin/poetry /usr/local/bin/poetry

# Configure Poetry to create virtual environment inside the project
RUN poetry config virtualenvs.in-project true

# Install dependencies (this will compile psycopg2 successfully)
RUN poetry install --without dev

# Copy the rest of the code
COPY . .

# Keep-alive port
ENV PORT=8000
EXPOSE 8000

# Run the bot using the virtual environment
CMD ["poetry", "run", "hyacinth"]
