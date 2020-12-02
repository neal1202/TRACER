-- Drug records for target cohort
WITH CTE AS (
	-- Descendant drug by ingredient drug
	SELECT ANCESTOR_CONCEPT_ID as INGREDIENT_CONCEPT_ID,DESCENDANT_CONCEPT_ID
	FROM @cdm_database_schema.concept_ancestor
	WHERE ancestor_concept_id in (
		SELECT CONCEPT_ID FROM @cdm_database_schema.CONCEPT
		WHERE CONCEPT_ID IN (
			SELECT concept_id_2 FROM @onco_voca_database_schema.CONCEPT_RELATIONSHIP
			WHERE relationship_id = 'Has antineopl Rx'
			)
		AND INVALID_REASON IS NULL
	)

	{@include_descendant}?{}:{-- Exclude descendant
	AND ANCESTOR_CONCEPT_ID = DESCENDANT_CONCEPT_ID}
),
CTE2 AS(
	SELECT * FROM @result_database_schema.@cohort_table c
	JOIN @cdm_database_schema.drug_exposure de
	ON c.subject_id = de.person_id
	AND c.COHORT_DEFINITION_ID = @target_cohort_id
	{@out_of_cohort_period}?{}:{
  -- Restrict in cohort period
	AND c.cohort_start_date <= de.drug_exposure_start_date
	AND c.cohort_end_date >= de.drug_exposure_end_date}
)
SELECT CTE2.drug_exposure_id, CTE.ingredient_concept_id, CTE2.subject_id, CTE2.drug_exposure_start_date, CTE2.drug_exposure_end_date FROM CTE
JOIN CTE2
ON CTE.descendant_concept_id = CTE2.drug_concept_id
