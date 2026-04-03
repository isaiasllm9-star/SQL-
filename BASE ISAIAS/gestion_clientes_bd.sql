-- ======================================================
-- ACTIVIDAD: GESTIÓN DE CLIENTES Y TRANSACCIONES
-- ======================================================

-- 1. SETUP: TABLA Y DATOS INICIALES
DROP TABLE IF EXISTS customers CASCADE;

CREATE TABLE customers (
    id_user SERIAL PRIMARY KEY, 
    fname VARCHAR NOT NULL, 
    lname VARCHAR NOT NULL, 
    balance NUMERIC(10, 2) NOT NULL
);

INSERT INTO customers (fname, lname, balance)
VALUES
    ('Juan', 'Santana', 10000),
    ('Pablo', 'Sánchez', 500),
    ('María', 'Sosa', 500);

-- ======================================================
-- PARTE 1: CREACIÓN DE FUNCIÓN (capturar_balance)
-- ======================================================

CREATE OR REPLACE FUNCTION capturar_balance(p_id_user INT)
RETURNS NUMERIC AS $$
DECLARE
    current_balance NUMERIC;
BEGIN
    SELECT balance INTO current_balance
    FROM customers
    WHERE id_user = p_id_user;

    -- Validación según instrucción: Si el usuario no existe (es NULL)
    IF current_balance IS NULL THEN
        RAISE EXCEPTION 'Este usuario no existe';
    END IF;

    RETURN current_balance;
END;
$$ LANGUAGE plpgsql;

-- ======================================================
-- PARTE 2: CREACIÓN DE PROCEDIMIENTO (realizar_transferencia)
-- ======================================================

CREATE OR REPLACE PROCEDURE realizar_transferencia(
    p_id_origen INT,
    p_id_destino INT,
    p_monto NUMERIC
)
AS $$
DECLARE
    origin_balance NUMERIC;
BEGIN
    -- 1. Obtener balance del usuario origen según instrucción
    SELECT balance INTO origin_balance
    FROM customers
    WHERE id_user = p_id_origen;

    -- Validar que el usuario de origen existe
    IF origin_balance IS NULL THEN
        RAISE EXCEPTION 'El usuario de origen no existe.';
    END IF;

    -- 2. Validar que el usuario de destino existe
    IF NOT EXISTS (SELECT 1 FROM customers WHERE id_user = p_id_destino) THEN
        RAISE EXCEPTION 'El usuario de destino no existe.';
    END IF;

    -- 3. Validar que el usuario de origen tenga fondos suficientes
    IF origin_balance < p_monto THEN
        RAISE EXCEPTION 'Fondos insuficientes para realizar la transferencia.';
    END IF;

    -- 4. Realizar la transferencia 
    -- Descontar del origen
    UPDATE customers 
    SET balance = balance - p_monto 
    WHERE id_user = p_id_origen;

    -- Acreditar al destino
    UPDATE customers 
    SET balance = balance + p_monto 
    WHERE id_user = p_id_destino;

    RAISE NOTICE 'Transferencia exitosa de % desde ID % a ID %', p_monto, p_id_origen, p_id_destino;
END;
$$ LANGUAGE plpgsql;

-- ======================================================
-- PARTE 3: PRUEBAS (EJEMPLOS DE EJECUCIÓN)
-- ======================================================

-- PRUEBA A: Consulta de balance mediante la función
-- SELECT capturar_balance(1); 

-- PRUEBA B: Ejecución exitosa de una transferencia
-- CALL realizar_transferencia(1, 2, 100);

-- PRUEBA C: Manejo de errores (Fondos insuficientes)
-- CALL realizar_transferencia(2, 3, 5000); 
