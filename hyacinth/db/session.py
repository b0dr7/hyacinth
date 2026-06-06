from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from hyacinth.db.models import Base
from hyacinth.settings import get_settings
import os

settings = get_settings()
credentials = f"{settings.postgres_user}:{settings.postgres_password}"
host = f"{os.environ['POSTGRES_HOST']}:{os.environ['POSTGRES_PORT']}/{os.environ['POSTGRES_DB']}"
connection_string = f"postgresql://{credentials}@{host}"
engine = create_engine(connection_string, future=True)
Session = sessionmaker(engine)
Base.metadata.create_all(engine)
