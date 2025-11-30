# 📘 Data Warehouse Financiero (MRR, CAC, FCF)

Este proyecto implementa un **modelo dimensional** para analizar métricas financieras clave de Innova SaaS: **MRR**, **CAC**, **FCF** y ingresos por país.
Incluye documentación, arquitectura ETL, SQL de negocio y estructura dbt-like.

---

## 🚀 1. Objetivo del Proyecto
Construir un **Data Warehouse Financiero** que habilite:

- MRR 
- CAC considerando marketing + nómina.
- FCF a partir de ingresos cobrados y gastos reales.
- Dashboard ejecutivo para toma de decisiones.

---

## 2. Estructura del Repositorio

- **`dashboard/`**  
  Contiene las visualizaciones ejecutivas que responden al **Punto 4 del reto**, incluyendo análisis clave basados en MRR, CAC, FCF e ingresos por país.
  Para visualizar correctamente el tablero:
  - Abrir el archivo PBIX
  - Ir a: Transformar datos → Administrar parámetros
  - Cambiar el parámetro RepoPath a la ruta local donde está el repositorio
  - Cerrar y aplicar

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
 [Modelo Dimensional - Descripción y Justificación](docs/1.Modelo%20Dimensional-Descripción%20y%20Justificacion.pdf)
 [Modelo Dimensional - Diagramas](docs/1.Modelo%20Dimensional-Diagramas.pdf)

---

## 4. Arquitectura ETL

El ETL está estructurado en 4 capas:

1. **Landing / RAW**  
2. **Staging (STG)** — limpieza y normalización  
3. **Transform** — llaves, cálculos, SCD2  
4. **DWH** — carga de dimensiones y hechos  

Detalles completos en:  
[Arquitectura ETL](docs/2.Lógica%20ETL%20arquitectura.pdf)

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

---

## 6. Bonus: Automatización y Escalabilidad

### **Automatización**

- Automatizaria el proceso de ETL con la herramienta DBT dado que está integra todas las buenas practicas de la ingenieria de software a los scripts SQL, como lo son los testing,versionamiento y la documentación. Adicional que es cloud-agnostic y orchestrator-agnostic , por lo cual si hay un cambio de proveedor de servicios o se va a utilizar un multi-cloud para disponibilidad, la misma logica desarrollada funcionaria para los diferentes escenarios. 
Se incluye una carpeta con estructuacion de [proyecto dbt](dbt-project/). 

### **Escalabilidad**
- El modelo dimensional propuesto es altamente escalable. Siguiendo los principios de Kimball, las dimensiones son entidades independientes y extensibles, lo que permite incorporar nuevos miembros sin impactar las tablas de hechos. Por ejemplo, la dimensión de países (dim_country) ya está normalizada y preparada para recibir nuevos valores conforme la empresa opere en más regiones, sin requerir cambios estructurales. De igual forma, la incorporación de una dimensión adicional y pequeña, como dim_currency, se integraría naturalmente con las dimensiones y hechos existentes, manteniendo la coherencia del diseño y permitiendo análisis multi-moneda sin afectar el grano de las fact tables.

### **IA/ML**
  - La incorporación de IA o modelos de machine learning es especialmente valiosa para tareas de forecasting y análisis predictivo. Estos modelos pueden capturar patrones no lineales y relaciones complejas que los métodos tradicionales no logran identificar con precisión. Al contar con un historial de datos amplio y bien estructurado en el data warehouse, la empresa puede aprovechar esta base sólida para entrenar modelos más robustos, mejorar la precisión de sus proyecciones y tomar decisiones operativas y estratégicas más informadas.Sin embargo, no se recomienda aplicar modelos de ML para la clasificación de gastos, ya que este proceso ya está correctamente resuelto mediante las transformaciones y reglas de negocio implementadas en dbt y en las dimensiones correspondientes. Al tratarse de categorías bien definidas y determinísticas, un modelo de clasificación no aportaría valor adicional y solo aumentaría complejidad operativa sin justificación técnica.


