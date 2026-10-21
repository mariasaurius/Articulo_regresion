# Artículo de regresión: eficiencia hidráulica de turbinas de impulso

Proyecto del curso **Análisis de Regresión** (2026-2), Universidad Nacional de Colombia, sede Medellín.
Docente: Freddy Hernández Barajas.
Autora: María Paula Ardila Otero.

## Objetivo

Aplicar modelos de regresión a los datos experimentales de un artículo científico para explicar y predecir
la eficiencia hidráulica de turbinas de impulso a pequeña escala (pico hidro) en función de variables de
diseño de la boquilla y del rodete.

## Artículo de referencia

Lakdawala, H. N., Patel, V. K., Bakhru, G. P. y Modi, D. N. (2025). Performance optimization of low-head
vertical axis impulse turbine runners for nozzle angle, nozzle diameter, and nozzle standoff distance using
response surface methodology. *Journal of Thermal Engineering*, 11(5), 1392–1419.
https://doi.org/10.14744/thermal.0000983

## Datos

El archivo `datos.xlsx` contiene las 80 corridas experimentales de la Tabla 6 del artículo, obtenidas con un
diseño central compuesto (CCD) con cabeza hidráulica constante de 10 m.

| Variable     | Descripción                                          | Tipo        | Unidad / niveles      |
|--------------|------------------------------------------------------|-------------|-----------------------|
| `corrida`    | Número de la corrida experimental                    | Identificador | 1 a 80              |
| `angulo`     | Ángulo de la boquilla (incidencia del chorro)        | Numérica    | grados (90, 92.5, 95) |
| `diametro`   | Diámetro de la boquilla (chorro)                     | Numérica    | mm (10, 12, 14)       |
| `distancia`  | Distancia entre la punta de la boquilla y el rodete  | Numérica    | mm (40, 50, 60)       |
| `rodete`     | Tipo de rodete                                       | Categórica  | PTR = Pelton, TTR = Turgo |
| `boquillas`  | Número de boquillas                                  | Categórica  | 1 o 2                 |
| `eficiencia` | Eficiencia hidráulica (**variable respuesta**)       | Numérica    | proporción (0 a 1)    |

## Estructura del repositorio

```
Articulo_regresion/
├── README.md
└── datos.xlsx
```

## Fuente y licencia de los datos

Los datos provienen del artículo citado arriba, publicado en acceso abierto bajo licencia
CC BY-NC 4.0. Se usan aquí únicamente con fines académicos.
