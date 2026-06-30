-- reserva, estadia, pago, detalle_pago, huesped, habitacion, empleado y servicio

CREATE TABLE reserva_documental (
    id_documento SERIAL PRIMARY KEY,
    datos JSONB NOT NULL
);


INSERT INTO reserva_documental (datos)
VALUES (
'{
  "id_reserva": 5001,
  "fch_reserva": "2026-05-08",
  "estado_reserva": "Confirmada",
  "cantidad_personas": 2,

  "huesped": {
    "id_huesped": 1,
    "nombres": "Carlos",
    "apellidos": "Mendoza",
    "dni": "70111222"
  },

  "habitacion": {
    "id_habitacion": 1,
    "nro_habitacion": 101,
    "piso": 1,
    "capacidad": 2,
    "precio_base": 150.00
  },

  "empleado": {
    "id_empleado": 1,
    "nombre": "Pedro",
    "apellido": "Salas"
  },

  "estadia": {
    "id_estadia": 1,
    "fch_ingreso": "2026-05-10",
    "fch_salida": "2026-05-12",
    "hr_ingreso": "14:00",
    "hr_salida": "11:00"
  },

  "pago": {
    "id_pago": 101,
    "fch_pago": "2026-05-15",
    "monto_total": 45.00,
    "estado_pago": "Pagado",

    "detalle_pago": [
      {
        "id_detalle": 201,
        "monto_abonado": 45.00,
        "descripcion": "Pago por 1 noche en habitacion simple",
        "servicio": {
          "id_servicio": 1,
          "nombre_servicio": "Hospedaje Habitacion Simple"
        }
      }
    ]
  }
}');

-- consultar propidad interna del json
SELECT *
FROM reserva_documental
WHERE datos->>'estado_reserva' = 'Confirmada';




