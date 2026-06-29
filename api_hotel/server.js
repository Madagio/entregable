//aqui estamos importando librerias 

const express = require("express"); // para crear una API 
const { Pool } = require("pg"); // permite conectar node.js con postgresql

//donde express sirve para crear la api, osea las rutas como :
/*GET /reportes/consumos
POST /reservas-completas
*/

const app = express();
app.use(express.json());

//crea la aplicacion, donde la api va a poder recibir archivos en formato json


// CONEXION A POSTGRESQL
const pool = new Pool({ //pool sera el objeto que usaremos para las consultas sql
    user: "postgres",
    host: "localhost",
    database: "hotel",
    password: "1234",
    port: 5432
}); // variable que guarda la conexion de la base de datos ademas pool es una clase que viene del paquete pg 



// el get() significa que se esta creando una ruta que responde a una peticion de tipo GET , GET se usa para consultar informacion
//"/" es la ruta principal http://localhost:3000/ representando la pagina inicial de la api
// RUTA PRINCIPAL

// el req y res (req, res) => {
/*   
    es una funcion que se ejecuta cuando alguien entra a esa ruta , en la que una significa req(request) y la otra responde(res)
}   osea la respuesta que tu servidor le va a devolver al cliente
*/


// PROBAR CONEXION CON POSTGRESQL
app.get("/probar-bd", async (req, res) => {
    try {
        const resultado = await pool.query("SELECT NOW()"); // manda una consulta a PostgreSQL DE LA FECHA Y hora actual del sv
        //pero como la base de datos no responde instantaneamente js recibe una promesa .await(espera hasta que postgre termine )
        //permaneciendo en esa linea 
        res.json(resultado.rows); // manda como respueesta de la API 
    } catch (error) {
        console.log(error);
        res.status(500).json({ mensaje: "Error al conectar con la base de datos" });
    }
});



/*
CONSULTA 
Listar los servicios consumidos atendidos por el empleado 2, mostrando cuántos consumos hubo, la cantidad total 
y el monto total recaudado por cada servicio, solo si el total recaudado es al menos 20
*/

// REPORTE CON GROUP BY Y HAVING
app.get("/reportes/consumos", async (req, res) => {
    try {
        const sql = `
            SELECT
                e.nombre AS nombre_empleado,
                e.apellido AS apellido_empleado,
                s.nombre_servicio,
                COUNT(c.id_consumo_srvc) AS cantidad_consumos,
                SUM(c.cantidad) AS total_cantidad,
                SUM(c.sub_total) AS total_recaudado
            FROM consumo_srvicio c
            INNER JOIN servicio s ON c.id_servicio = s.id_servicio
            INNER JOIN empleado e ON c.id_empleado = e.id_empleado
            WHERE c.id_empleado = 2
            GROUP BY e.nombre, e.apellido, s.nombre_servicio
            HAVING SUM(c.sub_total) >= 20
            ORDER BY total_recaudado DESC;
        `;

        const resultado = await pool.query(sql);
        res.json(resultado.rows);

    } catch (error) {
        console.log(error);
        res.status(500).json({ mensaje: "Error al generar reporte" });
    }
});




// EXPORTAR REPORTE A CSV
app.get("/reportes/consumos/exportar", async (req, res) => {
    try {
        const sql = `
            SELECT
                e.nombre AS nombre_empleado,
                e.apellido AS apellido_empleado,
                s.nombre_servicio,
                COUNT(c.id_consumo_srvc) AS cantidad_consumos,
                SUM(c.cantidad) AS total_cantidad,
                SUM(c.sub_total) AS total_recaudado
            FROM consumo_srvicio c
            INNER JOIN servicio s ON c.id_servicio = s.id_servicio
            INNER JOIN empleado e ON c.id_empleado = e.id_empleado
            WHERE c.id_empleado = 2
            GROUP BY e.nombre, e.apellido, s.nombre_servicio
            HAVING SUM(c.sub_total) >= 20
            ORDER BY total_recaudado DESC;
        `;

        const resultado = await pool.query(sql);

        let csv = "nombre_empleado,apellido_empleado,nombre_servicio,cantidad_consumos,total_cantidad,total_recaudado\n"; // encabezados
        //resueltado.rows = arreeglo de objetos de js , cada objeto representa una fila 
        resultado.rows.forEach(fila => { // fila es cada elemento de resultado.rows
            csv += `${fila.nombre_empleado},${fila.apellido_empleado},${fila.nombre_servicio},${fila.cantidad_consumos},${fila.total_cantidad},${fila.total_recaudado}\n`;
        }); // Crea una línea de texto usando los valores de cada propiedad de fila, separados por comas.

        res.setHeader("Content-Type", "text/csv"); // asegurar que se esta enviando un archivo csv para que no lo interprete como texto
        res.setHeader("Content-Disposition", "attachment; filename=reporte_consumos.csv"); //descargar esto como archivo con el nombre 
        res.send(csv);

    } catch (error) {
        console.log(error);
        res.status(500).json({ mensaje: "Error al exportar reporte" });
    }
});

// TRANSACCION: INSERTAR RESERVA COMPLETA
// POST : Inserta en 4 tablas: reserva, estadia, pago y detalle_pago
app.post("/reservas-completas", async (req, res) => {
    const client = await pool.connect();

    try {
        const datos = req.body;


        await client.query("BEGIN");

        const reserva = await client.query(`
            INSERT INTO reserva
            (fch_reserva, estado_reserva, cantidad_personas, id_huesped, id_habitacion, id_empleado)
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING id_reserva
        `, [
            datos.fch_reserva,
            datos.estado_reserva,
            datos.cantidad_personas,
            datos.id_huesped,
            datos.id_habitacion,
            datos.id_empleado
        ]);

        const id_reserva_generado = reserva.rows[0].id_reserva;

        const estadia = await client.query(`
            INSERT INTO estadia
            (fch_ingreso, fch_salida, hr_ingreso, hr_salida, id_empleado, id_reserva)
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING id_estadia
        `, [
            datos.fch_ingreso,
            datos.fch_salida,
            datos.hr_ingreso,
            datos.hr_salida,
            datos.id_empleado,
            id_reserva_generado
        ]);

        const id_estadia_generado = estadia.rows[0].id_estadia;

        const pago = await client.query(`
            INSERT INTO pago
            (fch_pago, monto_total, estado_pago, id_reserva, id_metodo)
            VALUES ($1, $2, $3, $4, $5)
            RETURNING id_pago
        `, [
            datos.fch_pago,
            datos.monto_total,
            datos.estado_pago,
            id_reserva_generado,
            datos.id_metodo
        ]);

        const id_pago_generado = pago.rows[0].id_pago;

        const detalle = await client.query(`
            INSERT INTO detalle_pago
            (monto_abonado, descripcion, id_pago, id_servicio)
            VALUES ($1, $2, $3, $4)
            RETURNING id_detalle
        `, [
            datos.monto_abonado,
            datos.descripcion,
            id_pago_generado,
            datos.id_servicio
        ]);

        const id_detalle_generado = detalle.rows[0].id_detalle;

        await client.query("COMMIT");

        res.json({
            mensaje: "Reserva completa registrada correctamente con COMMIT",
            id_reserva: id_reserva_generado,
            id_estadia: id_estadia_generado,
            id_pago: id_pago_generado,
            id_detalle: id_detalle_generado
        });

    } catch (error) {

        await client.query("ROLLBACK");

        console.log(error);

        res.status(500).json({
            mensaje: "Error en la transaccion. Se ejecuto ROLLBACK",
            error: error.message
        });

    } finally {
        client.release();
    }
});

// GET: listar reservas completas
app.get("/reservas-completas", async (req, res) => {
    try {
        const sql = `
            SELECT
                r.id_reserva,
                r.fch_reserva,
                r.estado_reserva,
                r.cantidad_personas,

                r.id_huesped,
                r.id_habitacion,
                r.id_empleado,

                es.id_estadia,
                es.fch_ingreso,
                es.fch_salida,
                es.hr_ingreso,
                es.hr_salida,

                p.id_pago,
                p.fch_pago,
                p.monto_total,
                p.estado_pago,
                p.id_metodo,

                dp.id_detalle,
                dp.monto_abonado,
                dp.descripcion AS descripcion_detalle,
                dp.id_servicio
            FROM reserva r
            INNER JOIN estadia es 
                ON r.id_reserva = es.id_reserva
            INNER JOIN pago p 
                ON r.id_reserva = p.id_reserva
            INNER JOIN detalle_pago dp 
                ON p.id_pago = dp.id_pago
            ORDER BY r.id_reserva DESC;
        `;

        const resultado = await pool.query(sql);
        res.json(resultado.rows);

    } catch (error) {
        console.log(error);
        res.status(500).json({
            mensaje: "Error al listar reservas completas",
            error: error.message
        });
    }
});


// PUT: actualizar reserva completa
app.put("/reservas-completas/:id", async (req, res) => {
    const client = await pool.connect();

    try {
        const id_reserva = req.params.id;
        const datos = req.body;

        await client.query("BEGIN");

        const reserva = await client.query(`
            UPDATE reserva
            SET fch_reserva = $1,
                estado_reserva = $2,
                cantidad_personas = $3,
                id_huesped = $4,
                id_habitacion = $5,
                id_empleado = $6
            WHERE id_reserva = $7
            RETURNING id_reserva;
        `, [
            datos.fch_reserva,
            datos.estado_reserva,
            datos.cantidad_personas,
            datos.id_huesped,
            datos.id_habitacion,
            datos.id_empleado,
            id_reserva
        ]);

        if (reserva.rows.length === 0) {
            await client.query("ROLLBACK");
            return res.status(404).json({
                mensaje: "Reserva no encontrada"
            });
        }

        const estadia = await client.query(`
            UPDATE estadia
            SET fch_ingreso = $1,
                fch_salida = $2,
                hr_ingreso = $3,
                hr_salida = $4,
                id_empleado = $5
            WHERE id_reserva = $6
            RETURNING id_estadia;
        `, [
            datos.fch_ingreso,
            datos.fch_salida,
            datos.hr_ingreso,
            datos.hr_salida,
            datos.id_empleado,
            id_reserva
        ]);

        const pago = await client.query(`
            UPDATE pago
            SET fch_pago = $1,
                monto_total = $2,
                estado_pago = $3,
                id_metodo = $4
            WHERE id_reserva = $5
            RETURNING id_pago;
        `, [
            datos.fch_pago,
            datos.monto_total,
            datos.estado_pago,
            datos.id_metodo,
            id_reserva
        ]);

        if (pago.rows.length === 0) {
            await client.query("ROLLBACK");
            return res.status(404).json({
                mensaje: "Pago asociado a la reserva no encontrado"
            });
        }

        const id_pago = pago.rows[0].id_pago;

        const detalle = await client.query(`
            UPDATE detalle_pago
            SET monto_abonado = $1,
                descripcion = $2,
                id_servicio = $3
            WHERE id_pago = $4
            RETURNING id_detalle;
        `, [
            datos.monto_abonado,
            datos.descripcion,
            datos.id_servicio,
            id_pago
        ]);

        await client.query("COMMIT");

        res.json({
            mensaje: "Reserva completa actualizada correctamente con COMMIT",
            id_reserva: reserva.rows[0].id_reserva,
            id_estadia: estadia.rows[0]?.id_estadia,
            id_pago: id_pago,
            id_detalle: detalle.rows[0]?.id_detalle
        });

    } catch (error) {
        await client.query("ROLLBACK");

        console.log(error);

        res.status(500).json({
            mensaje: "Error al actualizar reserva completa. Se ejecuto ROLLBACK",
            error: error.message
        });

    } finally {
        client.release();
    }
});


// DELETE: eliminar reserva completa
app.delete("/reservas-completas/:id", async (req, res) => {
    const client = await pool.connect();

    try {
        const id_reserva = req.params.id;

        await client.query("BEGIN");

        const pagos = await client.query(`
            SELECT id_pago
            FROM pago
            WHERE id_reserva = $1;
        `, [id_reserva]);

        for (const fila of pagos.rows) {
            await client.query(`
                DELETE FROM detalle_pago
                WHERE id_pago = $1;
            `, [fila.id_pago]);
        }

        await client.query(`
            DELETE FROM pago
            WHERE id_reserva = $1;
        `, [id_reserva]);

        await client.query(`
            DELETE FROM estadia
            WHERE id_reserva = $1;
        `, [id_reserva]);

        const reserva = await client.query(`
            DELETE FROM reserva
            WHERE id_reserva = $1
            RETURNING id_reserva;
        `, [id_reserva]);

        if (reserva.rows.length === 0) {
            await client.query("ROLLBACK");
            return res.status(404).json({
                mensaje: "Reserva no encontrada"
            });
        }

        await client.query("COMMIT");

        res.json({
            mensaje: "Reserva completa eliminada correctamente con COMMIT",
            id_reserva_eliminada: reserva.rows[0].id_reserva
        });

    } catch (error) {
        await client.query("ROLLBACK");

        console.log(error);

        res.status(500).json({
            mensaje: "Error al eliminar reserva completa. Se ejecuto ROLLBACK",
            error: error.message
        });

    } finally {
        client.release();
    }
});


app.listen(3000, () => {
    console.log("Iniciado en http://localhost:3000");
});
