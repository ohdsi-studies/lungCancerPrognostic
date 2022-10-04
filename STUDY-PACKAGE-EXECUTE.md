Instructions To Run Development Study
===================
- Execute the study by running this code:
```r
  library(lungCancerPrognostic)
  # USER INPUTS
#=======================
# The folder where the study intermediate and result files will be written:
outputFolder <- "C:/lungCancerPrognosticResults"


# Details for connecting to the server:
dbms <- "you dbms"
user <- 'your username'
pw <- 'your password'
server <- 'your server'
port <- 'your port'

connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port)

# Add the database containing the OMOP CDM data
cdmDatabaseSchema <- 'cdm database schema'
# Add a sharebale name for the database containing the OMOP CDM data
cdmDatabaseName <- 'a friendly shareable  name for your database'
# Add a database with read/write access as this is where the cohorts will be generated
cohortDatabaseSchema <- 'work database schema'

tempEmulationSchema <- NULL

cdmVersion <- 5

# table name where the cohorts will be generated
cohortTable <- 'LungCancerCohort'

# replace NULL with number to sample if needed
sampleSize <- NULL
#=======================

databaseDetails <- PatientLevelPrediction::createDatabaseDetails(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cdmDatabaseName = cdmDatabaseName,
  tempEmulationSchema = tempEmulationSchema,
  cohortDatabaseSchema = cohortDatabaseSchema,
  cohortTable = cohortTable,
  outcomeDatabaseSchema = cohortDatabaseSchema,
  outcomeTable = cohortTable,
  cdmVersion = cdmVersion
  )  
  
  logSettings <- PatientLevelPrediction::createLogSettings(
  verbosity = "INFO",
  timeStamp = T,
  logName = 'skeletonPlp'
  )                                          

 LungCancerPrognostic::developLungCancerEHRmodel(
         databaseDetails = databaseDetails,
         outputFolder = outputFolder, 
         createCohorts = T,
         runAnalyses = T,
         sampleSize = sampleSize,
         logSettings = logSettings
         )
```

The 'createCohorts' option will create the target and outcome cohorts into cohortDatabaseSchema.cohortTable if set to T.  The 'runAnalyses' option will create/extract the data for each prediction problem setting (each Analysis), develop a prediction model, internally validate it if set to T.  The results of each Analysis are saved in the 'outputFolder' directory under the subdirectories 'Analysis_1' to 'Analysis_N', where N is the total analyses specified.  


Instructions To Valdiate High Dimentional Lung Cancer Model on new OMOP CDM data
===================

```r
library(lungCancerPrognostic)
# USER INPUTS
#=======================
# The folder where the study intermediate and result files will be written:
outputFolder <- "C:/lungCancerPrognosticResults"


# Details for connecting to the server:
dbms <- "you dbms"
user <- 'your username'
pw <- 'your password'
server <- 'your server'
port <- 'your port'

connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = pw,
                                                                port = port)

# Add the database containing the OMOP CDM data
cdmDatabaseSchema <- 'cdm database schema'
# Add a sharebale name for the database containing the OMOP CDM data
cdmDatabaseName <- 'a friendly shareable  name for your database'
# Add a database with read/write access as this is where the cohorts will be generated
cohortDatabaseSchema <- 'work database schema'

tempEmulationSchema <- NULL

cdmVersion <- 5

# table name where the cohorts will be generated
cohortTable <- 'LungCancerCohort'


# replace NULL with number to sample if needed
sampleSize <- NULL
#=======================

databaseDetails <- PatientLevelPrediction::createDatabaseDetails(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cdmDatabaseName = cdmDatabaseName,
  tempEmulationSchema = tempEmulationSchema,
  cohortDatabaseSchema = cohortDatabaseSchema,
  cohortTable = cohortTable,
  outcomeDatabaseSchema = cohortDatabaseSchema,
  outcomeTable = cohortTable,
  cdmVersion = cdmVersion
  )  
  
  
  # first create the cohort if you have not already
   LungCancerPrognostic::developLungCancerEHRmodel(
         databaseDetails = databaseDetails,
         outputFolder = '.../lungTest', 
         createCohorts = T,
         runAnalyses = F
         )

# now validate the model using those cohorts
LungCancerPrognostic::validateLungCancerEHRmodel(
  databaseDetails = databaseDetails, 
  validationRestrictPlpDataSettings = PatientLevelPrediction::createRestrictPlpDataSettings(sampleSize = sampleSize),
  outputFolder =   '.../lungTest'
)

# load the result to see how the model did and view predictions
res <- PatientLevelPrediction::loadPlpResult('.../lungTest/test/Analysis_1/validationResult')
```

