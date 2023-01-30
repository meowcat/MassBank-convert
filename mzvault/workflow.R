library(Spectra)
library(MsBackendMassbank)
library(tidyverse)
library(glue)
library(yaml)


source("functions.R")

config_dir <- Sys.getenv("MZVGEN_CONFIG_DIR")
if(config_dir == "")
  config_dir <- getwd()

config <- read_yaml(
  fs::path(config_dir, "config.yaml")
)


con <- dbConnect(
  SQLite(),
  config$data_source
)

sp <- Spectra(
  con,
  source = MsBackendMassbankSql()
)


#sp <- sp[1:10]

sp_data_ <- spectraData(sp) %>% as_tibble() %>%
  mutate(mz = mz(sp) %>% as.list(), intensity = intensity(sp) %>% as.list())



cpds_ <- compounds(sp) %>% as_tibble()

# 
# 
# cpds <- cpds_ %>%
#   mutate(inchikey2d = str_sub(inchikey, 1, 14)) %>%
#   dplyr::group_by(inchikey2d) %>%
#   summarize(isomers = n_distinct(inchikey))

if(config$collapse_inchikey) {
  cpds_ <- cpds_ %>% 
    mutate(
      inchikey2d = str_sub(inchikey, 1, 14),
      inchikey_stereo = str_sub(inchikey, 16, 27),
      is_2d =  (inchikey_stereo == "UHFFFAOYSA-N")) %>%
    # Select one inchikey if there is only one non2d variant
    dplyr::group_by(inchikey2d) %>%
    mutate(
      n_inchikeys = n_distinct(inchikey), 
      has_2d = any(is_2d),
      n_non2d = n_inchikeys - has_2d
    ) %>%
    mutate(
      inchikey = if_else(
        n_non2d == 1,
        "{inchikey2d}-UHFFFAOYSA-N",
        inchikey
      )
    ) %>%
    ungroup()
}


cpds <- cpds_ %>%
  group_by(inchikey) %>%
  tidyr::fill(-inchikey, .direction = "downup") %>%
  slice(1) %>%
  ungroup() %>%
  mutate(compound_id = row_number())
# 
# cpds_with_structure <- 
#   cpds %>%
  

cpds_mzvault <- cpds %>%
  transmute(
    CompoundId = compound_id,
    Formula = formula,
    Name = name,
    CASId = cas,
    PubChemId = pubchem,
    SmilesDescription = smiles,
    InChiKey = inchikey
  ) %>%
  mutate(
    Synonyms = "",
    Tag = "",
    Sequence = "",
    ChemSpiderId = "",
    HMDBId = "",
    KEGGId = "",
    Structure = "",
    mzCloudId = 0,
    CompoundClass = ""
    )



sp_data <- sp_data_ %>%
  select(-compound_id) %>%
  left_join(cpds %>% select(inchikey, compound_id)) %>%
  mutate(
    spectrum_id_ = row_number()
  )

sp_data_filtered <- sp_data %>%
  filter(
    msLevel == 2,
    !is.na(precursorMz)
    )
  
sp_mzvault <- sp_data_filtered %>%
  replace_na(list(
    fragmentation_mode = "",
    ionization = "",
    collision_energy_text = ""
    
  )) %>%
  transmute(
    SpectrumId = spectrum_id_,
    CompoundId = compound_id,
    PrecursorMass = precursorMz,
    NeutralMass = exactmass,
    CollisionEnergy = collision_energy_text,
    Polarity = if_else(polarity == 0, "-", "+"),
    FragmentationMode = fragmentation_mode,
    IonizationMode = ionization,
    # MassAnalyzer = ,
    InstrumentName = instrument,
    blobMass = mz %>% map(write_blob) %>% blob::as_blob(),
    blobIntensity = intensity %>% map(write_blob) %>% blob::as_blob(),
    Accession = spectrum_id,
    PrecursorIonType = adduct,
    mzCloudURL = glue("{config$massbank_base}{spectrum_id}"),
  ) %>%
  mutate(
    ScanFilter = "",
    RetentionTime = 0,
    ScanNumber = 0L,
    MassAnalyzer = "",
    InstrumentOperator = "",
    RawFileURL = "",
    CreationDate = "",
    Curator = "",
    CurationType = "",
    blobAccuracy = raw(0) %>% blob::as_blob(),
    blobResolution = raw(0) %>% blob::as_blob(),
    blobFlags = raw(0) %>% blob::as_blob(),
    blobTopPeaks = raw(0) %>% blob::as_blob(),
  )


tryCatch(
  fs::file_create(config$file_out),
  error = function(e) NA
  )
fs::file_delete(config$file_out)
db <- open_database(config$file_out)
db %>% create_database()


version <- version_database(db)

dbWriteTable(db,
             "CompoundTable",
             cpds_mzvault,
             append = TRUE
             )

dbWriteTable(db,
             "SpectrumTable",
             sp_mzvault  %>% mutate(Version = version),
             append = TRUE)

dbDisconnect(db)

# mzv <- dbConnect(SQLite(), "C:/Daten/Spectral_Libraries/mzVault_libraries/fluoro.db")
# tb <- dbReadTable(mzv, "SpectrumTable")
