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

#' @export
loadDrugRecords <- function(connectionDetails,
                            andromeda,
                            cdmDatabaseSchema,
                            oncoVocaDatabaseSchema,
                            resultDatabaseSchema,
                            cohortTable,
                            outOfCohortPeriod,
                            includeDescendant,
                            targetCohortId
                            ){

  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename= "DrugExposureInCohort.sql",
                                           packageName = "TRACER",
                                           dbms = attr(connection,"dbms"),
                                           cdm_database_schema = cdmDatabaseSchema,
                                           onco_voca_database_schema = oncoVocaDatabaseSchema,
                                           result_database_schema = resultDatabaseSchema,
                                           cohort_table = cohortTable,
                                           out_of_cohort_period = outOfCohortPeriod,
                                           include_descendant = includeDescendant,
                                           target_cohort_id = targetCohortId
                                           )
  start <- Sys.time()
  if(packageVersion('DatabaseConnector') < 3)stop("TRACER needs DatabaseConnector version over 3.0.0")
  DatabaseConnector::querySqlToAndromeda(connection, sql,
                                         andromeda = andromeda,
                                         andromedaTableName = 'drugRecordsInCohort',
                                         snakeCaseToCamelCase = T)
  delta <- Sys.time() - start
  writeLines(paste("Loading drug records took", signif(delta,3), attr(delta, "units")))
  DatabaseConnector::disconnect(connection)

}


