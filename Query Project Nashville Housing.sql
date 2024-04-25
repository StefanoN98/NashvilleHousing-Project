
-- Cleaning data in SQL queries
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--standardize  Date format
SELECT CONVERT(DATE,saledate)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD SaledateConverted date;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET  SaledateConverted =  CONVERT(DATE,saledate)

SELECT SaledateConverted
FROM PortfolioProject.dbo.NashvilleHousing

-- At this point i could eliminate the old date column keeping only the new one "SaledateConverted"

--Populate property address data	
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID=b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.propertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID=b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--breaking out adress into individual columns (address, city,state)
--FIRST METHOD USING SUBSTRING+CHARINDEX
SELECT
	SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress)-1) AS Adress,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City	
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD Address2 nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET  Address2 =  SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD City nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET  City =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--SECOND METHOD
-- usando PARSENAME
SELECT OWnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS ultimo,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS penultimo,
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS terzultimo
FROM PortfolioProject.dbo.NashvilleHousing
WHERE OwnerAddress IS NOT NULL	

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerAddress2 nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET  OwnerAddress2 =  PARSENAME(REPLACE(OwnerAddress,',','.'),1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerCity nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET  OwnerCity =  PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerState nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET  OwnerState =  PARSENAME(REPLACE(OwnerAddress,',','.'),3)

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing



-- change Y and N in Yes and No in"Sold as vacant" field
--query x controllo
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant= 'Y' THEN 'Yes'
	 WHEN SoldAsVacant= 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END AS Corrected
FROM PortfolioProject.dbo.NashvilleHousing
WHERE SoldAsVacant IN('Y' , 'N')

--query per update
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant= 'Y' THEN 'Yes'
	 WHEN SoldAsVacant= 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END AS Corrected
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET  SoldAsVacant =
	 CASE WHEN SoldAsVacant= 'Y' THEN 'Yes'
	 WHEN SoldAsVacant= 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

SELECT DISTINCT SoldAsVacant
FROM PortfolioProject.dbo.NashvilleHousing


--remove duplicates
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY ParcelId, propertyAddress, SalePrice,SaleDate,LegalReference ORDER BY UniqueID) AS CHeckDuplicati
FROM PortfolioProject.dbo.NashvilleHousing
ORDER BY ParcelID

--controllo un parcel id che ha restituito row_number = 2
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY ParcelId, propertyAddress, SalePrice,SaleDate,LegalReference ORDER BY UniqueID) AS CHeckDuplicati
FROM PortfolioProject.dbo.NashvilleHousing
WHERE ParcelID = '091 04 0 046.00'


WITH Row_NUM_CTE AS 
(
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY ParcelId, propertyAddress, SalePrice,SaleDate,LegalReference ORDER BY UniqueID) AS CHeckDuplicati
FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)

SELECT *
FROM Row_NUM_CTE
WHERE CHeckDuplicati>1

--now we'll remove those duplicates
WITH Row_NUM_CTE AS 
(
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY ParcelId, propertyAddress, SalePrice,SaleDate,LegalReference ORDER BY UniqueID) AS CHeckDuplicati
FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)

DELETE 
FROM Row_NUM_CTE
WHERE CHeckDuplicati>1


--delete unused columns
--we'll eliminate TaxDistrict, PropertyAddress and OwnerAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
