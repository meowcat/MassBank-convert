
create view msms_spectrum as select
      RECORD.ACCESSION as spectrum_id,
      RECORD.RECORD_TITLE as spectrum_name,
      RECORD.DATE as date,
      RECORD.AUTHORS as authors,
      RECORD.LICENSE as license,
      RECORD.COPYRIGHT as copyright,
      RECORD.PUBLICATION as publication,
      RECORD.AC_MASS_SPECTROMETRY_MS_TYPE as ms_level,
      RECORD.AC_MASS_SPECTROMETRY_ION_MODE as polarity,
      RECORD.PK_SPLASH as splash,
      RECORD.CH as compound_id,
      (select VALUE from MS_FOCUSED_ION where RECORD = RECORD.ACCESSION
      and SUBTAG = 'BASE_PEAK') as precursor_intensity,
      (select VALUE from MS_FOCUSED_ION where RECORD = RECORD.ACCESSION
      and SUBTAG = 'PRECURSOR_M/Z') as precursor_mz_text,
      (select VALUE from MS_FOCUSED_ION where RECORD = RECORD.ACCESSION
      and SUBTAG = 'PRECURSOR_TYPE') as adduct,
      (select VALUE from AC_MASS_SPECTROMETRY where RECORD = RECORD.ACCESSION
      and SUBTAG = 'IONIZATION') as ionization,
      (select VALUE from AC_MASS_SPECTROMETRY where RECORD = RECORD.ACCESSION
      and SUBTAG = 'IONIZATION_VOLTAGE') as ionization_voltage,
      (select VALUE from AC_MASS_SPECTROMETRY where RECORD = RECORD.ACCESSION
      and SUBTAG = 'FRAGMENTATION_MODE') as fragmentation_mode,
      (select VALUE from AC_MASS_SPECTROMETRY where RECORD = RECORD.ACCESSION
      and SUBTAG = 'COLLISION_ENERGY') as collision_energy_text,
      (select INSTRUMENT.AC_INSTRUMENT from INSTRUMENT where
      INSTRUMENT.ID = RECORD.AC_INSTRUMENT) as instrument,
      (select INSTRUMENT.AC_INSTRUMENT_TYPE from INSTRUMENT where
      INSTRUMENT.ID = RECORD.AC_INSTRUMENT) as instrument_type
from RECORD;

create view msms_spectrum_peak as select
      PEAK.RECORD as spectrum_id,
      PEAK.PK_PEAK_MZ as mz,
      PEAK.PK_PEAK_INTENSITY as intensity
from PEAK;

create view ms_compound as select
      COMPOUND.ID as compound_id,
      COMPOUND.CH_FORMULA as formula,
      COMPOUND.CH_EXACT_MASS as exactmass,
      COMPOUND.CH_SMILES as smiles,
      COMPOUND.CH_IUPAC as inchi,
      (select DATABASE_ID from CH_LINK where CH_LINK.COMPOUND = COMPOUND.ID
      and CH_LINK.DATABASE_NAME = 'INCHIKEY') as inchikey,
      (select DATABASE_ID from CH_LINK where CH_LINK.COMPOUND = COMPOUND.ID
      and CH_LINK.DATABASE_NAME = 'CAS') as cas,
      (select DATABASE_ID from CH_LINK where CH_LINK.COMPOUND = COMPOUND.ID
      and CH_LINK.DATABASE_NAME = 'PUBCHEM') as pubchem
from COMPOUND;

create view synonym as select
      COMPOUND_NAME.COMPOUND as compound_id,
      NAME.CH_NAME as synonym
from NAME join COMPOUND_NAME on (COMPOUND_NAME.NAME = NAME.ID);
