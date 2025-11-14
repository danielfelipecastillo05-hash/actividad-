CREATE DATABASE IF NOT EXISTS tienda_select CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE tienda_select;

DROP TABLE IF EXISTS pedido_detalle;
DROP TABLE IF EXISTS pedidos;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS categorias;
DROP TABLE IF EXISTS clientes;

CREATE TABLE categorias (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE productos (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(150) NOT NULL,
  precio DECIMAL(10,2) NOT NULL,
  categoria_id INT,
  stock INT NOT NULL DEFAULT 0,
  activo BOOLEAN NOT NULL DEFAULT TRUE,
  sku VARCHAR(30),
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_prod_categoria FOREIGN KEY (categoria_id) REFERENCES categorias(id)
) ENGINE=InnoDB;

CREATE TABLE clientes (
  id INT PRIMARY KEY AUTO_INCREMENT,
  email VARCHAR(150) NOT NULL UNIQUE,
  nombre VARCHAR(120) NOT NULL,
  ciudad VARCHAR(100),
  fecha_registro DATE NOT NULL DEFAULT (CURRENT_DATE)
) ENGINE=InnoDB;

CREATE TABLE pedidos (
  id INT PRIMARY KEY AUTO_INCREMENT,
  cliente_id INT NOT NULL,
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_ped_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE pedido_detalle (
  pedido_id INT NOT NULL,
  linea INT NOT NULL,
  producto_id INT NOT NULL,
  cantidad INT NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (pedido_id, linea),
  CONSTRAINT fk_det_pedido   FOREIGN KEY (pedido_id)  REFERENCES pedidos(id)   ON DELETE CASCADE,
  CONSTRAINT fk_det_producto FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

INSERT INTO categorias (nombre) VALUES ('Electrónica'), ('Hogar'), ('Jardín');

INSERT INTO productos (nombre, precio, categoria_id, stock, activo, sku) VALUES
  ('Auriculares', 29.90, 1, 50, TRUE,  'SKU-AUR-001'),
  ('Televisor',  499.00, 1, 10, TRUE,  'SKU-TEL-001'),
  ('Silla',       85.50, 2, 30, TRUE,  'SKU-SIL-001'),
  ('Mesa',       129.00, 2, 15, FALSE, 'SKU-MES-001'),
  ('Manguera',    24.99, 3, 80, TRUE,  NULL),
  ('Tijeras',     12.49, 3, 40, TRUE,  'SKU-TIJ-001');

INSERT INTO clientes (email, nombre, ciudad, fecha_registro) VALUES
  ('ana@example.com',  'Ana',  'Madrid',     '2025-01-10'),
  ('luis@example.com', 'Luis', 'Barcelona',  '2025-03-22'),
  ('maria@example.com','María','Valencia',   '2025-05-05');

INSERT INTO pedidos (cliente_id, creado_en) VALUES
  (1, '2025-05-20 10:00:00'),
  (1, '2025-06-01 12:00:00'),
  (2, '2025-06-03 09:30:00');

INSERT INTO pedido_detalle (pedido_id, linea, producto_id, cantidad, precio_unitario) VALUES
  (1, 1, 1, 1, 29.90),
  (1, 2, 3, 2, 85.50),
  (2, 1, 2, 1, 499.00),
  (2, 2, 5, 3, 24.99),
  (3, 1, 4, 1, 129.00);
  
  -- Nivel 1 — Alias, filtros y ordenación
  
SELECT nombre AS producto, precio AS precio_eur
  FROM productos; -- Se cambiaron corretamente los nombres
  
SELECT * FROM productos 
	WHERE activo = TRUE AND precio >= 50.00;
  
SELECT * FROM productos
	WHERE precio BETWEEN 20.00 and 100.00;
    
SELECT * FROM productos
	WHERE categoria_id IN (1, 2, 3);
    
SELECT * FROM productos where nombre LIKE '%te%';

SELECT * FROM productos
WHERE sku IS NULL;

SELECT nombre, precio 
FROM productos 
ORDER BY precio DESC, nombre ASC;

SELECT *
FROM productos
ORDER BY precio DESC -- los mas caros
LIMIT 3; 

SELECT *
FROM productos
ORDER BY precio ASC -- los mas baratos 
LIMIT 3;

-- Nivel 2 — Agregaciones básicas

SELECT count(*) AS total_productos FROM productos; -- para saber cuantos productos hay en total 

select * from productos;

-- Calcula el precio_promedio, precio_max y precio_min de todos los productos.
-- Calcula el stock_total sumando stock de todos los productos activos.
SELECT AVG(precio) AS precio_promedio,
       SUM(stock) AS stock_total,
       MAX(precio) AS precio_max,  
       MIN(precio) AS precio_min    
FROM productos;

-- Nivel 3 — GROUP BY y HAVING

-- Por categoria_id, muestra: total_productos y precio_promedio, ordenando por total_productos descendente.

SELECT categoria_id,
       COUNT(*) AS total,
       AVG(precio) AS precio_promedio
FROM productos
GROUP BY categoria_id
ORDER BY total DESC;

-- muestra solo 2 categorias 

SELECT categoria_id, COUNT(*) AS total
FROM productos
GROUP BY categoria_id
HAVING COUNT(*) >= 2;

-- stock 
SELECT activo, SUM(stock) AS stock_total
FROM productos
GROUP BY activo;

-- 

SELECT 
    pedido_id,
    COUNT(*) AS lineas,
    SUM(cantidad) AS unidades,
    SUM(cantidad * precio_unitario) AS importe_total
FROM pedido_detalle
GROUP BY pedido_id
ORDER BY importe_total DESC;

-- Filtra los pedidos del punto anterior para dejar solo aquellos con importe_total >= 200 (usa HAVING).

SELECT 
    pedido_id,
    COUNT(*) AS lineas,
    SUM(cantidad) AS unidades,
    SUM(cantidad * precio_unitario) AS importe_total
FROM pedido_detalle
GROUP BY pedido_id
HAVING importe_total >= 200
ORDER BY importe_total DESC;

SELECT id, nombre
FROM clientes
ORDER BY fecha_registro DESC
LIMIT 2;

SELECT *
FROM productos
ORDER BY id ASC
LIMIT 2 OFFSET 2;







    
  
  