CREATE TABLE flash_card (
    id         UUID PRIMARY KEY,
    device_id  VARCHAR(64)  NOT NULL,
    question   TEXT         NOT NULL,
    answer     TEXT         NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_flash_card_device_id ON flash_card (device_id);
