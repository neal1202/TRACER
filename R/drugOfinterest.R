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
#' @import dplyr
drugOfInterest <- function(regimenConceptId){

  # loadHDAC
  HDAC <- loadHdac(regimenConceptId)

  # Subset drug of interest and label role of drug
  andromeda$drugOfInterest <- andromeda$drugRecordsInCohort %>% collect() %>%
    subset(ingredientConceptId %in% HDAC$drug$conceptId) %>% left_join(HDAC$drug,c('ingredientConceptId'= 'conceptId')) %>%
    mutate(minCombiDate = ifelse(role == 'index',
                                 drugExposureStartDate+HDAC$meta$combinationCriteriaMin,NA),
           maxCombiDate = ifelse(role == 'index',
                                 drugExposureStartDate+HDAC$meta$combinationCriteriaMax,NA)
    )
}
