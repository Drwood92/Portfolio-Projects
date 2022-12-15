/****** Script for SelectTopNRows command from SSMS  ******/
-- Selectung all columns from the data set
SELECT *
  FROM [PortfolioProject].[dbo].[NashvilleHousing];

  -- Standardizing the SaleDate Column from a DateTime Format to a Date Format
  SELECT SaleDate,SaleDate_Converted, CONVERT(Date,SaleDate), CAST(SaleDate AS date)
  FROM [PortfolioProject].[dbo].[NashvilleHousing];

  UPDATE [PortfolioProject].[dbo].NashvilleHousing
  SET SaleDate = CAST(SaleDate AS Date);

  -- Casting or converting the SaleDate column didn't reflect my changes, Hence I created Another Column with date datatype and I set it to the CAST format of the SaleDate.

  ALTER TABLE [PortfolioProject].[dbo].NashvilleHousing
  ADD SaleDate_Converted Date;
  
  UPDATE [PortfolioProject].[dbo].NashvilleHousing
  SET SaleDate_Converted = CAST(SaleDate AS Date);


--Property Address Data
 SELECT *
  FROM [PortfolioProject].[dbo].[NashvilleHousing]
  WHERE PropertyAddress IS NULL;

  --Some data within the property address is NULL hence we have to populate it however to do this a self join must be done and use the ISNULL function to populate missing data
  SELECT NHA.ParcelID, NHA.PropertyAddress, NHB.ParcelID, NHB.PropertyAddress, ISNULL(NHA.PropertyAddress,NHB.PropertyAddress)
  FROM [PortfolioProject].[dbo].[NashvilleHousing] AS NHA
  JOIN [PortfolioProject].[dbo].[NashvilleHousing] AS NHB
  ON NHA.ParcelID = NHB.ParcelID
  AND NHA.[UniqueID ]<>NHB.[UniqueID ]
  WHERE NHA.PropertyAddress IS NULL

  UPDATE NHA
  SET PropertyAddress = ISNULL(NHA.PropertyAddress,NHB.PropertyAddress)
  FROM [PortfolioProject].[dbo].[NashvilleHousing] AS NHA
  JOIN [PortfolioProject].[dbo].[NashvilleHousing] AS NHB
  ON NHA.ParcelID = NHB.ParcelID
  AND NHA.[UniqueID ]<>NHB.[UniqueID ]
  WHERE NHA.PropertyAddress IS NULL

--Splitting the PropertyAddress Column into further sub-columns (From the initial column the "," acts as the delimieter)
-- Upon splitting the columns I created two new columns and altered the initial table
 SELECT SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) AS Address, 
			SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS City
 FROM [PortfolioProject].[dbo].[NashvilleHousing]

  ALTER TABLE [PortfolioProject].[dbo].NashvilleHousing
  ADD Property_Address Nvarchar(255);

   UPDATE [PortfolioProject].[dbo].NashvilleHousing
  SET Property_Address = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)

  ALTER TABLE [PortfolioProject].[dbo].NashvilleHousing
  ADD Property_City Nvarchar(255)

   UPDATE [PortfolioProject].[dbo].NashvilleHousing
  SET Property_City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

  SELECT *
 FROM [PortfolioProject].[dbo].[NashvilleHousing]

 --Splitting the OwnerAddress Colum into Address, City and State (Similar to what was done above).
 --However, using the PARSENAME function I created 3 new columns and altered the existing table
 SELECT PARSENAME(REPLACE(OwnerAddress, ',','.'),3) AS Owner_Address, PARSENAME(REPLACE(OwnerAddress, ',','.'),2) AS Owner_City,PARSENAME(REPLACE(OwnerAddress, ',','.'),1) AS Owner_State
 FROM [PortfolioProject].[dbo].[NashvilleHousing];

 ALTER TABLE [PortfolioProject].[dbo].NashvilleHousing
  ADD Owner_Address Nvarchar(255)

   UPDATE [PortfolioProject].[dbo].NashvilleHousing
  SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

  ALTER TABLE [PortfolioProject].[dbo].NashvilleHousing
  ADD Owner_City Nvarchar(255)

   UPDATE [PortfolioProject].[dbo].NashvilleHousing
  SET Owner_City = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

  ALTER TABLE [PortfolioProject].[dbo].NashvilleHousing
  ADD Owner_State Nvarchar(255)

   UPDATE [PortfolioProject].[dbo].NashvilleHousing
  SET Owner_State = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

  SELECT *
 FROM [PortfolioProject].[dbo].[NashvilleHousing]

 --Editing the SoldAsVacant column by replacing N or Y with No or Yes Respectively
 --Modifictions were done using a case statement from the initial table and the table was then altered and column ammended to reflect the new data entries
SELECT
		CASE WHEN SoldAsVacant = 'N' THEN 'No'
			 WHEN SoldAsVacant = 'Y' THEN 'Yes'
			 ELSE SoldAsVacant
			 END
 FROM [PortfolioProject].[dbo].[NashvilleHousing]
 
 UPDATE [PortfolioProject].[dbo].NashvilleHousing
  SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
			 WHEN SoldAsVacant = 'Y' THEN 'Yes'
			 ELSE SoldAsVacant
			 END
	SELECT DISTINCT(SoldAsVacant)
	FROM [PortfolioProject].[dbo].[NashvilleHousing]


--Removing duplicate records
WITH rownum AS(SELECT *, ROW_NUMBER()
						OVER(PARTITION BY ParcelID,
										  PropertyAddress,
										  SalePrice,
										  SaleDate,
										  LegalReference
										  ORDER BY
										  UniqueID) AS rownumbers
	FROM [PortfolioProject].[dbo].[NashvilleHousing])

	-- I deleted the duplicates using the DELETE command after which I selected to see if they still existed and they do not
	SELECT *
	FROM rownum
	WHERE rownumbers > 1

	--Removing columns not required
	ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
	DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate

	SELECT *
	FROM [PortfolioProject].[dbo].[NashvilleHousing]
	