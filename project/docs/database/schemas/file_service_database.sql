-- ОПТИМИЗИРОВАННАЯ СХЕМА FILE SERVICE
-- Убраны избыточные поля из справочных таблиц
-- Упрощена структура без потери функциональности

-- Упрощенные справочные таблицы (убраны избыточные поля)
CREATE TABLE file_action_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL,
    description TEXT
);

CREATE TABLE file_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL,
    description TEXT,
    mime_type_pattern VARCHAR(100),
    max_size_bytes BIGINT
);

CREATE TABLE file_statuses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL,
    description TEXT,
    color VARCHAR(7) -- HEX цвет для UI
);

CREATE TABLE file_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL,
    description TEXT
);

CREATE TABLE access_levels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL,
    description TEXT,
    can_read BOOLEAN DEFAULT FALSE,
    can_write BOOLEAN DEFAULT FALSE,
    can_delete BOOLEAN DEFAULT FALSE,
    can_share BOOLEAN DEFAULT FALSE
);

CREATE TABLE file_operations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL,
    description TEXT,
    requires_permission VARCHAR(50)
);

-- Таблица корзин MinIO 
CREATE TABLE buckets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bucket_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    max_size_bytes BIGINT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Таблица файлов 
CREATE TABLE files (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT NOT NULL,
    content_type VARCHAR(100) NOT NULL,
    file_type_id UUID REFERENCES file_types(id),
    file_category_id UUID REFERENCES file_categories(id),
    file_status_id UUID REFERENCES file_statuses(id),
    bucket_id UUID NOT NULL REFERENCES buckets(id),
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    uploaded_by UUID NOT NULL -- Ссылка на пользователя из Auth Service
);

-- Таблица прав доступа к файлам 
CREATE TABLE file_access_rights (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    file_id UUID NOT NULL REFERENCES files(id) ON DELETE CASCADE,
    user_id UUID NOT NULL, -- Ссылка на пользователя из Auth Service
    access_level_id UUID REFERENCES access_levels(id),
    can_read BOOLEAN DEFAULT FALSE,
    can_write BOOLEAN DEFAULT FALSE,
    can_delete BOOLEAN DEFAULT FALSE,
    granted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    granted_by UUID, -- Ссылка на пользователя из Auth Service
    expires_at TIMESTAMP WITH TIME ZONE
);

-- Таблица истории файлов 
CREATE TABLE file_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    file_id UUID NOT NULL REFERENCES files(id) ON DELETE CASCADE,
    user_id UUID NOT NULL, -- Ссылка на пользователя из Auth Service
    action_type_id UUID NOT NULL REFERENCES file_action_types(id),
    operation_id UUID REFERENCES file_operations(id),
    action_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ip_address INET,
    user_agent TEXT,
    details JSONB -- Дополнительные детали операции
);
