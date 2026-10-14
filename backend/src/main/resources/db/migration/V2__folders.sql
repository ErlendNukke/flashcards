CREATE TABLE folder (
    id         UUID PRIMARY KEY,
    device_id  VARCHAR(64)  NOT NULL,
    name       VARCHAR(120) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX uq_folder_device_name ON folder (device_id, name);
CREATE INDEX idx_folder_device_id ON folder (device_id);

ALTER TABLE flash_card ADD COLUMN folder_id UUID NULL;
ALTER TABLE flash_card ADD CONSTRAINT fk_flash_card_folder
    FOREIGN KEY (folder_id) REFERENCES folder (id);
CREATE INDEX idx_flash_card_folder_id ON flash_card (folder_id);
