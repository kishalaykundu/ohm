CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS ohm.user (
    _id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid text DEFAULT uuid_generate_v4 (), -- generated herein USER DB and added in other DB's referencing this --
    ayushid text UNIQUE, -- (optional) provided by government - Unique Health ID --
    aadhaar varchar(16) UNIQUE, -- currently 12 digits extensible to 16 in the future --
    pan varchar(16) UNIQUE, -- currently 10 digits extensible to 16 in the future --
    name text NOT NULL,
    phone varchar(32) NOT NULL, -- assumption: we won't get a phone number > 32 digits --
    email varchar(128),
    active boolean DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS ohm.availed_service (
    _id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id bigint REFERENCES ohm.user (_id) NOT NULL,
    tenant_id bigint NOT NULL,
    service_id bigint NOT NULL,
    active boolean DEFAULT TRUE
);