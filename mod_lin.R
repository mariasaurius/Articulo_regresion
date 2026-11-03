# =================================================================
# Réplica del modelo de superficie de respuesta del artículo
#
# Artículo: Lakdawala, Patel, Bakhru y Modi (2025). Performance
# optimization of low-head vertical axis impulse turbine runners for
# nozzle angle, nozzle diameter, and nozzle standoff distance using
# response surface methodology. Journal of Thermal Engineering,
# 11(5), 1392-1419.
#
# Respuesta:    eficiencia hidráulica de la turbina (proporción)
# Explicativas: angulo, diametro y distancia de la boquilla (numéricas),
#               rodete (Pelton/Turgo) y boquillas (1 o 2) (categóricas)
#
# Modelo: cuadrático de superficie de respuesta con 19 coeficientes,
# ajustado por los autores en Design Expert 13 con factores codificados
# y sumas de cuadrados tipo III.
#
# Qué se replica:
#   - Tabla 7 (ANOVA), Apéndices A2 y A3 (R², R² ajustado, R² predicho,
#     PRESS, desviación estándar, CV y precisión adecuada)
#   - Ecuaciones (6) a (9)
#   - Figura 9 (diagnósticos) y Figura 10 (superficies y contornos)
#   - Tabla 8 (punto óptimo reportado)
# =================================================================


# -----------------------------------------------------------------
# 0. Paquetes
# -----------------------------------------------------------------
# Se instalan solo los que falten, para que el script corra en
# cualquier computador
paquetes <- c("readxl", "ggplot2", "car")
faltantes <- paquetes[!paquetes %in% rownames(installed.packages())]
if (length(faltantes) > 0) install.packages(faltantes)

library(readxl)
library(ggplot2)
library(car)      # Anova() con sumas de cuadrados tipo III

theme_set(theme_bw())   # mismo estilo para todos los gráficos
set.seed(2026)          # por consistencia con anal_descrip.R

# Carpeta donde se guardan las figuras del artículo (Articulo_Revista/Figs).
# Funciona si se corre desde la carpeta del repositorio o desde la
# carpeta del proyecto de RStudio (Analisis_Regresion).
carpeta_figs <- if (dir.exists("Articulo_Revista")) {
  "Articulo_Revista/Figs"
} else {
  "Articulo_regresion/Articulo_Revista/Figs"
}
dir.create(carpeta_figs, recursive = TRUE, showWarnings = FALSE)

# guardar(): exporta un gráfico de ggplot2 a PDF en Articulo_Revista/Figs.
# Se le quitan el título y el subtítulo porque en LaTeX el título lo
# pone el \caption{} de la figura.
guardar <- function(grafico, nombre, ancho = 6, alto = 4.5) {
  ggsave(filename = file.path(carpeta_figs, paste0(nombre, ".pdf")),
         plot = grafico + labs(title = NULL, subtitle = NULL),
         width = ancho, height = alto)
}


# -----------------------------------------------------------------
# 1. Lectura de los datos desde el repositorio de GitHub
# -----------------------------------------------------------------
url <- "https://raw.githubusercontent.com/mariasaurius/Articulo_regresion/main/datos.xlsx"

# read_excel() no lee directamente desde internet: primero se descarga
# el archivo a una ruta temporal (mode = "wb" evita daños en Windows)
archivo <- tempfile(fileext = ".xlsx")
download.file(url, destfile = archivo, mode = "wb")
datos <- as.data.frame(read_excel(archivo))

# Variables categóricas como factores
datos$rodete    <- factor(datos$rodete, levels = c("PTR", "TTR"),
                          labels = c("Pelton", "Turgo"))
datos$boquillas <- factor(datos$boquillas, levels = c(1, 2),
                          labels = c("1 boquilla", "2 boquillas"))


# -----------------------------------------------------------------
# 2. Corrección de dos corridas de la Tabla 6
# -----------------------------------------------------------------
# En la Tabla 6 del artículo hay dos corridas con niveles mal digitados:
#   - Corrida 12: dice ángulo 90°, pero el valor predicho que reportan
#     los autores (0.6283) corresponde a ángulo 95°. Así aparece además
#     el punto 95° - 14 mm - 40 mm - Pelton - 1 boquilla, que faltaba.
#   - Corrida 15: dice distancia 40 mm, pero el valor predicho reportado
#     (0.6378) corresponde a distancia 60 mm. Así aparece el punto axial
#     92.5° - 12 mm - 60 mm - Turgo - 1 boquilla, que faltaba.
# Con estas dos correcciones el modelo reproduce exactamente la Tabla 7,
# las ecuaciones (6) a (9) y la columna "Pred." de la Tabla 6.
datos$angulo[datos$corrida == 12]    <- 95
datos$distancia[datos$corrida == 15] <- 60

# Comprobación: ahora cada punto factorial aparece una sola vez y solo
# el punto central (92.5°, 12 mm, 50 mm) tiene repeticiones
clave <- with(datos, paste(angulo, diametro, distancia, rodete, boquillas))
table(table(clave))   # 56 combinaciones únicas y 4 centros repetidos (6 veces)


# -----------------------------------------------------------------
# 3. Codificación de las variables numéricas en -1, 0 y 1
# -----------------------------------------------------------------
# Cada variable numérica tiene 3 niveles: bajo, medio y alto. Codificar
# es cambiarles la escala para que el bajo valga -1, el medio 0 y el
# alto 1:
#
#     x_codificada = (x - centro) / (mitad del rango)
#
#   ángulo:    (angulo    - 92.5) / 2.5   ->  90 = -1, 92.5 = 0, 95 = 1
#   diámetro:  (diametro  - 12)   / 2     ->  10 = -1, 12   = 0, 14 = 1
#   distancia: (distancia - 50)   / 10    ->  40 = -1, 50   = 0, 60 = 1
#
# ¿Para qué sirve?
#   - Las tres variables quedan en la misma escala, así que sus
#     coeficientes se pueden comparar directamente: el más grande en
#     valor absoluto es el que más mueve la eficiencia.
#   - El intercepto pasa a ser la eficiencia predicha en el centro del
#     diseño (92.5°, 12 mm, 50 mm), que sí tiene sentido físico.
#   - Es la escala en que Design Expert reporta las ecuaciones (6) a (9),
#     así que se necesita para poder compararlas.
# Los nombres A, B, C, D y E son los mismos de la Tabla 7.
datos$A <- (datos$angulo    - 92.5) / 2.5
datos$B <- (datos$diametro  - 12)   / 2
datos$C <- (datos$distancia - 50)   / 10
datos$D <- datos$rodete
datos$E <- datos$boquillas

table(datos$A)   # deben salir solo -1, 0 y 1
table(datos$B)
table(datos$C)


# -----------------------------------------------------------------
# 4. Codificación de las variables categóricas (contrastes de suma)
# -----------------------------------------------------------------
# Por defecto R usa un nivel de referencia: Pelton = 0 y Turgo = 1.
# Design Expert, en cambio, codifica los factores categóricos como
# +1 y -1 (contrastes de suma), igual que las variables numéricas.
# contr.sum(2) crea esa codificación: el primer nivel vale +1 y el
# segundo -1, de modo que el efecto se mide respecto al promedio de los
# dos niveles y no respecto a uno de ellos.
contrasts(datos$D) <- contr.sum(2)   # Pelton = +1, Turgo = -1
contrasts(datos$E) <- contr.sum(2)   # 1 boquilla = +1, 2 boquillas = -1
contrasts(datos$D)                   # para ver la codificación


# -----------------------------------------------------------------
# 5. Ajuste del modelo cuadrático
# -----------------------------------------------------------------
# Fórmula del modelo:
#   (A + B + C + D + E)^2  -> los 5 efectos principales y las 10
#                             interacciones dobles (AB, AC, ..., DE)
#   I(A^2) + I(B^2) + I(C^2) -> los cuadrados de las 3 numéricas.
#                             I() le dice a R que haga la operación
#                             aritmética A^2 tal cual (dentro de una
#                             fórmula, ^ significa otra cosa).
# En total: 1 intercepto + 5 + 10 + 3 = 19 coeficientes.
mod <- lm(eficiencia ~ (A + B + C + D + E)^2 + I(A^2) + I(B^2) + I(C^2),
          data = datos)

length(coef(mod))      # 19 coeficientes
summary(mod)           # coeficientes en unidades codificadas
round(coef(mod), 6)


# -----------------------------------------------------------------
# 6. ANOVA con sumas de cuadrados tipo III (Tabla 7)
# -----------------------------------------------------------------
# ¿Qué es la suma de cuadrados tipo III?
#   Para cada término se pregunta: si quito SOLO este término y dejo
#   todos los demás en el modelo, ¿cuánto aumenta la suma de cuadrados
#   del error? Ese aumento es su suma de cuadrados tipo III.
#   Es decir, cada término se evalúa "como si entrara de último".
#
# ¿Por qué la usa Design Expert?
#   La suma de cuadrados tipo I (la que da anova()) va agregando los
#   términos en orden, y el resultado cambia si se cambia el orden de
#   la fórmula. La tipo III no depende del orden: a cada término se le
#   descuenta lo que ya explican todos los otros. Por eso el artículo la
#   describe como "partial".
#
# Requisito: para que la tipo III tenga sentido con factores, estos
# deben tener contrastes de suma (sección 4).
#
# Como cada término tiene 1 grado de libertad, su F tipo III es igual
# al cuadrado de su estadístico t en summary(): F = t^2.
anova_t3 <- Anova(mod, type = 3)   # Anova() del paquete car
anova_t3

# Organización de la tabla en el mismo orden de la Tabla 7
orden <- c("A", "B", "C", "D", "E",
           "A:B", "A:C", "A:D", "A:E", "B:C", "B:D", "B:E",
           "C:D", "C:E", "D:E", "I(A^2)", "I(B^2)", "I(C^2)")
terminos <- anova_t3[orden, ]

# Fila "Model": la suma de cuadrados del modelo completo frente al
# modelo que solo tiene el intercepto
sc_total  <- sum((datos$eficiencia - mean(datos$eficiencia))^2)
sc_error  <- sum(residuals(mod)^2)
gl_error  <- df.residual(mod)                 # 80 - 19 = 61
cm_error  <- sc_error / gl_error              # cuadrado medio del error
sc_modelo <- sc_total - sc_error
gl_modelo <- length(coef(mod)) - 1            # 18
F_modelo  <- (sc_modelo / gl_modelo) / cm_error
p_modelo  <- pf(F_modelo, gl_modelo, gl_error, lower.tail = FALSE)


# -----------------------------------------------------------------
# 7. Prueba de falta de ajuste
# -----------------------------------------------------------------
# Idea: en el punto central hay corridas repetidas con las mismas
# condiciones. Sus diferencias no las puede explicar ningún modelo: son
# el "error puro" (ruido del experimento). Si el error del modelo es
# mucho más grande que ese error puro, el modelo no está capturando la
# forma de los datos (falta de ajuste).
#
# Para obtener el error puro se ajusta un modelo con una media distinta
# para cada combinación de condiciones (modelo de celdas): ese modelo
# solo deja como error la variación entre repeticiones.
mod_celdas <- lm(eficiencia ~ factor(clave), data = datos)

# anova(modelo_pequeño, modelo_grande) compara los dos modelos:
# la diferencia entre sus errores es la suma de cuadrados de falta de
# ajuste y el error del modelo de celdas es el error puro
falta_ajuste <- anova(mod, mod_celdas)
falta_ajuste

sc_pe  <- sum(residuals(mod_celdas)^2)   # error puro
gl_pe  <- df.residual(mod_celdas)        # 20
sc_lof <- sc_error - sc_pe               # falta de ajuste
gl_lof <- gl_error - gl_pe               # 41
F_lof  <- (sc_lof / gl_lof) / (sc_pe / gl_pe)
p_lof  <- pf(F_lof, gl_lof, gl_pe, lower.tail = FALSE)

# Tabla 7 completa
tabla7 <- data.frame(
  fuente = c("Modelo", orden, "Residual", "Falta de ajuste",
             "Error puro", "Total corregido"),
  SC = c(sc_modelo, terminos$`Sum Sq`, sc_error, sc_lof, sc_pe, sc_total),
  gl = c(gl_modelo, terminos$Df, gl_error, gl_lof, gl_pe, nrow(datos) - 1),
  F  = c(F_modelo, terminos$`F value`, NA, F_lof, NA, NA),
  p  = c(p_modelo, terminos$`Pr(>F)`, NA, p_lof, NA, NA)
)
tabla7$CM <- tabla7$SC / tabla7$gl
tabla7$CM[tabla7$fuente == "Total corregido"] <- NA
tabla7 <- tabla7[, c("fuente", "SC", "gl", "CM", "F", "p")]
print(format(tabla7, digits = 4), row.names = FALSE)
# Artículo: modelo F = 90.49, falta de ajuste F = 0.9733 (p = 0.5454)

# Términos significativos al 5 %
tabla7$fuente[tabla7$fuente %in% orden & tabla7$p < 0.05]
# Artículo: A, B, C, D, E, AB, AC, BC, BD, CD, A² y C²


# -----------------------------------------------------------------
# 8. Estadísticas del modelo (Apéndices A2 y A3)
# -----------------------------------------------------------------
n <- nrow(datos)
p <- length(coef(mod))
s <- sigma(mod)                  # desviación estándar del error

# hatvalues() da el "peso" h_ii de cada corrida en su propia predicción.
# Con él se obtiene el residual PRESS: el error que se cometería al
# predecir cada corrida con un modelo ajustado SIN esa corrida.
h     <- hatvalues(mod)
press <- sum((residuals(mod) / (1 - h))^2)

# Precisión adecuada (Design Expert): rango de las predicciones dividido
# entre su error estándar promedio, sqrt(p * s^2 / n). Mide la "señal"
# frente al "ruido"; se busca que sea mayor que 4.
prec_adec <- (max(fitted(mod)) - min(fitted(mod))) / sqrt(p * s^2 / n)

estadisticas <- c(
  desv_estandar  = s,
  media          = mean(datos$eficiencia),
  CV_pct         = 100 * s / mean(datos$eficiencia),
  R2             = summary(mod)$r.squared,
  R2_ajustado    = summary(mod)$adj.r.squared,
  R2_predicho    = 1 - press / sc_total,
  PRESS          = press,
  prec_adecuada  = prec_adec
)
round(estadisticas, 4)
# Artículo: 0.0053, 0.6540, 0.8090, 0.9639, 0.9532, 0.9375, 0.0030, 44.3384


# -----------------------------------------------------------------
# 9. Ecuaciones (6) a (9): una por rodete y número de boquillas
# -----------------------------------------------------------------
# Al fijar el rodete y las boquillas, el modelo queda como una ecuación
# solo en A, B y C. Las interacciones AB, AC, BC y los cuadrados son
# iguales en las 4 ecuaciones; lo que cambia es el intercepto y los
# coeficientes de A, B y C (por las interacciones con D y E).
#
# Para sacar los coeficientes de cada grupo se usa predict(), que
# evalúa el modelo en las condiciones que uno le dé:
#   intercepto = predicción en A = B = C = 0
#   coef. de A = (predicción en A = 1 - predicción en A = -1) / 2
#   (lo mismo para B y C)
grupos <- expand.grid(D = levels(datos$D), E = levels(datos$E))
# expand.grid() arma todas las combinaciones: Pelton-1, Turgo-1, ...

pred <- function(a, b, c, d, e) {
  predict(mod, newdata = data.frame(A = a, B = b, C = c,
                                    D = factor(d, levels(datos$D)),
                                    E = factor(e, levels(datos$E))))
}

ecuaciones <- do.call(rbind, lapply(seq_len(nrow(grupos)), function(i) {
  d <- as.character(grupos$D[i]); e <- as.character(grupos$E[i])
  data.frame(
    rodete     = d,
    boquillas  = e,
    intercepto = pred(0, 0, 0, d, e),
    A = (pred(1, 0, 0, d, e) - pred(-1, 0, 0, d, e)) / 2,
    B = (pred(0, 1, 0, d, e) - pred(0, -1, 0, d, e)) / 2,
    C = (pred(0, 0, 1, d, e) - pred(0, 0, -1, d, e)) / 2
  )
}))
ecuaciones[, 3:6] <- round(ecuaciones[, 3:6], 6)
rownames(ecuaciones) <- NULL
ecuaciones

# Términos comunes a las 4 ecuaciones
round(coef(mod)[c("A:B", "A:C", "B:C", "I(A^2)", "I(B^2)", "I(C^2)")], 6)

# Valores impresos en el artículo, para comparar
articulo <- data.frame(
  ecuacion   = c(6, 8, 7, 9),   # mismo orden que 'grupos'
  intercepto = c(0.626362, 0.646587, 0.648982, 0.668212),
  A          = c(-0.019550, -0.020450, -0.021950, -0.022850),
  B          = c(0.000375, -0.006575, 0.002475, -0.009425),
  C          = c(-0.008110, -0.013190, -0.007830, -0.012910)
)
cbind(ecuaciones[, 1:2], round(ecuaciones[, 3:6] - articulo[, 2:5], 6))
# Todas las diferencias son 0, excepto B en la ecuación (7): el artículo
# imprime +0.002475 y el modelo da -0.002475. Es un error de signo del
# artículo: como el modelo es aditivo, el coeficiente de Pelton con 2
# boquillas debe ser Pelton-1 + Turgo-2 - Turgo-1 = -0.002475.


# -----------------------------------------------------------------
# 10. Figura 9: gráficos de diagnóstico
# -----------------------------------------------------------------
# Residuales estudentizados:
#   - internamente (rstandard): residual / (s * sqrt(1 - h_ii)),
#     usando el s del modelo con todas las corridas
#   - externamente (rstudent): igual, pero con el s de un modelo que
#     deja por fuera esa corrida. Así una corrida atípica no "infla"
#     el s con el que se juzga a sí misma.
datos$ajustado <- fitted(mod)
datos$r_int    <- rstandard(mod)
datos$r_ext    <- rstudent(mod)

# Escala de colores por eficiencia, como en Design Expert
colores_ef <- scale_fill_gradientn(
  colours = c("#2C3E9F", "#35B6E6", "#4CBB47", "#E8E337", "#E2231A"),
  name = "Eficiencia")

# (a) Probabilidad normal de los residuales externamente estudentizados.
# Se ordenan los residuales y a cada uno se le asigna el cuantil normal
# que le correspondería si vinieran de una N(0, 1). Si los puntos caen
# cerca de una recta, la normalidad es razonable.
# ppoints() da las probabilidades (i - 0.5) / n para i = 1, ..., n
orden_r <- order(datos$r_ext)
normal  <- data.frame(residual   = datos$r_ext[orden_r],
                      cuantil    = qnorm(ppoints(n)),
                      eficiencia = datos$eficiencia[orden_r])
# Recta de referencia que pasa por los cuartiles (como qqline())
q_res <- quantile(normal$residual, c(0.25, 0.75))
q_nor <- qnorm(c(0.25, 0.75))
pendiente <- diff(q_nor) / diff(q_res)
intercep  <- q_nor[1] - pendiente * q_res[1]

probs <- c(1, 5, 10, 20, 30, 50, 70, 80, 90, 95, 99)
g9a <- ggplot(normal, aes(x = residual, y = cuantil)) +
  geom_abline(intercept = intercep, slope = pendiente, color = "red") +
  geom_point(aes(fill = eficiencia), shape = 22, size = 2.5) +
  scale_y_continuous(breaks = qnorm(probs / 100), labels = probs) +
  colores_ef +
  labs(title = "Probabilidad normal de los residuales",
       x = "Residuales externamente estudentizados",
       y = "Probabilidad normal (%)")
print(g9a)
guardar(g9a, "fig9a_normal_residuales")

# (b) Eficiencia predicha vs. observada. Si el modelo predice bien,
# los puntos quedan sobre la recta y = x.
g9b <- ggplot(datos, aes(x = eficiencia, y = ajustado)) +
  geom_abline(intercept = 0, slope = 1) +
  geom_point(aes(fill = eficiencia), shape = 22, size = 2.5) +
  colores_ef +
  coord_equal() +
  labs(title = "Eficiencia predicha vs. observada",
       x = "Eficiencia observada", y = "Eficiencia predicha")
print(g9b)
guardar(g9b, "fig9b_predicha_observada")

# (c) Residuales internamente estudentizados vs. número de corrida.
# Design Expert marca los límites +/- 3.
g9c <- ggplot(datos, aes(x = corrida, y = r_int)) +
  geom_hline(yintercept = c(-3, 3), color = "red") +
  geom_hline(yintercept = 0) +
  geom_line(color = "grey40") +
  geom_point(aes(fill = eficiencia), shape = 22, size = 2.5) +
  colores_ef +
  scale_x_continuous(breaks = seq(1, 79, by = 13)) +
  labs(title = "Residuales internamente estudentizados vs. corrida",
       x = "Número de corrida",
       y = "Residual internamente estudentizado")
print(g9c)
guardar(g9c, "fig9c_rint_corrida")

# (d) Residuales externamente estudentizados vs. número de corrida.
# El límite es un valor crítico t con corrección de Bonferroni: se
# reparte el 5 % entre las 80 corridas para no declarar atípicos "por
# azar". gl = n - p - 1 = 60. Da 3.61051, como en el artículo.
lim_t <- qt(1 - 0.05 / (2 * n), df = n - p - 1)
lim_t

g9d <- ggplot(datos, aes(x = corrida, y = r_ext)) +
  geom_hline(yintercept = c(-lim_t, lim_t), color = "red") +
  geom_hline(yintercept = 0) +
  geom_line(color = "grey40") +
  geom_point(aes(fill = eficiencia), shape = 22, size = 2.5) +
  colores_ef +
  scale_x_continuous(breaks = seq(1, 79, by = 13)) +
  scale_y_continuous(limits = c(-4, 4)) +
  labs(title = "Residuales externamente estudentizados vs. corrida",
       x = "Número de corrida",
       y = "Residual externamente estudentizado")
print(g9d)
guardar(g9d, "fig9d_rext_corrida")

# Ninguna corrida supera los límites
sum(abs(datos$r_ext) > lim_t)


# -----------------------------------------------------------------
# 11. Figura 10: superficies de respuesta y gráficos de contorno
# -----------------------------------------------------------------
# Como en el artículo: eficiencia en función del ángulo (A) y del
# diámetro (B), con la distancia fija en 50 mm (C = 0), para cada
# rodete y número de boquillas. Los ejes se muestran en unidades
# originales (grados y mm) para que se lean más fácil.
malla <- expand.grid(A = seq(-1, 1, length.out = 41),
                     B = seq(-1, 1, length.out = 41),
                     C = 0,
                     D = levels(datos$D),
                     E = levels(datos$E))
malla$D <- factor(malla$D, levels(datos$D))
malla$E <- factor(malla$E, levels(datos$E))
malla$eficiencia <- predict(mod, newdata = malla)
malla$angulo   <- 92.5 + 2.5 * malla$A    # de vuelta a grados
malla$diametro <- 12 + 2 * malla$B        # de vuelta a mm

# Rango común para que los 4 grupos se puedan comparar
rango_z <- c(0.60, 0.72)

# 11.1 Superficies 3D con persp() (R base).
# persp() necesita una matriz z con una fila por valor de x y una
# columna por valor de y. Los gráficos de R base no se guardan con
# ggsave(): se abre un archivo con pdf(), se dibuja y se cierra con
# dev.off().
superficie <- function(d, e, nombre) {
  sub <- subset(malla, D == d & E == e)
  x <- sort(unique(sub$angulo))
  y <- sort(unique(sub$diametro))
  z <- matrix(sub$eficiencia, nrow = length(x), ncol = length(y))
  # (expand.grid varía primero A, así que el orden de 'z' coincide)

  # Color de cada faceta según la altura promedio de sus 4 esquinas
  z_faceta <- (z[-1, -1] + z[-1, -ncol(z)] + z[-nrow(z), -1] +
                 z[-nrow(z), -ncol(z)]) / 4
  paleta <- colorRampPalette(c("#2C3E9F", "#35B6E6", "#4CBB47",
                               "#E8E337", "#E2231A"))(100)
  col_faceta <- paleta[cut(z_faceta, breaks = seq(rango_z[1], rango_z[2],
                                                  length.out = 101),
                           include.lowest = TRUE)]
  dibujar <- function() {
    persp(x, y, z,
          theta = 135, phi = 25,        # ángulos de la vista
          zlim = rango_z, col = col_faceta, border = "grey30",
          lwd = 0.3, ticktype = "detailed", nticks = 4,
          xlab = "Ángulo (°)", ylab = "Diámetro (mm)",
          zlab = "Eficiencia", cex.axis = 0.7, cex.lab = 0.9)
  }
  dibujar()                                     # en pantalla
  pdf(file.path(carpeta_figs, paste0(nombre, ".pdf")), width = 5, height = 5)
  dibujar()                                     # en el archivo
  invisible(dev.off())
}

superficie("Pelton", "1 boquilla",  "fig10a_superficie_pelton_1")
superficie("Turgo",  "1 boquilla",  "fig10b_superficie_turgo_1")
superficie("Pelton", "2 boquillas", "fig10c_superficie_pelton_2")
superficie("Turgo",  "2 boquillas", "fig10d_superficie_turgo_2")

# 11.2 Gráficos de contorno de los 4 grupos en una sola figura.
# geom_contour_filled() colorea las franjas de igual eficiencia y
# geom_contour() dibuja las líneas que las separan. Los puntos son las
# corridas del diseño con distancia de 50 mm.
puntos50 <- subset(datos, distancia == 50)

g10 <- ggplot(malla, aes(x = angulo, y = diametro, z = eficiencia)) +
  geom_contour_filled(breaks = seq(0.60, 0.72, by = 0.01)) +
  geom_contour(breaks = seq(0.60, 0.72, by = 0.01),
               color = "black", linewidth = 0.2) +
  geom_point(data = puntos50, aes(x = angulo, y = diametro),
             inherit.aes = FALSE, color = "red", size = 1.5) +
  facet_grid(E ~ D) +
  scale_fill_manual(values = colorRampPalette(
    c("#2C3E9F", "#35B6E6", "#4CBB47", "#E8E337", "#E2231A"))(12),
    drop = FALSE) +
  scale_x_continuous(breaks = c(90, 92.5, 95), expand = c(0, 0)) +
  scale_y_continuous(breaks = c(10, 12, 14), expand = c(0, 0)) +
  labs(title = "Contornos de la eficiencia predicha (distancia = 50 mm)",
       x = "Ángulo de la boquilla (°)", y = "Diámetro de la boquilla (mm)",
       fill = "Eficiencia")
print(g10)
guardar(g10, "fig10_contornos", ancho = 7.5, alto = 6)


# -----------------------------------------------------------------
# 12. Revisión del punto óptimo (Tabla 8)
# -----------------------------------------------------------------
# El artículo reporta como óptimo para el Turgo con 2 boquillas:
# 95°, 14 mm y 40 mm, con eficiencia predicha de 66.19 %.
optimo_art <- data.frame(A = 1, B = 1, C = -1,
                         D = factor("Turgo", levels(datos$D)),
                         E = factor("2 boquillas", levels(datos$E)))
predict(mod, newdata = optimo_art)   # 0.6619: coincide con la Tabla 8

# La corrida experimental en ese punto (la 53) dio 0.6655, que es el
# valor "experimental" que muestra la Tabla 8
subset(datos, angulo == 95 & diametro == 14 & distancia == 40 &
         rodete == "Turgo" & boquillas == "2 boquillas")[, c("corrida", "eficiencia")]

# Pero ese no es el máximo del modelo. Se evalúa el modelo en una malla
# fina dentro de la región del experimento (de -1 a 1 en A, B y C):
rejilla <- expand.grid(A = seq(-1, 1, by = 0.1),
                       B = seq(-1, 1, by = 0.1),
                       C = seq(-1, 1, by = 0.1),
                       D = levels(datos$D),
                       E = levels(datos$E))
rejilla$D <- factor(rejilla$D, levels(datos$D))
rejilla$E <- factor(rejilla$E, levels(datos$E))
rejilla$eficiencia <- predict(mod, newdata = rejilla)
rejilla$angulo    <- 92.5 + 2.5 * rejilla$A
rejilla$diametro  <- 12 + 2 * rejilla$B
rejilla$distancia <- 50 + 10 * rejilla$C

# Máximo dentro de cada combinación de rodete y boquillas
maximos <- do.call(rbind, lapply(split(rejilla, list(rejilla$D, rejilla$E)),
                                 function(g) g[which.max(g$eficiencia), ]))
maximos[, c("D", "E", "angulo", "diametro", "distancia", "eficiencia")]
# El máximo global es Turgo con 2 boquillas en 90°, unos 10.6 mm y
# 40 mm, con eficiencia predicha de 0.719. Entre los niveles que sí se
# probaron, el mejor es 90°, 10 mm y 40 mm (predicha 0.7187; la corrida
# 11, en ese punto, dio 0.7165). Coincide con lo que muestran las medias
# descriptivas: la eficiencia es más alta con ángulo de 90°.
# En los 4 grupos el máximo está en 90° y 40 mm, no en 95°.
subset(datos, corrida == 11)[, c("angulo", "diametro", "distancia",
                                 "rodete", "boquillas", "eficiencia")]
