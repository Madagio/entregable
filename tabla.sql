CREATE TABLE rol_empleado (
    id_rol SERIAL,
    descripcion VARCHAR(50)
);

CREATE TABLE turno (
    id_turno SERIAL,
    hr_inicio TIME,
    hr_fin TIME,
    descripcion VARCHAR(100)
);

CREATE TABLE estd_habitacion (
    id_estado SERIAL,
    nombre_estado VARCHAR(20),
    descripcion TEXT
);

CREATE TABLE huesped (
    id_huesped SERIAL,
    nombres VARCHAR(25),
    apellidos VARCHAR(25),
    dni CHAR(8),
    historial TEXT,
    telefono VARCHAR(15)
);

CREATE TABLE servicio (
    id_servicio SERIAL,
    nombre_servicio VARCHAR(100),
    descripcion TEXT,
    precio_unitario NUMERIC(10,2)
);

CREATE TABLE mtd_pago (
    id_metodo SERIAL,
    nombre_pago VARCHAR(50),
    descripcion TEXT
);

CREATE TABLE empleado (
    id_empleado SERIAL,
    nombre VARCHAR(25),
    apellido VARCHAR(25),
    dni CHAR(8),
    telefono VARCHAR(15),
    correo VARCHAR(50),
    id_rol INT,
    id_turno INT
);

CREATE TABLE habitacion (
    id_habitacion SERIAL,
    nro_habitacion INT,
    piso INT,
    capacidad INT,
    precio_base NUMERIC(8,2),
    id_estado INT
);

CREATE TABLE reserva (
    id_reserva SERIAL,
    fch_reserva DATE,
    estado_reserva VARCHAR(20),
    cantidad_personas INT,
    id_huesped INT,
    id_habitacion INT,
    id_empleado INT
);

CREATE TABLE estadia (
    id_estadia SERIAL,
    fch_ingreso DATE,
    fch_salida DATE,
    hr_ingreso TIME,
    hr_salida TIME,
    id_empleado INT,
    id_reserva INT
);

CREATE TABLE pago (
    id_pago SERIAL,
    fch_pago DATE,
    monto_total NUMERIC(10,2),
    estado_pago VARCHAR(20),
    id_reserva INT,
    id_metodo INT
);

CREATE TABLE detalle_pago (
    id_detalle SERIAL,
    monto_abonado NUMERIC(10,2),
    descripcion TEXT,
    id_pago INT,
    id_servicio INT
);

CREATE TABLE comprobante (
    id_comprobante SERIAL,
    serie VARCHAR(20),
    fch_emision DATE,
    descripcion TEXT,
    id_pago INT
);

CREATE TABLE mantenimiento (
    id_mantenimiento SERIAL,
    fch_inicio DATE,
    fch_fin DATE,
    motivo VARCHAR(100),
    descripcion VARCHAR(200),
    estado_mant VARCHAR(50),
    costo NUMERIC(8,2),
    id_habitacion INT,
    id_empleado INT
);

CREATE TABLE cancelacion_reserva (
    id_cancelacion SERIAL,
    motivo VARCHAR(200),
    fecha DATE,
    penalidad NUMERIC(8,2),
    id_reserva INT
);

CREATE TABLE consumo_srvicio (
    id_consumo_srvc SERIAL,
    fch_consumo DATE,
    cantidad INT,
    sub_total NUMERIC(8,2),
    descripcion TEXT,
    id_estadia INT,
    id_servicio INT,
    id_empleado INT
);


-- =====================================================
-- 2. CONSTRAINTS
-- =====================================================

-- ROL_EMPLEADO
ALTER TABLE rol_empleado
ADD CONSTRAINT pk_rol_empleado PRIMARY KEY (id_rol);

ALTER TABLE rol_empleado
ALTER COLUMN descripcion SET NOT NULL;


-- TURNO
ALTER TABLE turno
ADD CONSTRAINT pk_turno PRIMARY KEY (id_turno);

ALTER TABLE turno
ALTER COLUMN hr_inicio SET NOT NULL;

ALTER TABLE turno
ALTER COLUMN hr_fin SET NOT NULL;

ALTER TABLE turno
ALTER COLUMN descripcion SET NOT NULL;


-- ESTD_HABITACION
ALTER TABLE estd_habitacion
ADD CONSTRAINT pk_estd_habitacion PRIMARY KEY (id_estado);

ALTER TABLE estd_habitacion
ALTER COLUMN nombre_estado SET NOT NULL;

ALTER TABLE estd_habitacion
ADD CONSTRAINT uk_estd_habitacion_nombre_estado UNIQUE (nombre_estado);


-- HUESPED
ALTER TABLE huesped
ADD CONSTRAINT pk_huesped PRIMARY KEY (id_huesped);

ALTER TABLE huesped
ALTER COLUMN nombres SET NOT NULL;

ALTER TABLE huesped
ALTER COLUMN apellidos SET NOT NULL;

ALTER TABLE huesped
ALTER COLUMN dni SET NOT NULL;

ALTER TABLE huesped
ALTER COLUMN historial SET NOT NULL;

ALTER TABLE huesped
ADD CONSTRAINT uk_huesped_dni UNIQUE (dni);


-- SERVICIO
ALTER TABLE servicio
ADD CONSTRAINT pk_servicio PRIMARY KEY (id_servicio);

ALTER TABLE servicio
ALTER COLUMN nombre_servicio SET NOT NULL;

ALTER TABLE servicio
ALTER COLUMN precio_unitario SET NOT NULL;

ALTER TABLE servicio
ADD CONSTRAINT uk_servicio_nombre UNIQUE (nombre_servicio);

ALTER TABLE servicio
ADD CONSTRAINT ck_servicio_precio CHECK (precio_unitario >= 0);


-- MTD_PAGO
ALTER TABLE mtd_pago
ADD CONSTRAINT pk_mtd_pago PRIMARY KEY (id_metodo);

ALTER TABLE mtd_pago
ALTER COLUMN nombre_pago SET NOT NULL;

ALTER TABLE mtd_pago
ADD CONSTRAINT uk_mtd_pago_nombre UNIQUE (nombre_pago);


-- EMPLEADO
ALTER TABLE empleado
ADD CONSTRAINT pk_empleado PRIMARY KEY (id_empleado);

ALTER TABLE empleado
ALTER COLUMN nombre SET NOT NULL;

ALTER TABLE empleado
ALTER COLUMN apellido SET NOT NULL;

ALTER TABLE empleado
ALTER COLUMN dni SET NOT NULL;

ALTER TABLE empleado
ALTER COLUMN telefono SET NOT NULL;

ALTER TABLE empleado
ALTER COLUMN id_rol SET NOT NULL;

ALTER TABLE empleado
ALTER COLUMN id_turno SET NOT NULL;

ALTER TABLE empleado
ADD CONSTRAINT uk_empleado_dni UNIQUE (dni);

ALTER TABLE empleado
ADD CONSTRAINT uk_empleado_correo UNIQUE (correo);

ALTER TABLE empleado
ADD CONSTRAINT fk_empleado_rol FOREIGN KEY (id_rol)
REFERENCES rol_empleado(id_rol);

ALTER TABLE empleado
ADD CONSTRAINT fk_empleado_turno FOREIGN KEY (id_turno)
REFERENCES turno(id_turno);


-- HABITACION
ALTER TABLE habitacion
ADD CONSTRAINT pk_habitacion PRIMARY KEY (id_habitacion);

ALTER TABLE habitacion
ALTER COLUMN nro_habitacion SET NOT NULL;

ALTER TABLE habitacion
ALTER COLUMN piso SET NOT NULL;

ALTER TABLE habitacion
ALTER COLUMN capacidad SET NOT NULL;

ALTER TABLE habitacion
ALTER COLUMN precio_base SET NOT NULL;

ALTER TABLE habitacion
ALTER COLUMN id_estado SET NOT NULL;

ALTER TABLE habitacion
ADD CONSTRAINT uk_habitacion_nro UNIQUE (nro_habitacion);

ALTER TABLE habitacion
ADD CONSTRAINT fk_habitacion_estado FOREIGN KEY (id_estado)
REFERENCES estd_habitacion(id_estado);

ALTER TABLE habitacion
ADD CONSTRAINT ck_habitacion_capacidad CHECK (capacidad > 0);

ALTER TABLE habitacion
ADD CONSTRAINT ck_habitacion_precio CHECK (precio_base >= 0);


-- RESERVA
ALTER TABLE reserva
ADD CONSTRAINT pk_reserva PRIMARY KEY (id_reserva);

ALTER TABLE reserva
ALTER COLUMN fch_reserva SET NOT NULL;

ALTER TABLE reserva
ALTER COLUMN estado_reserva SET NOT NULL;

ALTER TABLE reserva
ALTER COLUMN cantidad_personas SET NOT NULL;

ALTER TABLE reserva
ALTER COLUMN id_huesped SET NOT NULL;

ALTER TABLE reserva
ALTER COLUMN id_habitacion SET NOT NULL;

ALTER TABLE reserva
ALTER COLUMN id_empleado SET NOT NULL;

ALTER TABLE reserva
ADD CONSTRAINT fk_reserva_huesped FOREIGN KEY (id_huesped)
REFERENCES huesped(id_huesped);

ALTER TABLE reserva
ADD CONSTRAINT fk_reserva_habitacion FOREIGN KEY (id_habitacion)
REFERENCES habitacion(id_habitacion);

ALTER TABLE reserva
ADD CONSTRAINT fk_reserva_empleado FOREIGN KEY (id_empleado)
REFERENCES empleado(id_empleado);

ALTER TABLE reserva
ADD CONSTRAINT ck_reserva_cantidad_personas
CHECK (cantidad_personas > 0);


-- ESTADIA
ALTER TABLE estadia
ADD CONSTRAINT pk_estadia PRIMARY KEY (id_estadia);

ALTER TABLE estadia
ALTER COLUMN fch_ingreso SET NOT NULL;

ALTER TABLE estadia
ALTER COLUMN fch_salida SET NOT NULL;

ALTER TABLE estadia
ALTER COLUMN id_empleado SET NOT NULL;

ALTER TABLE estadia
ALTER COLUMN id_reserva SET NOT NULL;

ALTER TABLE estadia
ADD CONSTRAINT fk_estadia_empleado FOREIGN KEY (id_empleado)
REFERENCES empleado(id_empleado);

ALTER TABLE estadia
ADD CONSTRAINT fk_estadia_reserva FOREIGN KEY (id_reserva)
REFERENCES reserva(id_reserva);

ALTER TABLE estadia
ADD CONSTRAINT ck_estadia_fechas
CHECK (fch_salida >= fch_ingreso);


-- PAGO
ALTER TABLE pago
ADD CONSTRAINT pk_pago PRIMARY KEY (id_pago);

ALTER TABLE pago
ALTER COLUMN fch_pago SET NOT NULL;

ALTER TABLE pago
ALTER COLUMN monto_total SET NOT NULL;

ALTER TABLE pago
ALTER COLUMN id_reserva SET NOT NULL;

ALTER TABLE pago
ALTER COLUMN id_metodo SET NOT NULL;

ALTER TABLE pago
ADD CONSTRAINT ck_pago_monto CHECK (monto_total >= 0);

ALTER TABLE pago
ADD CONSTRAINT fk_pago_reserva FOREIGN KEY (id_reserva)
REFERENCES reserva(id_reserva);

ALTER TABLE pago
ADD CONSTRAINT fk_pago_mtd_pago FOREIGN KEY (id_metodo)
REFERENCES mtd_pago(id_metodo);


-- DETALLE_PAGO
ALTER TABLE detalle_pago
ADD CONSTRAINT pk_detalle_pago PRIMARY KEY (id_detalle);

ALTER TABLE detalle_pago
ALTER COLUMN monto_abonado SET NOT NULL;

ALTER TABLE detalle_pago
ALTER COLUMN id_pago SET NOT NULL;

ALTER TABLE detalle_pago
ALTER COLUMN id_servicio SET NOT NULL;

ALTER TABLE detalle_pago
ADD CONSTRAINT fk_detalle_pago_pago FOREIGN KEY (id_pago)
REFERENCES pago(id_pago);

ALTER TABLE detalle_pago
ADD CONSTRAINT fk_detalle_pago_servicio FOREIGN KEY (id_servicio)
REFERENCES servicio(id_servicio);

ALTER TABLE detalle_pago
ADD CONSTRAINT ck_detalle_pago_monto CHECK (monto_abonado >= 0);


-- COMPROBANTE
ALTER TABLE comprobante
ADD CONSTRAINT pk_comprobante PRIMARY KEY (id_comprobante);

ALTER TABLE comprobante
ALTER COLUMN serie SET NOT NULL;

ALTER TABLE comprobante
ALTER COLUMN fch_emision SET NOT NULL;

ALTER TABLE comprobante
ALTER COLUMN id_pago SET NOT NULL;

ALTER TABLE comprobante
ADD CONSTRAINT uk_comprobante_serie UNIQUE (serie);

ALTER TABLE comprobante
ADD CONSTRAINT fk_comprobante_pago FOREIGN KEY (id_pago)
REFERENCES pago(id_pago);


-- MANTENIMIENTO
ALTER TABLE mantenimiento
ADD CONSTRAINT pk_mantenimiento PRIMARY KEY (id_mantenimiento);

ALTER TABLE mantenimiento
ALTER COLUMN fch_inicio SET NOT NULL;

ALTER TABLE mantenimiento
ALTER COLUMN fch_fin SET NOT NULL;

ALTER TABLE mantenimiento
ALTER COLUMN motivo SET NOT NULL;

ALTER TABLE mantenimiento
ALTER COLUMN estado_mant SET NOT NULL;

ALTER TABLE mantenimiento
ALTER COLUMN id_habitacion SET NOT NULL;

ALTER TABLE mantenimiento
ALTER COLUMN id_empleado SET NOT NULL;

ALTER TABLE mantenimiento
ADD CONSTRAINT fk_mantenimiento_habitacion FOREIGN KEY (id_habitacion)
REFERENCES habitacion(id_habitacion);

ALTER TABLE mantenimiento
ADD CONSTRAINT fk_mantenimiento_empleado FOREIGN KEY (id_empleado)
REFERENCES empleado(id_empleado);

ALTER TABLE mantenimiento
ADD CONSTRAINT ck_mantenimiento_fechas
CHECK (fch_fin >= fch_inicio);

ALTER TABLE mantenimiento
ADD CONSTRAINT ck_mantenimiento_costo
CHECK (costo >= 0);


-- CANCELACION_RESERVA
ALTER TABLE cancelacion_reserva
ADD CONSTRAINT pk_cancelacion_reserva PRIMARY KEY (id_cancelacion);

ALTER TABLE cancelacion_reserva
ALTER COLUMN motivo SET NOT NULL;

ALTER TABLE cancelacion_reserva
ALTER COLUMN fecha SET NOT NULL;

ALTER TABLE cancelacion_reserva
ALTER COLUMN id_reserva SET NOT NULL;

ALTER TABLE cancelacion_reserva
ADD CONSTRAINT fk_cancelacion_reserva FOREIGN KEY (id_reserva)
REFERENCES reserva(id_reserva);

ALTER TABLE cancelacion_reserva
ADD CONSTRAINT ck_cancelacion_penalidad
CHECK (penalidad >= 0);


-- CONSUMO_SRVICIO
ALTER TABLE consumo_srvicio
ADD CONSTRAINT pk_consumo_srvicio PRIMARY KEY (id_consumo_srvc);

ALTER TABLE consumo_srvicio
ALTER COLUMN fch_consumo SET NOT NULL;

ALTER TABLE consumo_srvicio
ALTER COLUMN cantidad SET NOT NULL;

ALTER TABLE consumo_srvicio
ALTER COLUMN sub_total SET NOT NULL;

ALTER TABLE consumo_srvicio
ALTER COLUMN id_estadia SET NOT NULL;

ALTER TABLE consumo_srvicio
ALTER COLUMN id_servicio SET NOT NULL;

ALTER TABLE consumo_srvicio
ALTER COLUMN id_empleado SET NOT NULL;

ALTER TABLE consumo_srvicio
ADD CONSTRAINT fk_consumo_srvicio_estadia FOREIGN KEY (id_estadia)
REFERENCES estadia(id_estadia);

ALTER TABLE consumo_srvicio
ADD CONSTRAINT fk_consumo_srvicio_servicio FOREIGN KEY (id_servicio)
REFERENCES servicio(id_servicio);

ALTER TABLE consumo_srvicio
ADD CONSTRAINT fk_consumo_srvicio_empleado FOREIGN KEY (id_empleado)
REFERENCES empleado(id_empleado);

ALTER TABLE consumo_srvicio
ADD CONSTRAINT ck_consumo_srvicio_cantidad
CHECK (cantidad > 0);

ALTER TABLE consumo_srvicio
ADD CONSTRAINT ck_consumo_srvicio_sub_total
CHECK (sub_total >= 0);


-- =====================================================
-- 3. POBLADO DE DATOS
-- =====================================================

-- TABLAS BASE

INSERT INTO rol_empleado (id_rol, descripcion) VALUES
(1, 'Recepcionista'),
(2, 'Gerente'),
(3, 'Personal de limpieza'),
(4, 'Mantenimiento'),
(5, 'Conserje');

INSERT INTO turno (id_turno, hr_inicio, hr_fin, descripcion) VALUES
(1, '06:00', '14:00', 'Turno mañana'),
(2, '14:00', '22:00', 'Turno tarde'),
(3, '22:00', '06:00', 'Turno noche'),
(4, '08:00', '17:00', 'Turno administrativo'),
(5, '09:00', '18:00', 'Turno mixto');

INSERT INTO estd_habitacion (id_estado, nombre_estado, descripcion) VALUES
(1, 'Disponible', 'La habitacion esta libre'),
(2, 'Ocupada', 'La habitacion esta ocupada'),
(3, 'Mantenimiento', 'La habitacion no esta disponible'),
(4, 'Limpieza', 'La habitacion esta pendiente de limpieza'),
(5, 'Reservada', 'La habitacion fue reservada');

INSERT INTO huesped (id_huesped, nombres, apellidos, dni, historial, telefono) VALUES
(1, 'Carlos', 'Mendoza', '70111222', 'Sin observaciones', '958111222'),
(2, 'Lucia', 'Torres', '70222333', 'Cliente frecuente', '958222333'),
(3, 'Mario', 'Ramos', '70333444', 'Solicita habitacion tranquila', '958333444'),
(4, 'Ana', 'Flores', '70444555', 'Sin observaciones', '958444555'),
(5, 'Jorge', 'Quispe', '70555666', 'Pagos puntuales', '958555666');

INSERT INTO servicio (id_servicio, nombre_servicio, descripcion, precio_unitario) VALUES
(1, 'Hospedaje Habitacion Simple', 'Servicio de alojamiento simple por noche', 15.00),
(2, 'Hospedaje Habitacion Doble', 'Servicio de alojamiento para dos personas por noche', 30.00),
(3, 'Servicio de Minibar', 'Consumo de bebidas y snacks en la habitacion', 8.00),
(4, 'Acceso a Spa y Masajes', 'Uso de instalaciones de relajacion por hora', 20.00),
(5, 'Almuerzo Ejecutivo Hotelero', 'Menu completo servido en el restaurante principal', 15.00);

INSERT INTO mtd_pago (id_metodo, nombre_pago, descripcion) VALUES
(1, 'Pago por Efectivo', 'Pago fisico'),
(2, 'Pago por Tarjeta', 'Pago electronico'),
(3, 'Transferencia Bancaria', 'Transferencia directa'),
(4, 'Billetera Digital', 'Pago por aplicaciones'),
(5, 'Pago por Criptomonedas', 'Uso de criptomonedas como metodo de pago');


-- TABLAS DEPENDIENTES

INSERT INTO empleado (id_empleado, nombre, apellido, dni, telefono, correo, id_rol, id_turno) VALUES
(1, 'Pedro', 'Salas', '40111222', '999111222', 'psalas@htel.com', 1, 1),
(2, 'Edward', 'Poma', '40222333', '999222333', 'edwardp@htel.com', 2, 2),
(3, 'Ronal', 'Cueto', '40333444', '999333444', 'rcuetillo@htel.com', 3, 3),
(4, 'Alhy', 'Chura', '40444555', '999444555', 'alhyplayer15@htel.com', 4, 4),
(5, 'Diego', 'Castro', '40555666', '999555666', 'dcastro@htel.com', 5, 5);

INSERT INTO habitacion (id_habitacion, nro_habitacion, piso, capacidad, precio_base, id_estado) VALUES
(1, 101, 1, 2, 150.00, 1),
(2, 102, 1, 2, 150.00, 1),
(3, 201, 2, 3, 220.00, 2),
(4, 202, 2, 4, 300.00, 5),
(5, 301, 3, 2, 180.00, 3);


-- RESERVA

INSERT INTO reserva 
(id_reserva, fch_reserva, estado_reserva, cantidad_personas, id_huesped, id_habitacion, id_empleado)
VALUES
(5001, '2026-05-08', 'Confirmada', 2, 1, 1, 1),
(5002, '2026-05-09', 'Confirmada', 2, 2, 2, 2),
(5003, '2026-05-10', 'Confirmada', 3, 3, 3, 1),
(5004, '2026-05-11', 'Pendiente', 4, 4, 4, 2),
(5005, '2026-05-12', 'Confirmada', 2, 5, 5, 1);


-- TABLAS QUE DEPENDEN DE RESERVA

INSERT INTO estadia
(id_estadia, fch_ingreso, fch_salida, hr_ingreso, hr_salida, id_empleado, id_reserva)
VALUES
(1, '2026-05-10', '2026-05-12', '14:00', '11:00', 1, 5001),
(2, '2026-05-11', '2026-05-13', '15:30', '10:30', 2, 5002),
(3, '2026-05-12', '2026-05-15', '13:45', '11:15', 1, 5003),
(4, '2026-05-13', '2026-05-14', '16:00', '10:00', 3, 5004),
(5, '2026-05-14', '2026-05-17', '14:20', '11:00', 2, 5005);

INSERT INTO pago (id_pago, fch_pago, monto_total, estado_pago, id_reserva, id_metodo)
VALUES
(101, '2026-05-15', 45.00, 'Pagado', 5001, 1),
(102, '2026-05-16', 95.00, 'Pagado', 5002, 2),
(103, '2026-05-18', 60.00, 'Pagado', 5003, 2),
(104, '2026-05-20', 50.00, 'Pendiente', 5004, 3),
(105, '2026-05-22', 125.00, 'Pagado', 5005, 4);

INSERT INTO mantenimiento 
(id_mantenimiento, fch_inicio, fch_fin, motivo, descripcion, estado_mant, costo, id_habitacion, id_empleado)
VALUES
(1, '2025-01-05', '2025-01-06', 'Fuga de agua', 'Reparacion de tuberia en el baño', 'Finalizado', 120.00, 5, 4),
(2, '2025-02-10', '2025-02-11', 'Aire acondicionado', 'Cambio de filtro del aire', 'Finalizado', 90.00, 3, 4),
(3, '2025-03-01', '2025-03-02', 'Pintura', 'Repintado de paredes', 'Finalizado', 200.00, 5, 4),
(4, '2025-03-15', '2025-03-15', 'Cerradura', 'Cambio de chapa electronica', 'Finalizado', 75.00, 1, 4),
(5, '2025-04-01', '2025-04-03', 'Electrico', 'Revision del cableado', 'Finalizado', 160.00, 2, 4);

INSERT INTO cancelacion_reserva 
(id_cancelacion, motivo, fecha, penalidad, id_reserva)
VALUES
(1, 'Cambio de planes del huesped', '2026-05-13', 50.00, 5001),
(2, 'Vuelo cancelado', '2026-05-14', 30.00, 5002),
(3, 'Emergencia familiar', '2026-05-14', 0.00, 5003),
(4, 'Error en la fecha de reserva', '2026-05-15', 25.00, 5004),
(5, 'Insatisfaccion con la habitacion', '2026-05-16', 40.00, 5005);


-- TABLAS FINALES

INSERT INTO detalle_pago 
(id_detalle, monto_abonado, descripcion, id_pago, id_servicio)
VALUES
(201, 45.00, 'Pago por 1 noche en habitacion simple', 101, 1),
(202, 80.00, 'Pago por 1 noche en habitacion doble', 102, 2),
(203, 15.50, 'Pago por consumo de chocolates del minibar', 102, 3),
(204, 80.00, 'Abono parcial de alojamiento doble', 103, 2),
(205, 50.00, 'Reserva de sesion de masajes terapeuticos', 104, 4),
(206, 45.00, 'Alojamiento base del huesped de la reserva 5005', 105, 1),
(207, 80.00, 'Consumo asociado de suite doble en el mismo periodo', 105, 2);

INSERT INTO comprobante 
(id_comprobante, serie, fch_emision, descripcion, id_pago)
VALUES
(301, 'B001-000041', '2026-05-15', 'Boleta de venta electronica por hospedaje rapido', 101),
(302, 'F001-000012', '2026-05-16', 'Factura corporativa con desglose de consumos', 102),
(303, 'B001-000042', '2026-05-18', 'Boleta emitida al cerrar estadia', 103),
(304, 'B001-000043', '2026-05-20', 'Boleta de adelanto por transferencia', 104),
(305, 'F001-000013', '2026-05-22', 'Factura por adelantos integrales de alojamiento', 105);

INSERT INTO consumo_srvicio 
(id_consumo_srvc, fch_consumo, cantidad, sub_total, descripcion, id_estadia, id_servicio, id_empleado)
VALUES
(1, '2026-05-10', 2, 30.00, 'Consumo de hospedaje simple', 1, 1, 1),
(2, '2026-05-11', 1, 30.00, 'Consumo de hospedaje doble', 2, 2, 2),
(3, '2026-05-12', 3, 24.00, 'Consumo de minibar', 3, 3, 1),
(4, '2026-05-13', 1, 20.00, 'Acceso al spa', 4, 4, 3),
(5, '2026-05-14', 2, 30.00, 'Almuerzo ejecutivo hotelero', 5, 5, 2);


SELECT setval('rol_empleado_id_rol_seq', (SELECT MAX(id_rol) FROM rol_empleado));
SELECT setval('turno_id_turno_seq', (SELECT MAX(id_turno) FROM turno));
SELECT setval('estd_habitacion_id_estado_seq', (SELECT MAX(id_estado) FROM estd_habitacion));
SELECT setval('huesped_id_huesped_seq', (SELECT MAX(id_huesped) FROM huesped));
SELECT setval('servicio_id_servicio_seq', (SELECT MAX(id_servicio) FROM servicio));
SELECT setval('mtd_pago_id_metodo_seq', (SELECT MAX(id_metodo) FROM mtd_pago));
SELECT setval('empleado_id_empleado_seq', (SELECT MAX(id_empleado) FROM empleado));
SELECT setval('habitacion_id_habitacion_seq', (SELECT MAX(id_habitacion) FROM habitacion));
SELECT setval('reserva_id_reserva_seq', (SELECT MAX(id_reserva) FROM reserva));
SELECT setval('estadia_id_estadia_seq', (SELECT MAX(id_estadia) FROM estadia));
SELECT setval('pago_id_pago_seq', (SELECT MAX(id_pago) FROM pago));
SELECT setval('detalle_pago_id_detalle_seq', (SELECT MAX(id_detalle) FROM detalle_pago));
SELECT setval('comprobante_id_comprobante_seq', (SELECT MAX(id_comprobante) FROM comprobante));
SELECT setval('mantenimiento_id_mantenimiento_seq', (SELECT MAX(id_mantenimiento) FROM mantenimiento));
SELECT setval('cancelacion_reserva_id_cancelacion_seq', (SELECT MAX(id_cancelacion) FROM cancelacion_reserva));
SELECT setval('consumo_srvicio_id_consumo_srvc_seq', (SELECT MAX(id_consumo_srvc) FROM consumo_srvicio));
