# Copyright 2020 Observational Health Data Sciences and Informatics
#
# This file is part of TRACER
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

#' @param connectionDetails
#' @param oracleTempSchema
#' @param cohortDatabaseSchema
#' @param cohortTable
#' @param oracleTempSchema = NULL
#' @param cohortDatabaseSchema = cdmDatabaseSchema
#' @param cohortTable
#' @param includeConceptIdSetDescendant = TRUE

#' @export
createCohortTable <- function(connectionDetails,
                              oracleTempSchema = NULL,
                              cohortDatabaseSchema,
                              cohortTable){

  ParallelLogger::logInfo("Create table for the cohorts")
  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename= "CohortCreation.sql",
                                           packageName = "TRACER",
                                           dbms = attr(connection,"dbms"),
                                           oracleTempSchema = oracleTempSchema,
                                           cohort_database_schema = cohortDatabaseSchema,
                                           cohort_table = cohortTable)
  DatabaseConnector::executeSql(connection, sql, progressBar = TRUE, reportOverallTime = TRUE)

  DatabaseConnector::disconnect(connection)

}


#' @export
cohortGeneration <- function(connectionDetails,
                             oracleTempSchema = NULL,
                             cdmDatabaseSchema,
                             cohortDatabaseSchema = cdmDatabaseSchema,
                             cohortTable,
                             includeConceptIdSetDescendant = TRUE){

  ParallelLogger::logInfo("Insert cohort of interest into the cohort table")
  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  pathToCsv <- system.file("csv", "CohortsToCreate.csv", package = "TRACER")
  cohortInfo <- read.csv(pathToCsv, header = TRUE, stringsAsFactors = F)

  for (i in 1:nrow(cohortInfo)){
    conceptIdSet <- paste(strsplit(as.character(cohortInfo$conceptIds),';')[[i]],collapse = ',')
    cohortId <- cohortInfo$cohortDefinitionId[i]
    sql <- SqlRender::loadRenderTranslateSql(sqlFilename= "CohortGeneration.sql",
                                             packageName = "TRACER",
                                             dbms = attr(connection,"dbms"),
                                             oracleTempSchema = oracleTempSchema,
                                             cdm_database_schema = cdmDatabaseSchema,
                                             vocabulary_database_schema = cdmDatabaseSchema,
                                             target_database_schema = cohortDatabaseSchema,
                                             target_cohort_table = cohortTable,
                                             include_descendant = includeConceptIdSetDescendant,
                                             condition_concept_ids = conceptIdSet,
                                             target_cohort_id = cohortId)
    DatabaseConnector::executeSql(connection, sql, progressBar = TRUE, reportOverallTime = TRUE)
  }

  DatabaseConnector::disconnect(connection)
}
