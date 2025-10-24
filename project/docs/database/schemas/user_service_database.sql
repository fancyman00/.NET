-- ОПТИМИЗИРОВАННАЯ СХЕМА USER SERVICE
-- Убраны таблицы аутентификации (Identity Server берет на себя)
-- Упрощены справочные таблицы
-- Исправлены связи и типы данных

-- Таблица пользователей (упрощенная для Identity Server)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100), -- Отчество
    date_of_birth DATE,
    is_active BOOLEAN DEFAULT TRUE,
    email_confirmed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP WITH TIME ZONE
);

-- Таблица контактов пользователей
CREATE TABLE user_contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    contact_type VARCHAR(20) NOT NULL CHECK (contact_type IN ('phone', 'email', 'telegram', 'skype')),
    contact_value VARCHAR(255) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Упрощенная таблица ролей (без избыточных полей)
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id)
);

-- Упрощенная таблица разрешений
CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Связующая таблица пользователей и ролей
CREATE TABLE user_roles (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    assigned_by UUID REFERENCES users(id),
    PRIMARY KEY (user_id, role_id)
);

-- Связующая таблица ролей и разрешений
CREATE TABLE role_permissions (
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    granted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    granted_by UUID REFERENCES users(id),
    PRIMARY KEY (role_id, permission_id)
);

-- Убраны таблицы:
-- - login_history (логи в системе логирования)
-- - login_failure_reasons (логи в системе логирования)  
-- - authentication_types (Identity Server управляет)
-- - password_reset_tokens (Identity Server управляет)
-- - refresh_tokens (Identity Server управляет)
-- - token_types (Identity Server управляет)
-- - role_types (избыточная справочная таблица)
-- - permission_categories (избыточная справочная таблица)
