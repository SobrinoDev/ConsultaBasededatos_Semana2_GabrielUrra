SELECT numfactura                                        "Nº Factura",
       TO_CHAR(fecha, 'DD "de" Month YYYY',
               'NLS_DATE_LANGUAGE = SPANISH')            "Fecha Emisión",
       LPAD(rutcliente, 10, '0')                         "RUT Cliente",
       TO_CHAR(neto, '$9G999G999')                       "Monto Neto",
       TO_CHAR(iva, '$9G999G999')                        "Monto Iva",
       TO_CHAR(total, '$9G999G999')                      "Total Factura",
       CASE
           WHEN total BETWEEN 0 AND 50000      THEN 'Bajo'
           WHEN total BETWEEN 50001 AND 100000 THEN 'Medio'
           ELSE 'Alto'
       END                                               "Categoría Monto",
       DECODE(codpago, 1, 'EFECTIVO',
                       2, 'TARJETA DEBITO',
                       3, 'TARJETA CREDITO',
                          'CHEQUE')                      "Forma de pago"
  FROM factura
 WHERE EXTRACT(YEAR FROM fecha) = EXTRACT(YEAR FROM SYSDATE) - 1
 ORDER BY fecha DESC, neto DESC;


SELECT LPAD(rutcliente, 12, '*')                         "RUT",
       INITCAP(nombre)                                   "Cliente",
       NVL(TO_CHAR(telefono), 'Sin teléfono')            "TELÉFONO",
       NVL(TO_CHAR(codcomuna), 'Sin comuna')             "COMUNA",
       estado                                            "ESTADO",
       CASE
           WHEN saldo / credito < 0.5 THEN
                'Bueno ( ' || TO_CHAR(credito - saldo, '$9G999G999') || ')'
           WHEN saldo / credito BETWEEN 0.5 AND 0.8 THEN
                'Regular ( ' || TO_CHAR(saldo, '$9G999G999') || ')'
           ELSE 'Crítico'
       END                                               "Estado Crédito",
       NVL(UPPER(SUBSTR(correo, INSTR(correo, '@') + 1)),
           'Correo no registrado')                       "Dominio Correo"
  FROM cliente
 WHERE estado = 'A'
   AND credito > 0
 ORDER BY nombre ASC;


SELECT codproducto                                       "ID",
       INITCAP(descripcion)                              "Descripción de Producto",
       NVL2(valorcompradolar,
            TO_CHAR(valorcompradolar) || ' USD',
            'Sin registro')                              "Compra en USD",
       NVL2(valorcompradolar,
            TO_CHAR(ROUND(valorcompradolar * &&TIPOCAMBIO_DOLAR), 'FM$999G999G999') || ' PESOS',
            'Sin registro')                              "USD convertido",
       NVL(TO_CHAR(totalstock), 'Sin datos')             "Stock",
       CASE
           WHEN totalstock IS NULL              THEN 'Sin datos'
           WHEN totalstock < &&UMBRAL_BAJO      THEN '¡ALERTA stock muy bajo!'
           WHEN totalstock BETWEEN &&UMBRAL_BAJO
                               AND &&UMBRAL_ALTO THEN '¡Reabastecer pronto!'
           ELSE 'OK'
       END                                               "Alerta Stock",
       CASE
           WHEN totalstock > 80 THEN TO_CHAR(ROUND(vunitario * 0.9), 'FM$999G999G999')
           ELSE 'N/A'
       END                                               "Precio Oferta"
  FROM producto
 WHERE UPPER(descripcion) LIKE '%ZAPATO%'
   AND UPPER(procedencia) = 'I'
 ORDER BY codproducto DESC;

UNDEFINE TIPOCAMBIO_DOLAR
UNDEFINE UMBRAL_BAJO
UNDEFINE UMBRAL_ALTO