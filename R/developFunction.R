# Copyright 2020 Observational Health Data Sciences and Informatics
#
# This file is part of LungCancerPoster
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#' Develop the model
#'
#' @details
#' This function executes the LungCancerPrognsotic model development.
#' 
#' @param databaseDetails      Database details created using \code{PatientLevelPrediction::createDatabaseDetails()} 
#' @param outputFolder         Name of local folder to place results; make sure to use forward slashes
#'                             (/). Do not use a folder on a network drive since this greatly impacts
#'                             performance.
#' @param createCohorts        Create the cohortTable table with the target population and outcome cohorts?
#' @param runAnalyses          Run the model development
#' @param sampleSize           The number of patients in the target cohort to sample (if NULL uses all patients)
#' @param logSettings           The log setting \code{PatientLevelPrediction::createLogSettings()}                            
#'
#' @examples
#' \dontrun{
#' connectionDetails <- createConnectionDetails(dbms = "postgresql",
#'                                              user = "joe",
#'                                              password = "secret",
#'                                              server = "myserver")
#'                                              
#'  databaseDetails <- PatientLevelPrediction::createDatabaseDetails(
#'  connectionDetails = connectionDetails,
#'  cdmDatabaseSchema = cdmDatabaseSchema,
#'  cdmDatabaseName = cdmDatabaseName,
#'  tempEmulationSchema = tempEmulationSchema,
#'  cohortDatabaseSchema = cohortDatabaseSchema,
#'  cohortTable = cohortTable,
#'  outcomeDatabaseSchema = cohortDatabaseSchema,
#'  outcomeTable = cohortTable,
#'  cdmVersion = cdmVersion
#'  )  
#'  
#'  logSettings <- PatientLevelPrediction::createLogSettings(
#'  verbosity = "INFO",
#'  timeStamp = T,
#'  logName = 'skeletonPlp'
#'  )                                          
#'
#' developLungCancerEHRmodel(
#' databaseDetails = databaseDetails,
#'         outputFolder = "c:/temp/study_results", 
#'         createCohorts = T,
#'         runAnalyses = T,
#'         logSettings = logSettings
#'         )
#' }
#'
#' @export
developLungCancerEHRmodel <- function(
  databaseDetails,
  outputFolder,
  createCohorts = F,
  runAnalyses = F,
  sampleSize = NULL,
  logSettings
) {
  
  if (!file.exists(outputFolder)){
    dir.create(outputFolder, recursive = TRUE)
  }
  
  ParallelLogger::addDefaultFileLogger(file.path(outputFolder, "log.txt"))

  if (createCohorts) {
    ParallelLogger::logInfo("Creating cohorts")
    createCohorts(
      databaseDetails = databaseDetails,
      outputFolder = outputFolder
    )
  }
  
  if(runAnalyses ){
      ParallelLogger::logInfo("Running predictions")
  
   # model design setting
    modelDesign <- PatientLevelPrediction::createModelDesign(
      targetId = 301, 
      outcomeId = 298, 
      restrictPlpDataSettings = PatientLevelPrediction::createRestrictPlpDataSettings(
        sampleSize = sampleSize
      ), 
      covariateSettings = list(
        LungCancerPrognostic::createSmokingSettings(
          startDay = -365,
          endDay = 0, 
          analysisId = 639
        ), 
        FeatureExtraction::createCovariateSettings(
          useDemographicsGender = T, 
          useDemographicsAgeGroup = T, 
          useDemographicsRace = T, 
          useDemographicsEthnicity = T, 
          useConditionGroupEraLongTerm = T, 
          useDrugGroupEraLongTerm = T, 
          useProcedureOccurrenceLongTerm = T, 
          useObservationLongTerm = T, 
          useDeviceExposureLongTerm = T, 
          useMeasurementLongTerm = T, 
          useVisitConceptCountLongTerm = T, 
          longTermStartDays = -365, 
          endDays = 0
        )
        
      ), 
      populationSettings = PatientLevelPrediction::createStudyPopulationSettings(
        includeAllOutcomes = T, 
        firstExposureOnly = T, 
        washoutPeriod = 365, 
        removeSubjectsWithPriorOutcome = T, 
        priorOutcomeLookback = 999999, 
        requireTimeAtRisk = F, 
        riskWindowStart = 1, 
        riskWindowEnd = 1095), 
      sampleSettings = PatientLevelPrediction::createSampleSettings(), 
      preprocessSettings = PatientLevelPrediction::createPreprocessSettings(
        minFraction = 0.00001, 
        normalize = T, 
        removeRedundancy = T
      ), 
      modelSettings = PatientLevelPrediction::setLassoLogisticRegression(
        variance = 0.01, 
        seed = 10155538
      ), 
      splitSettings = PatientLevelPrediction::createDefaultSplitSetting(
        testFraction = 0.25, 
        trainFraction = 0.75, 
        splitSeed = 34594, 
        nfold = 3, 
        type = "stratified"
      ), 
      runCovariateSummary = T
    )
  
    result <- do.call(
      PatientLevelPrediction::runMultiplePlp, 
      
      list(
        databaseDetails = databaseDetails,
        modelDesignList = list(modelDesign),
        onlyFetchData =  F,
        cohortDefinitions = data.frame(
          cohortName = unlist(lapply(
            1:length(predictionAnalysisList$cohortDefinitions), 
            function(i){predictionAnalysisList$cohortDefinitions[[i]]$name}
          )), 
          cohortId = unlist(lapply(
            1:length(predictionAnalysisList$cohortDefinitions), 
            function(i){predictionAnalysisList$cohortDefinitions[[i]]$id}
          )), 
          json = unlist(lapply(
            1:length(predictionAnalysisList$cohortDefinitions), 
            function(i){ParallelLogger::convertSettingsToJson(predictionAnalysisList$cohortDefinitions[[i]])}
          )) 
                                     
          ),
        logSettings = logSettings,
        saveDirectory = outputFolder
      )
    )
  }
  
  invisible(NULL)
}




getNames <- function(
  cohortDefinitions, 
  ids
){
  
  idNames <- lapply(cohortDefinitions, function(x) c(x$id, x$name))
  idNames <- do.call(rbind, idNames)
  colnames(idNames) <- c('id', 'name')
  idNames <- as.data.frame(idNames)
  
  nams <- c()
  for(id in ids){
    nams <- c(nams, idNames$name[idNames$id == id])
  }
  
  return(nams)
  
}

