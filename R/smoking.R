createSmokingSettings <-function(
  startDay = -365,
  endDay = 0,
  analysisId = 639
  ){
  
  covariateSettings <- list(
    startDay = startDay,
    endDay = endDay,
    analysisId = analysisId
    )
  attr(covariateSettings, "fun") <- "getSmokingCovariateData"
  class(covariateSettings) <- "covariateSettings"
  return(covariateSettings)
  
}
  

getSmokingCovariateData <- function(connection,
  oracleTempSchema = NULL,
  cdmDatabaseSchema,
  cohortTable = "#cohort_person",
  cohortId = -1,
  cdmVersion = "5",
  rowIdField = "subject_id",
  covariateSettings,
  aggregated = FALSE
  ){
  
  
  if (aggregated)
    stop("Aggregation not supported")
  
  # Some SQL to construct the covariate:
  sql <-  "select @row_id_field, max(smoke_value)*1000+@analysis_id as covariate_id,
1 as covariate_value

from (
select p.@row_id_field, o.OBSERVATION_CONCEPT_ID,
  case 
     when VALUE_AS_STRING = 'Current smoker' then 3
     when VALUE_AS_STRING = 'Previously smoked' then 2 
     when VALUE_AS_STRING = 'Not currently smoking' then 2
     else  1 
  end as smoke_value
  from @cdm_database_schema.observation o inner join @cohort_table p
  on o.person_id = p.subject_id where 
  o.OBSERVATION_CONCEPT_ID = 40766362 and 
  o.OBSERVATION_DATE <= dateadd(day, @end_day, p.cohort_start_date)
  and o.OBSERVATION_DATE >= dateadd(day, @start_day, p.cohort_start_date)
  and o.VALUE_AS_STRING in ('Never smoked','Current smoker','Previously smoked','Not currently smoking')
  ) obs
  group by @row_id_field
  "
  sql <- SqlRender::render(sql,
    cohort_table = cohortTable,
    cohort_id = cohortId,
    row_id_field = rowIdField,
    cdm_database_schema = cdmDatabaseSchema,
    analysis_id = covariateSettings$analysisId,
    start_day = covariateSettings$startDay,
    end_day = covariateSettings$endDay
    )
  sql <- SqlRender::translate(sql, targetDialect = attr(connection, "dbms"))
  
  # Retrieve the covariate:
  covariates <- DatabaseConnector::querySql(connection, sql, snakeCaseToCamelCase = TRUE)
  
  # Construct covariate reference:
  covariateRef <-  data.frame(
    covariateId = (1:3)*1000+covariateSettings$analysisId,
    covariateName = c('never-smoker', 'previous_smoker' ,'Smoker'),
    analysisId = rep(covariateSettings$analysisId,3),
    conceptId = rep(0,3)
  )
  
  # Construct analysis reference:
  analysisRef <- data.frame(
    analysisId = covariateSettings$analysisId,
    analysisName = "Smoking status",
    domainId = "Smoking",
    startDay = covariateSettings$startDay,
    endDay = covariateSettings$endDay,
    isBinary = "Y",
    missingMeansZero = "Y"
    )
  
  # Construct analysis reference:
  metaData <- list(sql = sql, call = match.call())
  result <- Andromeda::andromeda(
    covariates = covariates, 
    covariateRef = covariateRef, 
    analysisRef = analysisRef
    )
  attr(result, "metaData") <- metaData
  class(result) <- "CovariateData"
  return(result)
  
}