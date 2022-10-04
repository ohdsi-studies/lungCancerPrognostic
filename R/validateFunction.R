#' Apply the model to new OMOP CDM data and get external performance
#'
#' @details
#' This will apply the model to new data and estimate the performance
#'
#' @param databaseDetails      The databaseDetails
#' @param validationRestrictPlpDataSettings  Whether to sample from the target population
#' @param settings             Whether to recalibrate
#' @param outputFolder         Name of local folder to place results; make sure to use forward slashes
#'                             (/)                         
#'
#' @export
validateLungCancerEHRmodel <- function(
  databaseDetails,
  validationRestrictPlpDataSettings,
  settings = PatientLevelPrediction::createValidationSettings(recalibrate = "weakRecalibration"),
  outputFolder
){


modelLoc <- system.file('models', 'full_model', package = 'LungCancerPrognostic')
#plpModel <- PatientLevelPrediction::loadPlpModel('/Users/jreps/Documents/github/lungCancerPrognostic/inst/models/full_model')
plpModel <- PatientLevelPrediction::loadPlpModel(modelLoc)

PatientLevelPrediction::externalValidateDbPlp(
  plpModel = plpModel, 
  validationDatabaseDetails = databaseDetails, 
  validationRestrictPlpDataSettings = validationRestrictPlpDataSettings, 
  settings = settings,
  outputFolder =   outputFolder
)

}



