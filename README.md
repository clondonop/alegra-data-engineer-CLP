# 📘 Data Warehouse Financiero (MRR, CAC, FCF)

Este proyecto implementa un **modelo dimensional** para analizar métricas financieras clave de Innova SaaS: **MRR**, **CAC**, **FCF**, churn, ingresos por país y desempeño por producto.  
Incluye documentación, arquitectura ETL, SQL de negocio y estructura dbt-like.

---

## 🚀 1. Objetivo del Proyecto
Construir un **Data Warehouse Financiero** que habilite:

- MRR mensual y churn.
- CAC considerando marketing + nómina.
- FCF a partir de ingresos cobrados y gastos reales.
- Ingresos por país, canal, cohorte y producto.
- Dashboard ejecutivo para toma de decisiones.

---

## 2. Estructura del Repositorio

- **`dashboard/`**  
  Contiene las visualizaciones ejecutivas que responden al **Punto 4 del reto**, incluyendo análisis clave basados en MRR, CAC, FCF e ingresos por país.

- **`dbt-project/`**  
  Incluye el proyecto automatizado utilizando **dbt**, cumpliendo con el **Punto 5.a del reto**, donde se propone la automatización del flujo de datos y la escalabilidad del modelo.

- **`docs/`**  
  Contiene los documentos que responden a los **Puntos 1 y 2 del reto**, incluyendo:
  - Modelo dimensional  
  - Diagramas  
  - Justificación del diseño  
  - Arquitectura lógica y ETL  

- **`etl-logic/`**  
  Incluye la lógica completa del proceso ETL desde las fuentes raw hasta el modelo analítico, cumpliendo con el **Punto 2 del reto**.

- **`finance-queries/`**  
  Carpeta con las consultas SQL que responden al **Punto 3 del reto**, demostrando cómo el modelo soporta métricas financieras como MRR, CAC, FCF y análisis por país.

---

##  3. Modelo Dimensional

El modelo sigue la metodología de **Kimball** y utiliza **SCD Tipo 2** para Customer y Subscription, permitiendo análisis históricos detallados.

### **Dimensiones**
- 'dim_customer' (SCD2)  
- 'dim_subscription' (SCD2)  
- 'dim_product'  
- 'dim_country'  
- 'dim_acquisition_channel'  
- 'dim_employee'  
- 'dim_provider'  
- 'dim_expense_category'  
- 'dim_payment_method'  
- 'dim_date'  

### **Hechos**
- 'fact_subscription_mrr'  
- 'fact_customer_acquisition'  
- 'fact_sales'  
- 'fact_payments'  
- 'fact_expenses'  
- 'fact_employee_cost'  

Documentación en:  
 [Modelo Dimensional - PDF](docs/1.Modelo Dimensional-Descripción y Justificacion.pdf)
 [Diagrama del Modelo](docs/1.Modelo Dimensional-Diagramas.pdf)

---

## 4. Arquitectura ETL

El ETL está estructurado en 4 capas:

1. **Landing / RAW**  
2. **Staging (STG)** — limpieza y normalización  
3. **Transform** — llaves, cálculos, SCD2  
4. **DWH** — carga de dimensiones y hechos  

Detalles completos en:  
[Arquitectura ETL](docs/2.Lógica ETL arquitectura.pdf)

---

##  5. Consultas SQL de Negocio

[Carpeta de Queries](finance-queries/)

### Preguntas resueltas:
- **MRR total — agosto 2024** → 'mrr_august_2024.sql'  
- **Nuevos clientes — Q1 2024** → 'new_clients_q1_2024.sql'  
- **Gastos de marketing — H1 2024** → 'expenses_marketing_s1_2024.sql'  
- **Free Cash Flow — diciembre 2024** → 'fcf_dec_2024.sql'  
- **País con mayor revenue — 2024** → 'most_total_revenue_x_country.sql'  
- **CAC anual promedio** → 'avg_cac_anual.sql'  

Cada consulta demuestra que el modelo soporta métricas del negocio complejas con SQL claro y eficiente.

---

## 6. Bonus: Automatización y Escalabilidad

### **Automatización**
- dbt (incremental models)  

### **Escalabilidad**
- Nuevos países → 'dim_country' ya soporta expansión  
- Nuevas monedas → agregar 'dim_currency'  

### **ML / IA (opcional)**
- Clasificación automática de gastos  
- Forecast financiero (MRR, churn, FCF)


##  7. Ejecución del Proyecto

1. Poblar tablas 'stg_*'  
2. Ejecutar ETL de dimensiones  
3. Ejecutar ETL de hechos  
4. Validar resultados con las queries del folder 'finance_queries/'  



