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
Reporte de consumos por empleado y servicio, mostrando cantidad de consumos, cantidad total y 
total recaudado, solo si el total recaudado es mayor o igual a 20, ordenado de mayor a menor recaudación.
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


/*
CONSULTA 
Reporte de consumos por empleado y servicio, mostrando cantidad de consumos, cantidad total y 
total recaudado, solo si el total recaudado es mayor o igual a 20, ordenado de mayor a menor recaudación.
*/

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

// CRUD COMPLEJO: INSERTAR RESERVA COMPLETA
// Inserta en 4 tablas: reserva, estadia, pago y detalle_pago
app.post("/reservas-completas", async (req, res) => {
    try {
        const datos = req.body;

        const reserva = await pool.query(`
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

        const estadia = await pool.query(`
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

        const pago = await pool.query(`
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

        const detalle = await pool.query(`
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

        res.json({
            mensaje: "Reserva completa registrada correctamente",
            id_reserva: id_reserva_generado,
            id_estadia: id_estadia_generado,
            id_pago: id_pago_generado,
            id_detalle: id_detalle_generado
        });

    } catch (error) {
        console.log(error);
        res.status(500).json({
            mensaje: "Error al registrar reserva completa",
            error: error.message
        });
    }
});


app.listen(3000, () => {
    console.log("Iniciado en http://localhost:3000");
});
