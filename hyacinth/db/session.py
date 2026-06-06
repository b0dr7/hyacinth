import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from hyacinth.db.models import Base

# Read database connection details from environment variables (without HYACINTH_ prefix)
user = os.environ.get('POSTGRES_USER')
password = os.environ.get('POSTGRES_PASSWORD')
host = os.environ.get('POSTGRES_HOST')
port = os.environ.get('POSTGRES_PORT', '5432')
db_name = os.environ.get('POSTGRES_DB')

# Validate that all required variables are present
if not all([user, password, host, db_name]):
    raise ValueError(f"Missing database environment variables. USER: {user}, HOST: {host}, DB: {db_name}")

# Build the connection string
connection_string = f"postgresql://{user}:{password}@{host}:{port}/{db_name}"

# Create engine and session
engine = create_engine(connection_string, future=True)
Session = sessionmaker(engine)

# Create tables if they don't exist
Base.metadata.create_all(engine)
