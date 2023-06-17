use [project-test2];

SELECT * FROM nashville;

--Correcting Data Types
ALTER TABLE nashville
ALTER COLUMN SaleDate DATE;

--Checking for NULL Values
SELECT SUM(CASE WHEN [UniqueID ] IS NULL THEN 1 ELSE 0 END) FROM nashville; -- 0 Nulls
SELECT SUM(CASE WHEN ParcelID IS NULL THEN 1 ELSE 0 END) FROM nashville; -- 0 Nulls
SELECT SUM(CASE WHEN LandUse IS NULL THEN 1 ELSE 0 END) FROM nashville; -- 0 Nulls
SELECT SUM(CASE WHEN PropertyAddress IS NULL THEN 1 ELSE 0 END) FROM nashville; -- 29 Nulls
SELECT SUM(CASE WHEN SaleDate IS NULL THEN 1 ELSE 0 END) FROM nashville; -- 0 Nulls
SELECT SUM(CASE WHEN SalePrice IS NULL THEN 1 ELSE 0 END) FROM nashville; -- 0 Nulls
SELECT SUM(CASE WHEN LegalReference IS NULL THEN 1 ELSE 0 END) FROM nashville; -- 0 Nulls
SELECT SUM(CASE WHEN SoldAsVacant IS NULL THEN 1 ELSE 0 END) FROM nashville; -- 0 Nulls
SELECT SUM(CASE WHEN OwnerName IS NULL THEN 1 ELSE 0 END) FROM nashville; -- 31,216 Nulls
SELECT SUM(CASE WHEN OwnerAddress IS NULL THEN 1 ELSE 0 END) FROM nashville; -- 30,462 Nulls
SELECT SUM(CASE WHEN Acreage IS NULL THEN 1 ELSE 0 END) FROM nashville; -- 30,462 Nulls
SELECT SUM(CASE WHEN TaxDistrict IS NULL THEN 1 ELSE 0 END) FROM nashville; -- 30,462 Nulls
SELECT SUM(CASE WHEN LandValue IS NULL THEN 1 ELSE 0 END) FROM nashville; -- 30,462 Nulls
SELECT SUM(CASE WHEN BuildingValue IS NULL THEN 1 ELSE 0 END) FROM nashville; -- 30,462 Nulls
SELECT * FROM nashville WHERE Acreage IS NULL;

--Populating Missing PropertyAddress Data
SELECT a.[UniqueID ], a.ParcelID, a.PropertyAddress,b.[UniqueID ], b.ParcelID, b.PropertyAddress,
		ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville a JOIN nashville b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville a JOIN nashville b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

SELECT SUM(CASE WHEN PropertyAddress IS NULL THEN 1 ELSE 0 END) FROM nashville; -- 0 Nulls
------------
-- Populating Missing OwnerName Data
SELECT a.[UniqueID ], a.OwnerAddress, a.OwnerName,b.[UniqueID ], b.OwnerAddress, b.OwnerName,
		ISNULL(a.OwnerName, b.OwnerName)
FROM nashville a JOIN nashville b
ON a.OwnerAddress = b.OwnerAddress AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.OwnerName IS NULL;

UPDATE a
SET OwnerName = ISNULL(a.OwnerName, b.OwnerName)
FROM nashville a JOIN nashville b
ON a.OwnerAddress = b.OwnerAddress AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.OwnerName IS NULL;

SELECT SUM(CASE WHEN OwnerName IS NULL THEN 1 ELSE 0 END) FROM nashville; -- 31,209 Nulls

-- Populating Missing OwnerAddress Data
SELECT a.[UniqueID ], a.OwnerAddress, a.OwnerName,b.[UniqueID ], b.OwnerAddress, b.OwnerName,
		ISNULL(a.OwnerAddress, b.OwnerAddress)
FROM nashville a JOIN nashville b
ON a.OwnerName = b.OwnerName AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.OwnerAddress IS NULL;

UPDATE a
SET OwnerName = ISNULL(a.OwnerName, b.OwnerName)
FROM nashville a JOIN nashville b
ON a.OwnerAddress = b.OwnerAddress AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.OwnerName IS NULL;

SELECT SUM(CASE WHEN OwnerName IS NULL THEN 1 ELSE 0 END) FROM nashville; -- 31,208 Nulls

--Populating Acreage Data
UPDATE a
SET Acreage = ISNULL(a.Acreage, b.Acreage)
FROM nashville a JOIN nashville b
ON a.PropertyAddress = b.PropertyAddress AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.OwnerName IS NULL;

SELECT SUM(CASE WHEN Acreage IS NULL THEN 1 ELSE 0 END) FROM nashville; -- 30,444 Nulls
----------------------------------------------------------------------------------------------

-- Breaking down the PropertyAddress Column into (Address, City, State)
SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 0, CHARINDEX(',', PropertyAddress)),
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
FROM nashville;

ALTER TABLE nashville
ADD Address NVARCHAR(255);
ALTER TABLE nashville
ADD City NVARCHAR(255);

UPDATE nashville
SET Address = SUBSTRING(PropertyAddress, 0, CHARINDEX(',', PropertyAddress));

UPDATE nashville
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));
-------------------------------------------------------------------------------------------------

-- Breaking down OwnerAddress into (Address, City, State)

SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM nashville;

ALTER TABLE nashville
ADD Owner_Address NVARCHAR(255)
ALTER TABLE nashville
ADD Owner_City NVARCHAR(255)
ALTER TABLE nashville
ADD Owner_State NVARCHAR(255)

UPDATE nashville
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

UPDATE nashville
SET Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

UPDATE nashville
SET Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT OwnerAddress, Owner_Address, Owner_City, Owner_State FROM nashville;
-----------------------------------------------------------------------------------

-- Turning 'Y' & 'N' mistakes into 'Yes' & 'No'
SELECT SoldAsVacant, COUNT(SoldAsVacant) FROM nashville
GROUP BY SoldAsVacant;

SELECT SoldAsVacant, 
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM nashville;

UPDATE nashville
SET SoldAsVacant =
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END;

SELECT SoldAsVacant, COUNT(SoldAsVacant) FROM nashville
GROUP BY SoldAsVacant; --'Y' & 'N' are replaced
-----------------------------------------------------------------------------------

-- Deleting All Duplicates

-- Finding the duplicate rows
SELECT *,
ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS RowNum
FROM nashville ORDER BY ParcelID;

WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS RowNum
FROM nashville)

SELECT * FROM RowNumCTE WHERE RowNum >1
ORDER BY PropertyAddress;

-- Deleting the duplicate rows
WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS RowNum
FROM nashville)

DELETE FROM RowNumCTE
WHERE RowNum >1;
------------------------------------------------------------------------------------

--Deleting Columns unuseful for analysis
SELECT * FROM nashville;

ALTER TABLE nashville
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict;
