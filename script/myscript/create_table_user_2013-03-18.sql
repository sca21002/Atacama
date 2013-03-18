DROP TABLE  IF EXISTS users;
CREATE TABLE users (
    id            INTEGER unsigned NOT NULL auto_increment,
    username      VARCHAR(255) UNIQUE,
    password      VARCHAR(255),
    password_expires TIMESTAMP,
    email_address VARCHAR(255) UNIQUE,
    first_name    VARCHAR(255),
    last_name     VARCHAR(255),
    active        INTEGER,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;