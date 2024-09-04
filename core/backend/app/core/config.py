from pydantic_core import MultiHostUrl
from pydantic_settings import BaseSettings, SettingsConfigDict
from sqlalchemy import create_engine

class Configuration(BaseSettings):
    API_V1_STR: str = '/api/v1'
    DOMAIN: str = 'localhost'
    ENVIRONMENT: Literal['local', 'dev', 'live'] = 'local'

    ADMIN_POSTGRES_HOST: str
    ADMIN_POSTGRES_DB: str = ""
    ADMIN_POSTGRES_USER: str
    ADMIN_POSTGRES_PASSWORD: str = ""
    ADMIN_POSTGRES_PORT: int = 5432

    USER_POSTGRES_HOST: str
    USER_POSTGRES_DB: str = ""
    USER_POSTGRES_USER: str
    USER_POSTGRES_PASSWORD: str = ""
    USER_POSTGRES_PORT: int = 5432

    @computed_field  # type: ignore[prop-decorator]
    @property
    def server_host(self) -> str:
        # Use HTTPS for anything other than local development
        if self.ENVIRONMENT == 'local':
            return f"http://{self.DOMAIN}"
        return f"https://{self.DOMAIN}"

    @computed_field  # type: ignore[prop-decorator]
    @property
    def ADMIN_DATABASE_URI(self) -> PostgresDsn:
        return MultiHostUrl.build(
            scheme="postgresql+psycopg",
            host=self.ADMIN_POSTGRES_HOST,
            path=self.ADMIN_POSTGRES_DB,
            username=self.ADMIN_POSTGRES_USER,
            password=self.ADMIN_POSTGRES_PASSWORD,
            port=self.ADMIN_POSTGRES_PORT,
        )

    @computed_field  # type: ignore[prop-decorator]
    @property
    def USER_DATABASE_URI(self) -> PostgresDsn:
        return MultiHostUrl.build(
            scheme="postgresql+psycopg",
            host=self.USER_POSTGRES_HOST,
            path=self.USER_POSTGRES_DB,
            username=self.USER_POSTGRES_USER,
            password=self.USER_POSTGRES_PASSWORD,
            port=self.USER_POSTGRES_PORT,
        )

config = Configuration()  # type: ignore
