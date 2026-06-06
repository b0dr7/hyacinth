from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from hyacinth.db.models import Base
from hyacinth.settings import get_settings
import os

settings = get_settings()

# Use the prefixed environment variables (with HYACINTH_)
user = os.environ.get('HYACINTH_POSTGRES_USER', '')
password = os.environ.get('HYACINTH_POSTGRES_PASSWORD', '')
host = os.environ.get('HYACINTH_POSTGRES_HOST', '')
port = os.environ.get('HYACINTH_POSTGRES_PORT', '5432')
db_name = os.environ.get('HYACINTH_POSTGRES_DB', '')

# Build connection string
connection_string = f"postgresql://{user}:{password}@{host}:{port}/{db_name}"
engine = create_engine(connection_string, future=True)
Session = sessionmaker(engine)
Base.metadata.create_all(engine)
