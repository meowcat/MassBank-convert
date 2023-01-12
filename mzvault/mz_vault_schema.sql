
CREATE TABLE CompoundTable(
  [CompoundId] INTEGER PRIMARY KEY, 
  [Formula] TEXT, 
  [Name] TEXT, 
  [Synonyms] BLOB_TEXT, 
  [Tag] TEXT, 
  [Sequence] TEXT, 
  [CASId] TEXT, 
  [ChemSpiderId] TEXT,  
  [HMDBId] TEXT, 
  [KEGGId] TEXT, 
  [PubChemId] TEXT,  
  [Structure] BLOB_TEXT, 
  [mzCloudId] INTEGER, 
  [CompoundClass] TEXT, 
  [SmilesDescription] TEXT, 
  [InChiKey] TEXT
);

CREATE TABLE HeaderTable(
  version INTEGER NOT NULL DEFAULT 0, 
  [CreationDate] TEXT, 
  [LastModifiedDate] TEXT, 
  [Description] TEXT, 
  [Company] TEXT, 
  [ReadOnly] BOOL, 
  [UserAccess] TEXT,
  [PartialEdits] BOOL
);

CREATE TABLE MaintenanceTable(
  [CreationDate] TEXT, 
  [NoofCompoundsModified] INTEGER, 
  [Description] TEXT
);

CREATE TABLE SpectrumTable (
  [SpectrumId] INTEGER PRIMARY KEY, 
  [CompoundId] INTEGER REFERENCES [CompoundTable] ([CompoundId]), 
  [mzCloudURL] TEXT, 
  [ScanFilter] TEXT, 
  [RetentionTime] DOUBLE, 
  [ScanNumber] INTEGER, 
  [PrecursorMass] DOUBLE, 
  [NeutralMass] DOUBLE,
  [CollisionEnergy] TEXT, 
  [Polarity] TEXT, 
  [FragmentationMode] TEXT,
  [IonizationMode] TEXT, 
  [MassAnalyzer] TEXT, 
  [InstrumentName] TEXT, 
  [InstrumentOperator] TEXT, 
  [RawFileURL] TEXT, 
  [blobMass] BLOB, 
  [blobIntensity] BLOB, 
  [blobAccuracy] BLOB, 
  [blobResolution] BLOB, 
  [blobNoises] BLOB, 
  [blobFlags] BLOB, 
  [blobTopPeaks] BLOB, 
  [Version] INTEGER, 
  [CreationDate] TEXT, 
  [Curator] TEXT, 
  [CurationType], 
  [PrecursorIonType] TEXT, 
  [Accession] TEXT
);