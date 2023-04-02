Lung Cancer Prognostic
=============

<img src="https://img.shields.io/badge/Study%20Status-Results%20Available-yellow.svg" alt="Study Status: Results Available">

- Analytics use case(s): **Patient-Level Prediction**
- Study type: **Clinical Application**
- Tags: **PatientLevelPrediction**
- Study lead: **Urmila Chandran, Jenna Reps**
- Study lead forums tag: **[jreps](https://forums.ohdsi.org/u/jreps)**
- Study start date: **2020**
- Study end date: **Aug 2022**
- Protocol: **-**
- Publications: **-**
- Results explorer: **-**

A patient-level prediction model developed to predict the risk of new lung cancer within 3 years of a visit where the patient is cancer free.

Suggested Requirements
===================
- R studio (https://rstudio.com)
- Java runtime environment
- Python

## Code to Install

To install Strategus run :

```r
  # install the network package
  # install.packages('remotes')
  remotes::install_github("OHDSI/Strategus")
```

Instructions To Run Strategus for model development:
===================

```r
  library(Strategus)

##=========== START OF INPUTS ==========
# Add your json file location, connection to OMOP CDM data settings and 

# load the json spec
url <- "https://raw.githubusercontent.com/ohdsi-studies/lungCancerPrognostic/develop/inst/model_development.json"
json <- readLines(file(url))
json2 <- paste(json, collaplse = '\n')
analysisSpecifications <- ParallelLogger::convertJsonToSettings(json2)

connectionDetailsReference <- "<database ref>"

connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = '<dbms>',
  server ='<server>',
  user = '<user>',
  password = '<password>',
  port = '<port>'
)

workDatabaseSchema <- '<your workDatabaseSchema>'
cdmDatabaseSchema <- '<your cdmDatabaseSchema>'

outputLocation <- '<folder location to run study and output results?'
minCellCount <- 5
cohortTableName <- "lung_cancer_develop"

##=========== END OF INPUTS ==========

storeConnectionDetails(
  connectionDetails = connectionDetails,
  connectionDetailsReference = connectionDetailsReference
  )

executionSettings <- createCdmExecutionSettings(
  connectionDetailsReference = connectionDetailsReference,
  workDatabaseSchema = workDatabaseSchema,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cohortTableNames = CohortGenerator::getCohortTableNames(cohortTable = cohortTableName),
  workFolder = file.path(outputLocation, "strategusWork"),
  resultsFolder = file.path(outputLocation, "strategusOutput"),
  minCellCount = minCellCount
)

# Note: this environmental variable should be set once for each compute node
Sys.setenv("INSTANTIATED_MODULES_FOLDER" = file.path(outputLocation, "StrategusInstantiatedModules"))

execute(
  analysisSpecifications = analysisSpecifications,
  executionSettings = executionSettings,
  executionScriptFolder = file.path(outputLocation, "strategusExecution")
  )
```


Instructions To Run Strategus for model validation:
===================

```r
  library(Strategus)

##=========== START OF INPUTS ==========
# Add your json file location, connection to OMOP CDM data settings and 

# load the json spec
url <- "https://raw.githubusercontent.com/ohdsi-studies/lungCancerPrognostic/develop/inst/model_validation.json"
json <- readLines(file(url))
json2 <- paste(json, collaplse = '\n')
analysisSpecifications <- ParallelLogger::convertJsonToSettings(json2)

connectionDetailsReference <- "<database ref>"

connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = '<dbms>',
  server ='<server>',
  user = '<user>',
  password = '<password>',
  port = '<port>'
)

workDatabaseSchema <- '<your workDatabaseSchema>'
cdmDatabaseSchema <- '<your cdmDatabaseSchema>'

outputLocation <- '<folder location to run study and output results?'
minCellCount <- 5
cohortTableName <- "lung_cancer_val"

##=========== END OF INPUTS ==========

storeConnectionDetails(
  connectionDetails = connectionDetails,
  connectionDetailsReference = connectionDetailsReference
  )

executionSettings <- createCdmExecutionSettings(
  connectionDetailsReference = connectionDetailsReference,
  workDatabaseSchema = workDatabaseSchema,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cohortTableNames = CohortGenerator::getCohortTableNames(cohortTable = cohortTableName),
  workFolder = file.path(outputLocation, "strategusWork"),
  resultsFolder = file.path(outputLocation, "strategusOutput"),
  minCellCount = minCellCount
)

# Note: this environmental variable should be set once for each compute node
Sys.setenv("INSTANTIATED_MODULES_FOLDER" = file.path(outputLocation, "StrategusInstantiatedModules"))

execute(
  analysisSpecifications = analysisSpecifications,
  executionSettings = executionSettings,
  executionScriptFolder = file.path(outputLocation, "strategusExecution")
  )
```

Results
========================================================
Once executed you will find multiple csv files in the specified outputFolder.
