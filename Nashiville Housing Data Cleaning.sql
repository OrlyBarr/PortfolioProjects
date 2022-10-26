--Cleaning Data in SQL Queries

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--Standardize Date Format

SELECT SaleDateConverted, CONVERT(DATE, SaleDate) 
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted=CONVERT(DATE, SaleDate) 

--------------------------------------------------

--Populate Property Address data

SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID 


SELECT a.ParcelID,a.PropertyAddress, b.ParcelID,b.PropertyAddress,
ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.UniqueID <> b.UniqueID
	AND a.ParcelID = b.ParcelID
WHERE a.PropertyAddress IS NULL 


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.UniqueID <> b.UniqueID
	AND a.ParcelID = b.ParcelID
WHERE a.PropertyAddress IS NULL 
	
--------------------------------------------

--Breaking out Address into individual columns(Address, City, State) 
--WHERE PropertyAddress IS NULL



ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress=SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity=SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

--Breaking out OwnerAddress column into individual columns(Address, City, State)  by using the PARSENAME function. 

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) Address, 
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) City,
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) State
FROM PortfolioProject.dbo.NashvilleHousing 


ALTER TABLE NashvilleHousing
ADD OwnerySplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerySplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


------------------------------------------

--Change Y and N to Yes and No in "SoldAsVacant" field

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant 
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant='Y' THEN 'Yes'
		 WHEN SoldAsVacant='N' THEN 'No'
		 ELSE SoldAsVacant END  
FROM PortfolioProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant='Y' THEN 'Yes'
		 WHEN SoldAsVacant='N' THEN 'No'
		 ELSE SoldAsVacant END  
		 

--Finding Duplicate values. We actually will not remove the duplicate values on the Data Base

WITH "CTE-RowNum" AS
(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	PropertyAddress,
	SaleDate,
	LegalReference
	ORDER BY
	UniqueID) row_num
FROM PortfolioProject.dbo.NashvilleHousing
)

SELECT *
FROM "CTE-RowNum"
WHERE row_num>1 

/*Delete 
FROM "CTE-RowNum"
WHERE row_num>1 */


--Delete unused columns

ALTER TABLE NashvilleHousing
DROP Column PropertyAddress, OwnerAddress