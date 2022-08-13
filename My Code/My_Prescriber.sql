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
--Answer: Npi: 1912011792 with 4538 claims

Select p1.npi, p1.total_claim_count
From prescription as p1
Left Join prescriber as p2
on p1.npi = p2.npi
Group by p1.npi, p1,total_claim_count
Order by total_claim_count DESC

--1b David Coffey, Family Practice 4538 claims

Select p1.npi, p1.total_claim_count, p2.nppes_provider_first_name, p2.nppes_provider_last_org_name, p2.specialty_description
From prescription as p1
Left Join prescriber as p2
on p1.npi = p2.npi
Group by p1.npi, p1,total_claim_count, p2.nppes_provider_first_name, p2.nppes_provider_last_org_name, p2.specialty_description
Order by total_claim_count DESC


--2a Which specialty had the most total number of claims (totaled over all drugs)?

Select drug_name as Drug_Name, total_claim_count as total_claim, p2.specialty_description
from prescription as p1
Left Join prescriber as p2
on p1.npi = p2.npi
group by p2.specialty_description, Drug_name, total_claim_count
order by total_claim_count DESC;












