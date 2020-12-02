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

#' @export loadHdac
loadHdac <- function(regimenConceptId){
  # load HDAC
  pathToHDAC <- system.file("json", "HDAC.json", package = "TRACER")
  HDAC <- rjson::fromJSON(file = pathToHDAC)

  targetRegimenHDAC <- HDAC[sapply(HDAC,`[`,"conceptId") == regimenConceptId][[1]]

  metaParam <- data.frame(targetRegimenHDAC[is.na(sapply(targetRegimenHDAC,`[`,"role"))])
  drugParam <- data.frame(
    data.table::rbindlist(
      lapply(
        1:length(targetRegimenHDAC[!is.na(sapply(targetRegimenHDAC,`[`,"role"))]),
        function(x){
          data.frame(targetRegimenHDAC[!is.na(sapply(targetRegimenHDAC,`[`,"role"))][[x]])
          }
        )
      )
    )

  # Numbering combination drug
  x = 1
  y = 1
  while(x <= nrow(drugParam)){
    if(drugParam[x,]$role == 'combination'){
    drugParam[x,]$role <- paste0('combination_',y)
    y <- y+1
  }
  x <- x+1
  }
  result <- list(meta=metaParam,drug=drugParam)
  class(result) <- c('HDAC')
  return(result)
}
