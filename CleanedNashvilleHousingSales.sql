/*
Cleaning Data in SQL Queries
*/

Select * 
From NashvilleHousing..Sales


--------------------------------------------------------------------------------------------------------------------------

------ Standardize Date Format


Select SaleDate, CONVERT(Date, SaleDate) AS StandardizedSaleDate
from 
NashvilleHousing..sales

--The Column was not being updated using this method
--Update NashvilleHousing..Sales
--SET SaleDate = CONVERT(Date, SaleDate)

-- Add New Column SaleDate Converted
Alter table NashvilleHousing..Sales
Add SaleDateConverted Date

-- Converting and copying Date into new column
Update NashvilleHousing..Sales
SET SaleDateConverted = CONVERT(Date, SaleDate)
 
 
 --------------------------------------------------------------------------------------------------------------------------

-------- Populate Property Address data

--Selecting the sales data where the address column in a row is empty
Select * 
from NashvilleHousing..Sales
Where PropertyAddress is null 
order by ParcelID

--joining table to find out if same parcel id has its corresponding address missing 
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing..Sales as a
Join NashvilleHousing..Sales as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--updating missing address column by populating the address that is found for the same parcel id
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing..Sales as a
Join NashvilleHousing..Sales as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

--------------------------------------------------------------------------------------------------------------------------

------------- Breaking out PropertyAddress into Individual Columns (Address, City, State)


----

-- Adding new columns to extract data from Property Address Column
Alter Table NashvilleHousing..Sales
Add 
Address nvarchar(100),
City nvarchar(50)

--Extracting Address Column From Property Address Column
SELECT SUBSTRING(PropertyAddress,0, CHARINDEX(',' , PropertyAddress))
From NashvilleHousing..Sales

--Extracting City Column From Property Address Column
SELECT SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, LEN(PropertyAddress))
From NashvilleHousing..Sales

--Update Address Column from Property Address Column
Update NashvilleHousing..Sales
SET Address = SUBSTRING(PropertyAddress,0,CHARINDEX(',' , PropertyAddress))

--Update City Column from Property Address Column
Update NashvilleHousing..Sales
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, LEN(PropertyAddress))

SELECT PropertyAddress, Address, City 
FROM 
NashvilleHousing..Sales


--------------------------------------------------------------------------------------------------------------------------

------------- Breaking out OwnerAddress into Individual Columns (Address, City, State)

-- Adding new columns to extract data from Property Address Column
Alter Table NashvilleHousing..Sales
Add 
OwnerNewAddress nvarchar(100),
OwnerCity nvarchar(100),
OwnerState nvarchar(50)

SELECT PARSENAME(Replace(OwnerAddress,',' , '.'), 1),
PARSENAME(Replace(OwnerAddress,',' , '.'), 2),
PARSENAME(Replace(OwnerAddress,',' , '.'), 3)
FROM 
NashvilleHousing..Sales

Update NashvilleHousing..Sales
SET OwnerNewAddress = PARSENAME(Replace(OwnerAddress,',' , '.'), 3)

Update NashvilleHousing..Sales
SET OwnerCity = PARSENAME(Replace(OwnerAddress,',' , '.'), 2)

Update NashvilleHousing..Sales
SET OwnerState = PARSENAME(Replace(OwnerAddress,',' , '.'), 1)

SELECT * FROM NashvilleHousing..Sales


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

--Extracting Sold as Vacant Values Based on condition
SELECT SoldAsVacant,
CASE	When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
FROM NashvilleHousing..Sales

--Updating Y with Yes and N with No
Update NashvilleHousing..Sales
SET SoldAsVacant = 
CASE	When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


-- Group Multiple Columns 
WITH RowNumCTE AS ( 
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID
					)	as row_num
FROM NashvilleHousing..Sales

)

--Delete Multiple Columns
DELETE
FROM RowNumCTE
WHERE row_num > 1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT * 
FROM NashvilleHousing..Sales


ALTER TABLE NashvilleHousing..Sales
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict 









