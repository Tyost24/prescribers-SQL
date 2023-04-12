Select *
From prescriber

Select *
from prescription

Select *
From cbsa

Select *
from drug

Select *
From fips_county

Select *
from overdoses

Select *
From population

Select *
from zip_fips

-- 1a a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims. b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.
--Answer: Npi: 1881634483 with 99707 claims **Edit after walkthrough

Select p1.npi, sum(total_claim_count) as total_claim_count
From prescription as p1
Left Join prescriber as p2
on p1.npi = p2.npi
Group by p1.npi
Order by total_claim_count DESC

--1b Bruce Pendley, Family Practice 99707 claims **edit after walkthrough

Select p1.npi, sum(total_claim_count) as total_claim_count, p2.nppes_provider_first_name, p2.nppes_provider_last_org_name, p2.specialty_description
From prescription as p1
Inner Join prescriber as p2
on p1.npi = p2.npi
Group by p1.npi, p2.nppes_provider_first_name, p2.nppes_provider_last_org_name, p2.specialty_description
Order by total_claim_count DESC


--2a Which specialty had the most total number of claims (totaled over all drugs)?
-- There 9752347 total claims by Family Practice


Select sum(total_claim_count) as total_claim, p2.specialty_description
from prescription as p1
Left Join prescriber as p2
on p1.npi = p2.npi
group by p2.specialty_description
order by total_claim DESC;


--2b. Which specialty had the most total number of claims for opioids?
--Nurse Practitioner has the most opiods with 900845 claims.

Select sum(total_claim_count) as total_claim, p2.specialty_description
from prescription as p1
Left Join prescriber as p2
on p1.npi = p2.npi
Left Join drug as d
on p1.drug_name = d.drug_name
where d.opioid_drug_flag = 'Y'
group by p2.specialty_description
order by total_claim DESC;


--3a.Which drug (generic_name) had the highest total drug cost?
-- Insulin Glargine,Hum.Rec.ANLOG with a total cost of 104264066.35

Select sum(total_drug_cost) as total_cost, d.generic_name
from prescription as p
Left Join drug as d
on p.drug_name = d.drug_name
where total_drug_cost is not NULL
group by d.generic_name
order by total_cost DESC

--3b. b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.
-- C1 ESTERASE INHIBITOR has the highest total cost per day at 3495 --edit through walkthrough


Select round(sum(total_drug_cost)/sum(total_day_supply)) as per_day, d.generic_name
from prescription as p
Left Join drug as d
on p.drug_name = d.drug_name
group by d.generic_name
order by per_day DESC

--4a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.


Select d.drug_name,
CASE WHEN opioid_drug_flag = 'Y' Then 'opioid'
when antibiotic_drug_flag = 'Y' Then 'antibiotic'
Else 'neither' END as drug_type
from drug as d
Left Join prescription as p
on d.drug_name = p.drug_name
group by d.drug_name, drug_type

-- 4b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
-- Opiods
SELECT MONEY(SUM(total_drug_cost)),
CASE
	WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither'
END AS drug_type
FROM drug
LEFT JOIN prescription
ON drug.drug_name = prescription.drug_name
GROUP BY drug_type;

-- 5.How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
-- 10.
SELECT COUNT(DISTINCT cbsa)
FROM cbsa
WHERE cbsaname LIKE '%, TN%'
	OR cbsaname LIKE '%-TN%';


-- b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
-- Nashville-Davidson_Murphreesboro-Franklin: 1,830,410
SELECT cbsaname, sum(population) AS total_population
FROM cbsa 
INNER JOIN population
USING (fipscounty)
GROUP BY cbsaname


-- c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
--Sevier: 95,523

SELECT f.county, f.state, p.population
FROM fips_county as f
INNER JOIN population as p
USING(fipscounty)
LEFT JOIN cbsa as c
USING(fipscounty)
WHERE c.cbsa IS NULL
ORDER BY population DESC;



-- 6. 
-- a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000;

--  b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT drug_name, total_claim_count, opioid_drug_flag
FROM prescription
LEFT JOIN drug
USING(drug_name)
WHERE total_claim_count >= 3000;


--  c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT 
	drug_name, 
	total_claim_count, 
	opioid_drug_flag, 
	nppes_provider_first_name, 
	nppes_provider_last_org_name
FROM prescription
LEFT JOIN drug
USING(drug_name)
LEFT JOIN prescriber
ON prescription.npi = prescriber.npi
WHERE total_claim_count >= 3000;



-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

-- a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT npi, drug_name
FROM prescriber
CROSS JOIN drug
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y';


-- b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT prescriber.npi, drug_name, total_claim_count
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription
USING(npi, drug_name)
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y'
ORDER BY drug_name;


-- c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

SELECT prescriber.npi, drug_name, COALESCE(total_claim_count,0)
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription
USING(npi, drug_name)
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y'
ORDER BY drug_name;





