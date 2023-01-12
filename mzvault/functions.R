# Convert MassBank to mzVault
# mzVault already does this, but doesn't do the nicer stuff such as 
# combining compounds by InChIKey or importing all the metadata.

library(RSQLite)
library(Spectra)
library(MsBackendMassbank)



open_database <- function(filename = ":memory:") {
  con <- dbConnect(RSQLite::SQLite(), filename)
  return(con)
}

create_database <- function(db) {
  schema <- read_file("mz_vault_schema.sql") %>%
    str_split_1(fixed(";")) %>%
    keep(~ str_detect(.x, "[A-Za-z0-9]"))
  dbBegin(db)
  walk(schema, ~ dbExecute(db, .x))
  dbCommit(db)
  return(invisible(db))
}

version_database <- function(db, version = 5, description = "") {
  # next_version <- 1
  # current_version <- dbGetQuery(
  #   db,
  #   "SELECT version FROM HeaderTable 
  #     ORDER BY version DESC
  #     LIMIT 1"
  # )
  # if(nrow(current_version) > 0)
  #   next_version <- current_version$version + 1
  
  dbExecute(
    db,
    "INSERT INTO HeaderTable (version, Description) VALUES (?, ?)",
    params = list(version, description))
  
  inserted_version <- dbGetQuery(
    db,
    "SELECT version FROM HeaderTable
      ORDER BY version DESC
      LIMIT 1"
  )
  return(inserted_version$version)
  
}


read_blob <- function(blob) {
  blob_con <- rawConnection(blob)
  data <- readBin(blob_con, "numeric", n = length(blob) / 4)
  close(blob_con)
  return(data)
}

write_blob <- function(data) {
  stopifnot(is.numeric(data))
  blob_con <- rawConnection(raw(0), "r+")
  writeBin(data, blob_con)
  blob <- rawConnectionValue(blob_con)
  close(blob_con)
  return(blob)
}
