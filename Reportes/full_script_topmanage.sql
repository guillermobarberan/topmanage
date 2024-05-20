select * from DOCS;  -- CABECERA DE DOCUMENTOS
select * from LNS1;  -- LINEAS DE DOCUMENTOS
select * from CLNT;  -- CLIENTES
select * from ITMS;  -- ARTICULOS
select * from EMPL;  -- EMPLEADOS

/****** 1. Hacer un reporte donde se listen todos los documentos de los clientes 
 * C00005 y P00005. Las columnas que se requieren para el reporte son las siguientes:
******/
SELECT
    -- a. Tipo del Documento - # de Documento
    CASE 
        WHEN D."DocType" = 13 THEN 'FACTURA DE VENTA'
        WHEN D."DocType" = 14 THEN 'NOTA DE CRÉDITO DE VENTA'
        WHEN D."DocType" = 18 THEN 'FACTURA DE COMPRA'
        WHEN D."DocType" = 19 THEN 'NOTA DE CRÉDITO DE COMPRA'
        ELSE 'DESCONOCIDO'
    END || ' - ' || D."DocNum" AS "Tipo del Documento - # de Documento",
    
    -- b. Fecha de Documento
    TO_CHAR(D."DocDate", 'DD/MM/YYYY') AS "Fecha de Documento",
    
    -- c. Fecha de Vencimiento del Documento
    TO_CHAR(D."DocDueDate", 'DD/MM/YYYY') AS "Fecha de Vencimiento del Documento",
    
    -- d. Código del Cliente
    UPPER(D."ClntCode") AS "Código del Cliente",
    
    -- e. Nombre del Cliente
    UPPER(C."ClntName") AS "Nombre del Cliente",
    
    -- f. RUC
    UPPER(C."LicTradNum") AS "RUC",
    
    -- g. Subtotal (sin impuesto)
    TO_CHAR(ROUND(SUM(L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100)), 2), '999999.99') AS "Subtotal (sin impuesto)",
    
    -- h. Total de Impuesto
    TO_CHAR(ROUND(SUM(L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100) * L."TaxPrcnt" / 100), 2), '999999.99') AS "Total de Impuesto",
    
    -- i. Total de Retención IVA
    TO_CHAR(ROUND(SUM(L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100) * (C."WBPrcnt" / 100)), 2), '999999.99') AS "Total de Retención IVA",
    
    -- j. Total de Retención Renta
    TO_CHAR(ROUND(SUM(L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100) * (C."WTaxPrcnt" / 100)), 2), '999999.99') AS "Total de Retención Renta"
    
FROM DOCS D
JOIN LNS1 L ON D."DocID" = L."DocID" AND D."DocType" = L."DocType"
JOIN CLNT C ON D."ClntCode" = C."ClntCode"
WHERE D."ClntCode" IN ('C00005', 'P00005')
GROUP BY 
    D."DocID", 
    D."DocType", 
    D."DocNum", 
    D."DocDate", 
    D."DocDueDate", 
    D."ClntCode", 
    C."ClntName", 
    C."LicTradNum", 
    C."WBPrcnt", 
    C."WTaxPrcnt"
ORDER BY D."DocDate";


/****** 2. Basado en el reporte anterior, modificar para que los registros que salgan sean facturas 
 * (venta o compra) y agregar las siguientes columnas:******/
WITH 
Facturas AS (
    SELECT
        D."DocID",
        CASE 
            WHEN D."DocType" = 13 THEN 'FACTURA DE VENTA'
            WHEN D."DocType" = 18 THEN 'FACTURA DE COMPRA'
            ELSE 'DESCONOCIDO'
        END AS "Tipo del Documento",
        D."DocNum",
        TO_CHAR(D."DocDate", 'DD/MM/YYYY') AS "Fecha de Documento",
        TO_CHAR(D."DocDueDate", 'DD/MM/YYYY') AS "Fecha de Vencimiento del Documento",
        UPPER(D."ClntCode") AS "Código del Cliente",
        UPPER(C."ClntName") AS "Nombre del Cliente",
        UPPER(C."LicTradNum") AS "RUC",
        ROUND(SUM(L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100)), 2) AS "Subtotal (sin impuesto)",
        ROUND(SUM(L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100) * L."TaxPrcnt" / 100), 2) AS "Total de Impuesto",
        ROUND(SUM(L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100) * (C."WBPrcnt" / 100)), 2) AS "Total de Retención IVA",
        ROUND(SUM(L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100) * (C."WTaxPrcnt" / 100)), 2) AS "Total de Retención Renta"
    FROM DOCS D
    JOIN LNS1 L ON D."DocID" = L."DocID" AND D."DocType" = L."DocType"
    JOIN CLNT C ON D."ClntCode" = C."ClntCode"
    WHERE D."ClntCode" = 'C00003' AND D."DocType" IN (13, 18)
    GROUP BY 
        D."DocID", 
        D."DocType", 
        D."DocNum", 
        D."DocDate", 
        D."DocDueDate", 
        D."ClntCode", 
        C."ClntName", 
        C."LicTradNum", 
        C."WBPrcnt", 
        C."WTaxPrcnt"
),
NotasCredito AS (
    SELECT
        L."BaseDocID",
        D."DocNum" AS "NC_DocNum",
        ROUND(SUM(L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100)), 2) AS "NC_Subtotal",
        ROUND(SUM(L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100) * L."TaxPrcnt" / 100), 2) AS "NC_Impuesto"
    FROM DOCS D
    JOIN LNS1 L ON D."DocID" = L."DocID" AND D."DocType" = L."DocType"
    WHERE D."ClntCode" = 'C00003' AND D."DocType" = 14
    GROUP BY L."BaseDocID", D."DocNum"
)
SELECT
    F."Tipo del Documento" || ' - ' || F."DocNum" AS "Tipo del Documento - # de Documento",
    F."Fecha de Documento",
    F."Fecha de Vencimiento del Documento",
    F."Código del Cliente",
    F."Nombre del Cliente",
    F."RUC",
    TO_CHAR(F."Subtotal (sin impuesto)", '999999.99') AS "Subtotal (sin impuesto)",
    TO_CHAR(F."Total de Impuesto", '999999.99') AS "Total de Impuesto",
    TO_CHAR(F."Total de Retención IVA", '999999.99') AS "Total de Retención IVA",
    TO_CHAR(F."Total de Retención Renta", '999999.99') AS "Total de Retención Renta",
    NC."NC_DocNum" AS "# de Nota de Crédito",
    COALESCE(TO_CHAR(NC."NC_Subtotal", '999999.99'), '0.00') AS "Subtotal (sin impuesto) NC",
    COALESCE(TO_CHAR(NC."NC_Impuesto", '999999.99'), '0.00') AS "Total Impuesto NC",
    TO_CHAR(F."Subtotal (sin impuesto)" + F."Total de Impuesto" - F."Total de Retención IVA" - F."Total de Retención Renta" - COALESCE(NC."NC_Subtotal", 0) - COALESCE(NC."NC_Impuesto", 0),'999999.99') AS "Deuda Total"
FROM Facturas F
LEFT JOIN NotasCredito NC ON F."DocID" = NC."BaseDocID"
ORDER BY F."Fecha de Documento";


/****** 3. Hacer un reporte que, dado un número de documento (#400005), 
 * liste el flujo (Factura --> Nota de Crédito)   de todos los artículos, 
 * ordenado por número de línea de la factura.
******/
WITH Factura AS (
    SELECT
        D."DocID",
        D."DocNum",
        D."DocType",
        D."ClntCode",
        TO_CHAR(D."DocDate", 'DD/MM/YYYY') AS "Fecha de Documento",
        TO_CHAR(D."DocDueDate", 'DD/MM/YYYY') AS "Fecha de Vencimiento del Documento",
        L."LineNum",
        L."ItemCode",
        I."ItemName",
        I."CodBars",
        L."Qty",
        L."UnitPrice",
        L."DiscPrcnt",
        L."TaxPrcnt",
        C."WTaxPrcnt",
        C."WBPrcnt",
        ROUND(L."UnitPrice" * (1 - L."DiscPrcnt" / 100), 2) AS "PrecioUnitFinal",
        ROUND(L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100) * L."TaxPrcnt" / 100, 2) AS "MontoImpuesto",
        ROUND(L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100) + L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100) * L."TaxPrcnt" / 100, 2) AS "TotalLinea",
        ROUND(L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100) * (C."WTaxPrcnt" / 100), 2) AS "MontoRetRenta",
        ROUND(L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100) * (C."WBPrcnt" / 100), 2) AS "MontoRetIVA"
    FROM DOCS D
    JOIN LNS1 L ON D."DocID" = L."DocID" AND D."DocType" = L."DocType"
    JOIN CLNT C ON D."ClntCode" = C."ClntCode"
    JOIN ITMS I ON L."ItemCode" = I."ItemCode"
    WHERE D."DocNum" = 400005
),
NotasCredito AS (
    SELECT
        L."BaseDocID",
        L."BaseDocType",
        L."BaseDocLine",
        D."DocNum" AS "NC_DocNum",
        TO_CHAR(D."DocDate", 'DD/MM/YYYY') AS "Fecha de Nota de Crédito",
        L."LineNum" AS "NC_LineNum",
        L."ItemCode" AS "NC_ItemCode",
        L."Qty" AS "NC_Qty",
        ROUND(L."UnitPrice" * (1 - L."DiscPrcnt" / 100), 2) AS "NC_PrecioUnitFinal",
        ROUND(L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100) * L."TaxPrcnt" / 100, 2) AS "NC_MontoImpuesto",
        ROUND(L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100) + L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100) * L."TaxPrcnt" / 100, 2) AS "NC_TotalLinea"
    FROM DOCS D
    JOIN LNS1 L ON D."DocID" = L."DocID" AND D."DocType" = L."DocType"
    WHERE D."DocType" = 14
)
SELECT
    F."LineNum" AS "# Línea",
    F."ItemCode" AS "Código del Item",
    F."ItemName" || ' (' || F."CodBars" || ')' AS "Nombre del Item + Código de Barras",
    F."Qty" AS "Cant. en la Factura",
    TO_CHAR(F."UnitPrice", '999999.99') AS "Precio Unitario en la Factura",
    TO_CHAR(F."UnitPrice" * F."DiscPrcnt" / 100, '999999.99') || ' (' || F."DiscPrcnt" || '%)' AS "Monto y Porcentaje de Descuento en la Factura",
    TO_CHAR(F."PrecioUnitFinal", '999999.99') AS "Precio Unitario Final después del Descuento",
    TO_CHAR(F."MontoImpuesto", '999999.99') || ' (' || F."TaxPrcnt" || '%)' AS "Monto y Porcentaje de Impuesto en la Factura",
    TO_CHAR(F."TotalLinea", '999999.99') AS "Total de la Línea",
    TO_CHAR(F."MontoRetRenta", '999999.99') || ' (' || F."WTaxPrcnt" || '%)' AS "Monto y Porcentaje de Retención de Renta en la Factura",
    TO_CHAR(F."MontoRetIVA", '999999.99') || ' (' || F."WBPrcnt" || '%)' AS "Monto y Porcentaje de Retención de Impuesto en la Factura",
    NC."NC_DocNum" AS "# de Nota de Crédito",
    NC."NC_LineNum" AS "Línea en la Nota de Crédito",
    COALESCE(TO_CHAR(NC."NC_Qty", '999999.99'), '0.00') AS "Cantidad en la NC",
    COALESCE(TO_CHAR(NC."NC_TotalLinea", '999999.99'), '0.00') AS "Monto Final de la Línea de NC (incluye impuesto)"
FROM Factura F
LEFT JOIN NotasCredito NC ON F."DocID" = NC."BaseDocID" AND F."DocType" = NC."BaseDocType" AND F."LineNum" = NC."BaseDocLine"
ORDER BY F."LineNum";

/******4. Hacer un reporte que calcule las comsisiones de los vendedores de acuerdo al monto de la factura (con impuesto) - el monto de la nota de crédito (con impuesto). No mostrar empleado cuyas comisiones sean 0 ambas.
Las columnas que se requieren para el reporte son las siguientes:
a. Nombre del Vendedor
b. Porcentaje Comisión
c. Comisión de Ventas 
d. Comision en Compras
******/

WITH FacturaConImpuesto AS (
    SELECT
        D."EmpCode",
        E."EmpName" AS "Nombre_del_Vendedor",
        E."Comission" AS "Porcentaje_Comision",
        ROUND(SUM(L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100) * (1 + L."TaxPrcnt" / 100)), 2) AS "MontoFacturaConImpuesto"
    FROM DOCS D
    JOIN LNS1 L ON D."DocID" = L."DocID" AND D."DocType" = L."DocType"
    JOIN EMPL E ON D."EmpCode" = E."EmpCod"
    WHERE D."DocType" = 13 -- Factura de Venta
    GROUP BY D."EmpCode", E."EmpName", E."Comission"
), 
NotaCreditoConImpuesto AS (
    SELECT
        D."EmpCode",
        ROUND(SUM(L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100) * (1 + L."TaxPrcnt" / 100)), 2) AS "MontoNCConImpuesto"
    FROM DOCS D
    JOIN LNS1 L ON D."DocID" = L."DocID" AND D."DocType" = L."DocType"
    WHERE D."DocType" = 14 -- Nota de Crédito de Venta
    GROUP BY D."EmpCode"
), 
FacturaCompraConImpuesto AS (
    SELECT
        D."EmpCode",
        ROUND(SUM(L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100) * (1 + L."TaxPrcnt" / 100)), 2) AS "MontoFacturaCompraConImpuesto"
    FROM DOCS D
    JOIN LNS1 L ON D."DocID" = L."DocID" AND D."DocType" = L."DocType"
    WHERE D."DocType" = 18 -- Factura de Compra
    GROUP BY D."EmpCode"
), 
NotaCreditoCompraConImpuesto AS (
    SELECT
        D."EmpCode",
        ROUND(SUM(L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100) * (1 + L."TaxPrcnt" / 100)), 2) AS "MontoNCCompraConImpuesto"
    FROM DOCS D
    JOIN LNS1 L ON D."DocID" = L."DocID" AND D."DocType" = L."DocType"
    WHERE D."DocType" = 19 -- Nota de Crédito de Compra
    GROUP BY D."EmpCode"
)
SELECT
    E."EmpName" AS "Nombre_del_Vendedor",
    E."Comission" AS "Porcentaje_Comision",
    ROUND((COALESCE(F."MontoFacturaConImpuesto", 0) - COALESCE(NC."MontoNCConImpuesto", 0)) * E."Comission" / 100, 2) AS "Comisión_de_Ventas",
    ROUND((COALESCE(FC."MontoFacturaCompraConImpuesto", 0) - COALESCE(NCC."MontoNCCompraConImpuesto", 0)) * E."Comission" / 100, 2) AS "Comisión_en_Compras"
FROM EMPL E
LEFT JOIN FacturaConImpuesto F ON E."EmpCod" = F."EmpCode"
LEFT JOIN NotaCreditoConImpuesto NC ON E."EmpCod" = NC."EmpCode"
LEFT JOIN FacturaCompraConImpuesto FC ON E."EmpCod" = FC."EmpCode"
LEFT JOIN NotaCreditoCompraConImpuesto NCC ON E."EmpCod" = NCC."EmpCode"
WHERE 
    ROUND((COALESCE(F."MontoFacturaConImpuesto", 0) - COALESCE(NC."MontoNCConImpuesto", 0)) * E."Comission" / 100, 2) != 0
    OR
    ROUND((COALESCE(FC."MontoFacturaCompraConImpuesto", 0) - COALESCE(NCC."MontoNCCompraConImpuesto", 0)) * E."Comission" / 100, 2) != 0
ORDER BY E."EmpName";



/****** 5. Basado en el reporte anterior, mostrar el monto base de las ventas y 
 * compras, agrupar por año + mes y agregar una línea con el total por mes para un año en específico (2024)
******/
WITH 
FacturaConImpuesto AS (
    SELECT
        D."EmpCode",
        E."EmpName" AS "Nombre_del_Vendedor",
        E."Comission" AS "Porcentaje_Comisión",
        DATE_TRUNC('month', D."DocDate") AS "Mes",
        ROUND(SUM(L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100)), 2) AS "MontoBaseFactura",
        ROUND(SUM(L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100) * (1 + L."TaxPrcnt" / 100)), 2) AS "MontoFacturaConImpuesto"
    FROM DOCS D
    JOIN LNS1 L ON D."DocID" = L."DocID" AND D."DocType" = L."DocType"
    JOIN EMPL E ON D."EmpCode" = E."EmpCod"
    WHERE D."DocType" = 13 AND DATE_PART('year', D."DocDate") = 2024 -- Factura de Venta en 2024
    GROUP BY D."EmpCode", E."EmpName", E."Comission", DATE_TRUNC('month', D."DocDate")
),
NotaCreditoConImpuesto AS (
    SELECT
        D."EmpCode",
        DATE_TRUNC('month', D."DocDate") AS "Mes",
        ROUND(SUM(L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100)), 2) AS "MontoBaseNC",
        ROUND(SUM(L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100) * (1 + L."TaxPrcnt" / 100)), 2) AS "MontoNCConImpuesto"
    FROM DOCS D
    JOIN LNS1 L ON D."DocID" = L."DocID" AND D."DocType" = L."DocType"
    WHERE D."DocType" = 14 AND DATE_PART('year', D."DocDate") = 2024 -- Nota de Crédito de Venta en 2024
    GROUP BY D."EmpCode", DATE_TRUNC('month', D."DocDate")
),
FacturaCompraConImpuesto AS (
    SELECT
        D."EmpCode",
        DATE_TRUNC('month', D."DocDate") AS "Mes",
        ROUND(SUM(L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100)), 2) AS "MontoBaseFacturaCompra",
        ROUND(SUM(L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100) * (1 + L."TaxPrcnt" / 100)), 2) AS "MontoFacturaCompraConImpuesto"
    FROM DOCS D
    JOIN LNS1 L ON D."DocID" = L."DocID" AND D."DocType" = L."DocType"
    WHERE D."DocType" = 18 AND DATE_PART('year', D."DocDate") = 2024 -- Factura de Compra en 2024
    GROUP BY D."EmpCode", DATE_TRUNC('month', D."DocDate")
),
NotaCreditoCompraConImpuesto AS (
    SELECT
        D."EmpCode",
        DATE_TRUNC('month', D."DocDate") AS "Mes",
        ROUND(SUM(L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100)), 2) AS "MontoBaseNCCompra",
        ROUND(SUM(L."Qty" * L."UnitPrice" * (1 - L."DiscPrcnt" / 100) * (1 + L."TaxPrcnt" / 100)), 2) AS "MontoNCCompraConImpuesto"
    FROM DOCS D
    JOIN LNS1 L ON D."DocID" = L."DocID" AND D."DocType" = L."DocType"
    WHERE D."DocType" = 19 AND DATE_PART('year', D."DocDate") = 2024 -- Nota de Crédito de Compra en 2024
    GROUP BY D."EmpCode", DATE_TRUNC('month', D."DocDate")
),

Comisiones AS (
    SELECT
        F."Nombre_del_Vendedor",
        F."Porcentaje_Comisión",
        F."Mes",
        ROUND((COALESCE(F."MontoBaseFactura", 0) - COALESCE(NC."MontoBaseNC", 0)) * F."Porcentaje_Comisión" / 100, 2) AS "Comisión_de_Ventas",
        ROUND((COALESCE(FC."MontoBaseFacturaCompra", 0) - COALESCE(NCC."MontoBaseNCCompra", 0)) * F."Porcentaje_Comisión" / 100, 2) AS "Comisión_en_Compras"
    FROM FacturaConImpuesto F
    FULL JOIN NotaCreditoConImpuesto NC ON F."EmpCode" = NC."EmpCode" AND F."Mes" = NC."Mes"
    FULL JOIN FacturaCompraConImpuesto FC ON F."EmpCode" = FC."EmpCode" AND F."Mes" = FC."Mes"
    FULL JOIN NotaCreditoCompraConImpuesto NCC ON F."EmpCode" = NCC."EmpCode" AND F."Mes" = NCC."Mes"
    JOIN EMPL E ON F."EmpCode" = E."EmpCod" OR NC."EmpCode" = E."EmpCod" OR FC."EmpCode" = E."EmpCod" OR NCC."EmpCode" = E."EmpCod"
    WHERE 
        ROUND((COALESCE(F."MontoBaseFactura", 0) - COALESCE(NC."MontoBaseNC", 0)) * F."Porcentaje_Comisión" / 100, 2) != 0
        OR
        ROUND((COALESCE(FC."MontoBaseFacturaCompra", 0) - COALESCE(NCC."MontoBaseNCCompra", 0)) * F."Porcentaje_Comisión" / 100, 2) != 0)
SELECT
    C."Mes" AS "Año",
    C."Nombre_del_Vendedor",
    C."Porcentaje_Comisión",
    SUM(C."Comisión_de_Ventas") AS "Comisión_de_Ventas",
    SUM(C."Comisión_en_Compras") AS "Comisión_en_Compras"
FROM Comisiones C
GROUP BY C."Mes", C."Nombre_del_Vendedor", C."Porcentaje_Comisión"
ORDER BY C."Mes", C."Nombre_del_Vendedor"

/****** TM TEST  ******/

/* CABECERA DE DOCUMENTOS */
CREATE TABLE DOCS(
	"DocID" integer NOT NULL,
	"DocType" integer NULL,
	"DocNum" integer NULL,
	"DocDate" date NULL,
  	"DocDueDate" date NULL,
	"ClntCode" character varying(15) NULL,
	"EmpCode" integer NULL
);
/* LINEAS DE DOCUMENTOS */
CREATE TABLE LNS1(
	"DocID" integer NOT NULL,
	"DocType" integer NULL,
	"LineNum" integer NOT NULL,
	"ItemCode" character varying(50) NULL,
  	"Qty" decimal(19, 6) NULL,
  	"UnitPrice" decimal(19, 6) NULL,
  	"DiscPrcnt" decimal(19, 6) NULL,
  	"Price" decimal(19, 6) NULL,
  	"TaxPrcnt" decimal(19, 6) NULL,
	"BaseDocID" integer NULL,
	"BaseDocType" integer NULL,
	"BaseDocLine" integer NULL
);
/* CLIENTES */
CREATE TABLE CLNT(
	"ClntCode" character varying(50) NULL,
  	"ClntType" character varying(1) NULL,
	"ClntName" character varying(100) NULL,
	"LicTradNum" character varying(50) NULL,
  	"WTaxPrcnt" decimal(19,6) NULL,
  	"WBPrcnt" decimal(19,6) NULL
);
/* ARTICULOS */
CREATE TABLE ITMS(
	"ItemCode" character varying(50) NULL,
	"ItemName" character varying(100) NULL,
	"CodBars" character varying(10) NULL
);
/* EMPLEADOS */
CREATE TABLE EMPL(
	"EmpCod" integer NULL,
	"EmpName" character varying(100) NULL,
	"Comission" decimal(19,6) NULL
);


/*********  TEST DATA **************/
/* EMPLEADOS */
INSERT INTO EMPL VALUES (1, 'Omar González', 1.5);
INSERT INTO EMPL VALUES (2, 'José Pérez', 1.0);
INSERT INTO EMPL VALUES (3, 'Francisco Cárdenas', 0.5);
INSERT INTO EMPL VALUES (4, 'Ana Trujillo', 1.0);
INSERT INTO EMPL VALUES (5, 'Mariana Franco', 0.0);
INSERT INTO EMPL VALUES (6, 'Roberto Contreras', 1.5);
INSERT INTO EMPL VALUES (7, 'Mario Fernández', 1.5);
/* CLIENTES */
INSERT INTO CLNT VALUES ('C00001', 'C', 'Impresoras Internacionales Galaxia',	'11-142367',		0.0, 0.0);
INSERT INTO CLNT VALUES ('C00002', 'C', 'Far East Imports',						'20-100644',		50.0, 1.75);
INSERT INTO CLNT VALUES ('C00003', 'C', 'Repuestos Panama',						'12-2822630',		25.0, 0.0);
INSERT INTO CLNT VALUES ('C00004', 'C', 'Acme Associates',						'16-923440',		0.0, 0.3);
INSERT INTO CLNT VALUES ('C00005', 'C', 'SG Electronics',						'26-438513',		30.0, 1.25);
INSERT INTO CLNT VALUES ('P00001', 'S', 'SMD Technologies',						'1294567890001',	0.0, 0.0);
INSERT INTO CLNT VALUES ('P00002', 'S', 'Materiales Graficos PTY',				'11-234567',		50.0, 1.0);
INSERT INTO CLNT VALUES ('P00003', 'S', 'Blockies Corporation',					'13-186727',		100.0, 0.0);
INSERT INTO CLNT VALUES ('P00004', 'S', 'Lumarx',								'26-107636',		0.0, 0.5);
INSERT INTO CLNT VALUES ('P00005', 'S', 'CTI Computers',						'45-137648',		100, 0.7);
/* ARTICULOS */
INSERT INTO ITMS VALUES ('A00001', 'J.B. Officeprint 1420', '1033272854');
INSERT INTO ITMS VALUES ('A00002', 'J.B. Officeprint 1111', '1910514787');
INSERT INTO ITMS VALUES ('A00003', 'J.B. Officeprint 1186', '1107277150');
INSERT INTO ITMS VALUES ('A00004', 'Rainbow Color Printer 5.0', '2121882846');
INSERT INTO ITMS VALUES ('A00005', 'Rainbow Color Printer 7.5', '0400985691');
INSERT INTO ITMS VALUES ('A00006', 'Rainbow 1200 Laser Series', '0734307381');
INSERT INTO ITMS VALUES ('B10000', 'Printer Label', '1327960172');
INSERT INTO ITMS VALUES ('C00001', 'Motherboard BTX', '0989835165');
INSERT INTO ITMS VALUES ('C00002', 'Motherboard MicroATX', '0629776520');
INSERT INTO ITMS VALUES ('C00003', 'Quadcore CPU 3.4 GHz', '1668027486');
INSERT INTO ITMS VALUES ('C00004', 'Tower Case with Power supply', '0058297223');
INSERT INTO ITMS VALUES ('C00005', 'WLAN Card', '1892692287');
INSERT INTO ITMS VALUES ('C00006', 'Gigabit Network Card', '1980025884');
INSERT INTO ITMS VALUES ('C00007', 'Hard Disk 3TB', '0299162164');
INSERT INTO ITMS VALUES ('C00008', 'Computer Monitor 24" HDMI', '1995956937');
INSERT INTO ITMS VALUES ('C00009', 'Keyboard Comfort USB', '1193075353');
INSERT INTO ITMS VALUES ('C00010', 'Mouse USB', '1365700015');
INSERT INTO ITMS VALUES ('C00011', 'Memory DDR RAM 8GB', '0740899545');
INSERT INTO ITMS VALUES ('C00012', 'Base para Disco externo HD', '1464573151');
INSERT INTO ITMS VALUES ('C00013', '1 TB disk for external HD', '1121671734');
INSERT INTO ITMS VALUES ('C00014', 'Laptop case', '0541624042');
INSERT INTO ITMS VALUES ('CM001', 'computadpr', '0305608603');
INSERT INTO ITMS VALUES ('CM002', 'mouse', '1257313031');
INSERT INTO ITMS VALUES ('CM006', 'ups', '0340434038');
INSERT INTO ITMS VALUES ('D00001', 'Portable Hard Disk 1TB', '0553855707');
INSERT INTO ITMS VALUES ('D00002', 'Portable Hard Disk 2TB', NULL);
INSERT INTO ITMS VALUES ('E00001', 'Secondhand Tablets', '1003787710');
INSERT INTO ITMS VALUES ('I00001', 'Blu-Ray Disc 10-Pack', '2034323658');
INSERT INTO ITMS VALUES ('I00002', 'Blu-Ray DL Disc 10-Pack', '1443467636');
INSERT INTO ITMS VALUES ('I00003', 'USB Flashdrive 128GB', '1932990104');
INSERT INTO ITMS VALUES ('I00004', 'USB Flashdrive 256GB', '0776717177');
INSERT INTO ITMS VALUES ('I00005', 'J.B. Laptop Batteries X1 series', '0750155817');
INSERT INTO ITMS VALUES ('I00006', 'J.B. Laptop Batteries X2 series', '0934081548');
INSERT INTO ITMS VALUES ('I00007', 'Rainbow Printer 9.5 Inkjet Cartridge', '0865239075');
INSERT INTO ITMS VALUES ('I00008', 'Rainbow Nuance Ink 6-Pack and Photo Paper Kit', '0443503308');
INSERT INTO ITMS VALUES ('I00009', 'SLR PreciseShot PX1500', '0529313300');
INSERT INTO ITMS VALUES ('I00010', 'SLR M-CAM 40C', '1994042537');
INSERT INTO ITMS VALUES ('I00011', 'KG USB Travel Hub', '0235436187');
INSERT INTO ITMS VALUES ('I00012', 'KG PC-to-Mac Transfer Kit', '0818573455');
INSERT INTO ITMS VALUES ('I00013', 'SDHC 64 GB Class 10', '1639895799');
INSERT INTO ITMS VALUES ('LM4029', 'LeMon 4029 Printer', '1106018303');
INSERT INTO ITMS VALUES ('LM4029ACA', 'LeMon 4029 Printer AC Adapter', '0386680479');
INSERT INTO ITMS VALUES ('LM4029APCD', 'LeMon 4029 Printer AC Power Cord', '0137859681');
INSERT INTO ITMS VALUES ('LM4029D', 'LeMon 4029 500 sheet paper drawer', '1639323035');
INSERT INTO ITMS VALUES ('LM4029MC', 'Memory Chip', '0986482255');
INSERT INTO ITMS VALUES ('LM4029PH', 'LeMon 4029 Printer Head', '1250938799');
INSERT INTO ITMS VALUES ('LM4029PS', 'LeMon 4029 Printer Power Supply', '0135512414');
INSERT INTO ITMS VALUES ('LM4029SB', 'LeMon 4029 Printer System Board', '0216145386');
INSERT INTO ITMS VALUES ('P10001', 'PC - 8x core, DDR 32GB, 2TB HDD', '1347782585');
INSERT INTO ITMS VALUES ('P10002', 'PC - 12x core, 64GB, 5 x 150GB SSD', '1756370019');
/* DOCUMENTOS */
/* FACTURAS DE VENTAS */
/*CABECERA */
INSERT INTO DOCS VALUES (1, 13, 100001, '2023-09-06', '2023-10-06', 'C00004', 4);
INSERT INTO DOCS VALUES (2, 13, 100002, '2023-11-15', '2023-12-15', 'C00003', 5);
INSERT INTO DOCS VALUES (3, 13, 100003, '2024-01-14', '2024-02-14', 'C00001', 2);
INSERT INTO DOCS VALUES (4, 13, 100004, '2023-01-14', '2023-02-14', 'C00002', 6);
INSERT INTO DOCS VALUES (5, 13, 100005, '2024-01-15', '2024-02-15', 'C00005', 3);
INSERT INTO DOCS VALUES (6, 13, 100006, '2024-02-28', '2024-03-28', 'C00003', 1);
INSERT INTO DOCS VALUES (7, 13, 100007, '2024-03-01', '2024-04-01', 'C00001', 2);
/* LINEAS */
INSERT INTO LNS1 VALUES (1, 13, 1, 'C00006', 13, 375.41, 10, 337.869, 7, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (1, 13, 2, 'P10002', 50, 435.36, 0, 435.36, 0, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (1, 13, 3, 'LM4029PH', 46, 218.76, 0, 218.76, 0, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (1, 13, 4, 'I00010', 37, 88.71, 15, 75.4035, 0, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (2, 13, 1, 'I00012', 39, 610.84, 0, 610.84, 7, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (2, 13, 2, 'CM002', 23, 820.58, 0, 820.58, 7, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (2, 13, 3, 'C00014', 21, 809.98, 15, 688.483, 0, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (3, 13, 1, 'I00001', 28, 289.92, 0, 289.92, 7, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (3, 13, 2, 'C00006', 13, 649.16, 0, 649.16, 7, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (3, 13, 3, 'C00002', 9, 241.1, 0, 241.1, 7, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (3, 13, 4, 'I00007', 34, 470.77, 0, 470.77, 0, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (3, 13, 5, 'I00002', 29, 299.92, 0, 299.92, 7, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (4, 13, 1, 'E00001', 27, 29.89, 0, 29.89, 7, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (4, 13, 2, 'C00004', 11, 48.66, 0, 48.66, 7, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (5, 13, 1, 'A00004', 4, 492.8, 20, 394.24, 0, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (5, 13, 2, 'C00006', 13, 572.97, 0, 572.97, 0, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (5, 13, 3, 'D00002', 26, 621.05, 20, 496.84, 0, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (6, 13, 1, 'I00011', 38, 530.9, 0, 530.9, 7, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (7, 13, 1, 'CM001', 22, 375.18, 0, 375.18, 0, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (7, 13, 2, 'C00014', 21, 478.44, 10, 430.596, 0, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (7, 13, 3, 'CM001', 22, 271.29, 0, 271.29, 0, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (7, 13, 4, 'I00007', 34, 690.38, 0, 690.38, 7, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (7, 13, 5, 'CM002', 23, 373.71, 0, 373.71, 0, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (7, 13, 6, 'A00005', 5, 853.91, 15, 725.8235, 0, NULL, NULL, NULL);

/* NOTA DE CREDITO DE VENTAS */
/* CABECERA */
INSERT INTO DOCS VALUES (1, 14, 200001, '2024-01-20', '2024-01-20', 'C00005', 3);
INSERT INTO DOCS VALUES (2, 14, 200002, '2024-03-01', '2024-03-01', 'C00003', 1);
INSERT INTO DOCS VALUES (3, 14, 200003, '2023-03-02', '2023-03-02', 'C00005', 3);
INSERT INTO DOCS VALUES (4, 14, 200004, '2024-03-03', '2024-03-03', 'C00001', 2);
/* LINEAS */
INSERT INTO LNS1 VALUES (1, 14, 1, 'C00006', 5, 572.97, 0, 572.97, 0, 5, 13, 2);
INSERT INTO LNS1 VALUES (2, 14, 1, 'I00011', 38, 530.9, 0, 530.9, 7, 6, 13, 1);
INSERT INTO LNS1 VALUES (3, 14, 1, 'D00002', 20, 621.05, 20, 496.84, 0, 5, 13, 3);
INSERT INTO LNS1 VALUES (4, 14, 1, 'I00007', 10, 690.38, 0, 690.38, 7, 7, 13, 4);
INSERT INTO LNS1 VALUES (4, 14, 2, 'A00005', 5, 853.91, 15, 725.8235, 0, 7, 13, 6);

/* FACTURAS DE COMPRAS */
/* CABECERA */
INSERT INTO DOCS VALUES (1, 18, 400001, '2023-08-03', '2023-09-03', 'P00004', 4);
INSERT INTO DOCS VALUES (2, 18, 400002, '2023-09-09', '2023-10-09', 'P00003', 5);
INSERT INTO DOCS VALUES (3, 18, 400003, '2023-12-14', '2024-01-14', 'P00001', 2);
INSERT INTO DOCS VALUES (4, 18, 400004, '2023-12-29', '2024-01-29', 'P00002', 6);
INSERT INTO DOCS VALUES (5, 18, 400005, '2024-01-12', '2024-02-12', 'P00005', 3);
INSERT INTO DOCS VALUES (6, 18, 400006, '2024-02-28', '2024-03-28', 'P00003', 1);
INSERT INTO DOCS VALUES (7, 18, 400007, '2024-03-05', '2024-04-05', 'P00001', 2);
/* LINEAS */
INSERT INTO LNS1 VALUES (1, 18, 1, 'C00005', 12, 820.3, 0, 820.3, 7, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (1, 18, 2, 'CM001', 22, 215.94, 20, 172.752, 0, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (1, 18, 3, 'I00002', 29, 464.74, 0, 464.74, 7, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (2, 18, 1, 'E00001', 27, 0.35, 0, 0.35, 0, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (2, 18, 2, 'C00014', 21, 806.44, 0, 806.44, 0, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (2, 18, 3, 'I00013', 40, 974.34, 15, 828.189, 7, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (2, 18, 4, 'LM4029PH', 46, 8.74, 0, 8.74, 7, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (3, 18, 1, 'CM001', 22, 535.36, 0, 535.36, 7, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (3, 18, 2, 'CM002', 23, 416.71, 0, 416.71, 0, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (3, 18, 3, 'I00012', 39, 956.02, 15, 812.617, 7, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (3, 18, 4, 'C00010', 17, 819.71, 0, 819.71, 7, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (4, 18, 1, 'CM001', 22, 269.51, 0, 269.51, 7, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (4, 18, 2, 'I00009', 36, 830.49, 0, 830.49, 0, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (4, 18, 3, 'CM006', 24, 200.52, 0, 200.52, 0, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (5, 18, 1, 'D00002', 26, 131.49, 0, 131.49, 0, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (5, 18, 2, 'C00013', 20, 794.09, 0, 794.09, 0, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (5, 18, 3, 'I00002', 29, 882.57, 0, 882.57, 0, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (6, 18, 1, 'I00010', 37, 164.9, 0, 164.9, 7, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (6, 18, 2, 'A00002', 2, 695.57, 0, 695.57, 7, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (7, 18, 1, 'I00011', 38, 715.31, 0, 715.31, 7, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (7, 18, 2, 'C00011', 18, 225.11, 0, 225.11, 7, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (7, 18, 3, 'LM4029', 41, 897, 10, 807.3, 7, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (7, 18, 4, 'D00001', 25, 575.2, 20, 460.16, 0, NULL, NULL, NULL);
INSERT INTO LNS1 VALUES (7, 18, 5, 'C00014', 21, 784.09, 0, 784.09, 7, NULL, NULL, NULL);

/* NOTA DE CREDITO DE COMPRAS */
/* CABECERA */
INSERT INTO DOCS VALUES (1, 19, 500001, '2024-02-11', '2024-02-11', 'P00005', 3);
INSERT INTO DOCS VALUES (2, 19, 500002, '2024-02-29', '2024-02-29', 'P00003', 1);
INSERT INTO DOCS VALUES (3, 19, 500003, '2023-03-01', '2023-03-01', 'P00005', 3);
INSERT INTO DOCS VALUES (4, 19, 500004, '2024-03-07', '2024-03-07', 'P00001', 2);
/* LINEAS */
INSERT INTO LNS1 VALUES (1, 19, 1, 'D00002', 26, 131.49, 0, 131.49, 0, 5, 18, 1);
INSERT INTO LNS1 VALUES (1, 19, 2, 'C00013', 5, 794.09, 0, 794.09, 0, 5, 18, 2);
INSERT INTO LNS1 VALUES (2, 19, 1, 'I00013', 10, 974.34, 15, 828.189, 7, 2, 18, 3);
INSERT INTO LNS1 VALUES (2, 19, 2, 'LM4029PH', 10, 8.74, 0, 8.74, 7, 2, 18, 4);
INSERT INTO LNS1 VALUES (3, 19, 1, 'C00013', 5, 794.09, 0, 794.09, 0, 5, 18, 2);
INSERT INTO LNS1 VALUES (4, 19, 1, 'I00011', 38, 715.31, 0, 715.31, 7, 7, 18, 1);
INSERT INTO LNS1 VALUES (4, 19, 2, 'D00001', 25, 575.2, 20, 460.16, 0, 7, 18, 4);
INSERT INTO LNS1 VALUES (4, 19, 3, 'C00014', 21, 784.09, 0, 784.09, 7, 7, 18, 5);
