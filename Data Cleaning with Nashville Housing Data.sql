

-- Cleaning data in SQL queries

SELECT *
FROM Portfolio_Project.dbo.NashvilleHousing

-- Change sale date to eliminate timestamp at the end of each date
SELECT SaleDate, CONVERT(date, SaleDate)
FROM Portfolio_Project.dbo.NashvilleHousing

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
ADD SaleDateConverted Date; 

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

-----------------------------------------------------------------------------------------------
-- Populate Property Address data
SELECT *
FROM Portfolio_Project.dbo.NashvilleHousing
-- WHERE PropertyAddress is null
ORDER BY ParcelID

-- Bringing up all property addresses that are appear null but have an address
SELECT a.ParcelID, a. PropertyAddress, b.ParcelID, b.PropertyAddress
FROM Portfolio_Project.dbo.NashvilleHousing a
JOIN Portfolio_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a. [UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Creating a separate column that will replace the null Property Addresses

SELECT a.ParcelID, a. PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.propertyaddress, b.PropertyAddress)
FROM Portfolio_Project.dbo.NashvilleHousing a
JOIN Portfolio_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a. [UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


--	Eliminating nulls for property addresses by updating the table

UPDATE a
SET PropertyAddress = ISNULL (a.propertyaddress, b.PropertyAddress)
FROM Portfolio_Project.dbo.NashvilleHousing a
JOIN Portfolio_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a. [UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

---------------------------------------------------------------------------------------------
-- Breaking out address into individual columns (address, city, state)

SELECT PropertyAddress
FROM Portfolio_Project.dbo.NashvilleHousing

--Separating street address from city and eliminating the comma at the end of every street address

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
FROM Portfolio_Project.dbo.NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM Portfolio_Project.dbo.NashvilleHousing

-- Creating two new columns adding new values

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR (255)

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR (255) 

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT*
FROM Portfolio_Project.dbo.NashvilleHousing



SELECT OwnerAddress
FROM Portfolio_Project.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant Field

SELECT DISTINCT(SoldAsVacant)
FROM Portfolio_Project.dbo.NashvilleHousing

--How many are Y, N, Yes, No?
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio_Project.dbo.NashvilleHousing
GROUP BY SoldAsVacant
order by 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM Portfolio_Project.dbo.NashvilleHousing

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END


----------------------------------------------------------------------------------------------------------------

--Removing duplicates

-- Identifying duplicates
SELECT *
FROM Portfolio_Project.dbo.NashvilleHousing

SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
					UniqueID
					) row_num
FROM Portfolio_Project.dbo.NashvilleHousing
ORDER BY  ParcelID

SELECT *
FROM Portfolio_Project.dbo.NashvilleHousing

-- Checking number of duplicates
WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
					UniqueID
					) row_num
FROM Portfolio_Project.dbo.NashvilleHousing
--ORDER BY  ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


-- Deleting duplicates
WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
					UniqueID
					) row_num
FROM Portfolio_Project.dbo.NashvilleHousing
--ORDER BY  ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1