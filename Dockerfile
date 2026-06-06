FROM mcr.microsoft.com/playwright/python:v1.51.0-noble
WORKDIR /app
COPY pyproject.toml poetry.lock ./
RUN pip install poetry && \
    poetry config virtualenvs.create false && \
    poetry install --without dev
COPY . .
ENV PORT=8000
EXPOSE 8000
CMD ["poetry", "run", "hyacinth"]
