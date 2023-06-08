use [Housing-Data];
SELECT * FROM nash_housing;

--Some property addresses are NULL even though they have a uniqueID and ParcelID
SELECT * FROM nash_housing WHERE PropertyAddress IS NULL;

--Populating missing property addres data

SELECT a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nash_housing a INNER JOIN nash_housing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nash_housing a INNER JOIN nash_housing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;
--------------------------------------------------------------------------------

--Breaking Property Address Column into (Address, City)

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS AddressCity
FROM nash_housing

ALTER TABLE nash_housing
ADD Address NVARCHAR(255);

ALTER TABLE nash_housing
ADD AddressCity NVARCHAR(255);

UPDATE nash_housing
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

UPDATE nash_housing
SET AddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

SELECT PropertyAddress, Address, AddressCity FROM nash_housing;
-------------------------------------------------------------------------------

----Breaking Owner Address Column into (Address, City, State)
SELECT OwnerAddress FROM nash_housing;

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM Nash_Housing;

ALTER TABLE Nash_Housing
ADD OwnerAddress1 NVARCHAR(255);

ALTER TABLE Nash_Housing
ADD OwnerCity NVARCHAR(255);

ALTER TABLE Nash_Housing
ADD OwnerState NVARCHAR(255);

UPDATE Nash_Housing
SET OwnerAddress1 = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3);

UPDATE Nash_Housing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2);

UPDATE Nash_Housing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1);

SELECT OwnerAddress1, OwnerCity, OwnerState FROM Nash_Housing;
----------------------------------------------------------------------------------

--Correcting data in SoldAsVacant, replacing 'Y' & 'N' with 'Yes' & 'No'

SELECT SoldAsVacant, COUNT(SoldAsVacant) FROM Nash_Housing GROUP BY SoldAsVacant;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
		WHEN SoldAsVacant ='N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM Nash_Housing;

UPDATE nash_housing
SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
		WHEN SoldAsVacant ='N' THEN 'No'
		ELSE SoldAsVacant
		END;
-----------------------------------------------------------------------------

--Delete Duplicates using a CTE
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) row_num
FROM Nash_Housing
ORDER BY ParcelID;


WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) row_num

FROM Nash_Housing)

SELECT * FROM RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress;

DELETE FROM RowNumCTE
WHERE row_num >1;
-------------------------------------------------------------------------------

--Delete Unused Columns

ALTER TABLE Nash_Housing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict;
-------------------------------------------------------------------------------