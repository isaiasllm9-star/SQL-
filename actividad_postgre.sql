-- ========================================================
-- ESTUDIANTE: Isaias Marchart Sosa
-- MATERIA: Base de Datos 2
-- PROFESOR: Jaimer Vilorio Green
-- TEMA: Actividad - Funciones y Procedimientos Almacenados
-- ========================================================

-- 📋 SETUP: CREACIÓN DE TABLA Y DATOS INICIALES
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

-- 🧩 PARTE 1: CREACIÓN DE FUNCIÓN

-- Función que captura el balance de un usuario por su ID
CREATE OR REPLACE FUNCTION capturar_balance(p_id_user INT)
RETURNS NUMERIC AS $$
DECLARE
    current_balance NUMERIC;
BEGIN
    -- Seleccionamos el balance en la variable
    SELECT balance INTO current_balance
    FROM customers
    WHERE id_user = p_id_user;

    -- Validamos si el usuario existe (si es NULL lanza error)
    IF current_balance IS NULL THEN
        RAISE EXCEPTION 'Este usuario no existe';
    END IF;

    RETURN current_balance;
END;
$$ LANGUAGE plpgsql;


-- ==========================================
-- 🔄 PARTE 2: CREACIÓN DE PROCEDIMIENTO
-- ==========================================

-- Procedimiento para realizar transacciones entre usuarios
CREATE OR REPLACE PROCEDURE realizar_transferencia(
    p_id_origen INT,
    p_id_destino INT,
    p_monto NUMERIC
)
AS $$
DECLARE
    origin_balance NUMERIC;
BEGIN
    -- Obtenemos el balance del usuario origen
    SELECT balance INTO origin_balance
    FROM customers
    WHERE id_user = p_id_origen;

    -- Validamos que el usuario origen tenga fondos suficientes
    IF origin_balance < p_monto THEN
        RAISE EXCEPTION 'Fondos insuficientes para la transferencia';
    END IF;

    -- Validamos que el usuario origen no sea NULL (que exista)
    IF origin_balance IS NULL THEN
        RAISE EXCEPTION 'El usuario de origen no existe';
    END IF;

    -- Validamos que el usuario destino exista
    IF NOT EXISTS (SELECT 1 FROM customers WHERE id_user = p_id_destino) THEN
        RAISE EXCEPTION 'El usuario de destino no existe';
    END IF;

    -- Descontar el monto del usuario origen
    UPDATE customers 
    SET balance = balance - p_monto 
    WHERE id_user = p_id_origen;

    -- Acreditar el monto al usuario destino
    UPDATE customers 
    SET balance = balance + p_monto 
    WHERE id_user = p_id_destino;

    -- Mensaje de éxito
    RAISE NOTICE 'Transferencia de % realizada correctamente.', p_monto;

END;
$$ LANGUAGE plpgsql;


-- ==========================================
-- ⚙️ PARTE 3: PRUEBAS DE EJECUCIÓN
-- ==========================================

-- 1. Probar la función (Consultar balance del usuario 1)
-- SELECT capturar_balance(1);

-- 2. Probar el procedimiento con éxito (Juan pasa 1000 a Pablo)
-- CALL realizar_transferencia(1, 2, 1000);

-- 3. Probar manejo de error (Intentar transferir más dinero del disponible)
-- CALL realizar_transferencia(2, 3, 5000);
