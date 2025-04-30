from app.core.config import config
from sqlalchemy.ext.asyncio import create_async_engine

admindb_engine = create_async_engine(config.ADMIN_DB_URI.unicode_string())
userdb_engine = create_async_engine(config.USER_DB_URI.unicode_string())
