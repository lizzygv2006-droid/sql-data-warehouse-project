# DICCIONARIO DE DATOS PARA LA CAPA 'GOLD'
## RESUMEN
La Capa 'Gold' es la representación de datos a nivel de negocio, estructurado para dar soporte a casos de uso de análisis y generación de informes. 
Consta de **tablas de dimensiones** y **tablas de hechos** para métricas de negocio específicas.

---

### 1. **gold.dim_customers**
-**Propisito:** Almacena datos de clientes, información demográfica y geográfica.
-**Columnas:**

| Nombre de columna| Tipo de dato  | Descripción                                                                                         |
|------------------|---------------|-----------------------------------------------------------------------------------------------------|
| customer_key     | INT           | Clave subrogada que identifica de forma única cada registro de cliente en la tabla de dimensión.    |
| customer_id      | INT           | Identificador numérico único asignado a cada cliente.                                               |
| customer_number  | NVARCHAR(50)  | Identificador alfanumérico que representa al cliente, utilizado para el seguimiento y la referencia.|
| first_name       | NVARCHAR(50)  | El nombre del cliente, tal como figura en el sistema.                                               |
| last_name        | NVARCHAR(50)  | El apellido del cliente.                                                                            |
| country          | NVARCHAR(50)  | El país de residencia del cliente (e.j., 'Australia').                                              |
| marital_status   | NVARCHAR(50)  | El estado civil del cliente (e.j., 'Married', 'Single').                                            |
| gender           | NVARCHAR(50)  | El género del cliente (e.g., 'Male', 'Female', 'n/a').                                              |
| birthdate        | DATE          | La fecha de nacimiento del cliente, formateado como YYYY-MM-DD (e.j., 1971-10-06).                  |
| create_date      | DATE          | La fecha y tiempo en el cual el registro del cliente fue creado en el sistema                       |

---

### 2. **gold.dim_products**
- **Proposito:** Provides information about the products and their attributes.
- **Columnas:**

| Nombre de columna   | Tipo de dato  | Descripción                                                                                                     |
|---------------------|---------------|-----------------------------------------------------------------------------------------------------------------|
| product_key         | INT           | Clave subrogada que identifica de forma única cada registro de productos en la tabla de dimensión.              |
| product_id          | INT           | Un identificador único asignado a los productos para rastreo interno y referencia                               |
| product_number      | NVARCHAR(50)  | Un código alfanumérico estructurado que representa el producto, a menudo usado pata categorización o inventario |
| product_name        | NVARCHAR(50)  | Nombre descriptivo del producto, incluyendo detalles claves como tipo, color, y tamaño.                         |
| category_id         | NVARCHAR(50)  | Un identificador único para la categoría de los productos, vinculando a su clasificación de alto nivel.         |
| category            | NVARCHAR(50)  | La clasificación más amplia del producto(e.j., Bikes, Components) agrupando elementos relacionados              |
| subcategory         | NVARCHAR(50)  | Una clasificación más detallada del producto dentro de la categoría, como tipo de producto.                     |
| maintenance_required| NVARCHAR(50)  | Indica si el producto requiere mantenimiento(e.j., 'Yes', 'No').                                                |
| cost                | INT           | El costo o or precio base de los productos, medida en unidades monetarias.                                      |
| product_line        | NVARCHAR(50)  | La linea de producto específica o serie al cual el producto pertenece(e.j., Road, Mountain).                    |
| start_date          | DATE          | La fecha en la cual el producto se lanzó para la venta o uso                                                    |

---

### 3. **gold.fact_sales**
- **Proposito:** Almacena datos de ventas transaccionales con fines analíticos.
- **Columnas:**

| Nombre de columna | Tipo de dato   | Description                                                                                                 |
|-------------------|----------------|-------------------------------------------------------------------------------------------------------------|
| order_number      | NVARCHAR(50)   | Un identificador único alfanumérico por cada orden de venta (e.j., 'SO54496').                              |
| product_key       | INT            | Clave subrogada que enlaza la orden a los productos de la tabla dimensión.                                  |
| customer_key      | INT            | Clave subrogada que enlaza la orden a los clientes de la tabla dimensión.                                   |
| order_date        | DATE           | La fecha en la cual la orden fue realizada.                                                                 |
| shipping_date     | DATE           | La fecha en la cual la orden fue enviada al cliente.                                                        |
| due_date          | DATE           | La fecha en la cual el pago de la orden vence.                                                              |
| sales_amount      | INT            | El valor monetario total de la venta de la línea de producto, en unidades monetarias completas (e.j., 25).  |
| quantity          | INT            | El número de unidades del producto ordenado de la linea de producto (e.j., 1).                              |
| price             | INT            | El precio unitario del producto de la linea de producto, en unidades monetarias completas (e.j., 25).       |
