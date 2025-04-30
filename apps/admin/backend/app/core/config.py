from pydantic import field_validator, computed_field, PostgresDsn, ValidationInfo
from pydantic_core import MultiHostUrl, Literal
from pydantic_settings import BaseSettings, SettingsConfigDict

class Configuration(BaseSettings):
    API_V1_STR: str = '/api/v1'
    DOMAIN: str = 'localhost'
    ENVIRONMENT: Literal['local', 'dev', 'stage', 'live'] = 'local'

    DB_SCHEME: str = 'postgresql+psycopg'
    DB_CONNECTION_POOL_SIZE: int

    ADMIN_DB_HOST: str
    ADMIN_DB: str = ''
    ADMIN_DB_USER: str
    ADMIN_DB_PASSWORD: str = ''
    ADMIN_DB_PORT: int = 5432

    USER_DB_HOST: str
    USER_DB: str = ''
    USER_DB_USER: str
    USER_DB_PASSWORD: str = ''
    USER_DB_PORT: int = 5432

    @computed_field  # type: ignore[prop-decorator]
    @property
    def server_host(self) -> str:
        # Use HTTPS for anything other than local development
        if self.ENVIRONMENT == 'local':
            return f"http://{self.DOMAIN}"
        return f"https://{self.DOMAIN}"

    @computed_field  # type: ignore[prop-decorator]
    @property
    def ADMIN_DB_URI(self) -> PostgresDsn:
        return MultiHostUrl.build(
            scheme=self.DB_SCHEME,
            host=self.ADMIN_DB_HOST,
            path=self.ADMIN_DB,
            username=self.ADMIN_DB_USER,
            password=self.ADMIN_DB_PASSWORD,
            port=self.ADMIN_DB_PORT,
        )

    @computed_field  # type: ignore[prop-decorator]
    @property
    def USER_DB_URI(self) -> PostgresDsn:
        return MultiHostUrl.build(
            scheme=self.DB_SCHEME,
            host=self.USER_DB_HOST,
            path=self.USER_DB,
            username=self.USER_DB_USER,
            password=self.USER_DB_PASSWORD,
            port=self.USER_DB_PORT,
        )

config = Configuration()  # type: ignore
