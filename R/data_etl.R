
# Pacotes -----------------------------------------------------------------

# Carregar pacotes
library(GetBCBData)
library(dplyr)
library(readr)
library(tidyr)


# Importar dados ----------------------------------------------------------

# Variáveis a serem importadas
vars_inflation <- c(
  "IPCA"    = 433,
  "IGP-M"   = 189,
  "IGP-DI"  = 190,
  "INPC"    = 188,
  "IPC-Br"  = 191
  )

# Importar dados
raw_data <- GetBCBData::gbcbd_get_series(
  id          = vars_inflation,
  first.date  = as.Date("2000-01-01"),
  format.data = "long",
  use.memoise = FALSE
  )

# Verificar se há variáveis faltando
if (dplyr::n_distinct(tbl_inflation2$variable) != length(vars_inflation)) {
  stop("Missing variables, please check ETL process.")
}


# Tratar dados ------------------------------------------------------------

tbl_inflation <- raw_data |>
  dplyr::as_tibble() |>
  dplyr::select(
    "date"     = "ref.date",
    "variable" = "series.name",
    "mom"      = "value"
    ) |>
  tidyr::drop_na()

# Verificar se há dados faltando
if (file.exists("data/tbl_inflation.rds")) {
  last_data <- readr::read_rds("data/tbl_inflation.rds")
  if (nrow(tbl_inflation) < nrow(last_data)) {
    stop("Missing data, please check ETL process.")
  }
}


# Salvar dados ------------------------------------------------------------

readr::write_rds(x = tbl_inflation, file = "data/tbl_inflation.rds")
