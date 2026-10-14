CREATE TABLE app_user (
    id            UUID PRIMARY KEY,
    username      VARCHAR(32)  NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at    TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX uq_app_user_username ON app_user (username);

ALTER TABLE folder ADD COLUMN user_id UUID NULL;
ALTER TABLE folder ADD CONSTRAINT fk_folder_user FOREIGN KEY (user_id) REFERENCES app_user (id);
ALTER TABLE folder ALTER COLUMN device_id DROP NOT NULL;

ALTER TABLE flash_card ADD COLUMN user_id UUID NULL;
ALTER TABLE flash_card ADD CONSTRAINT fk_flash_card_user FOREIGN KEY (user_id) REFERENCES app_user (id);
ALTER TABLE flash_card ALTER COLUMN device_id DROP NOT NULL;

CREATE INDEX idx_folder_user_id ON folder (user_id);
CREATE INDEX idx_flash_card_user_id ON flash_card (user_id);
