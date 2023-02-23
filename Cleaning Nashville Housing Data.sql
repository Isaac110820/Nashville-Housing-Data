select *
from PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select SaleDate, convert(date, SaleDate)
from PortfolioProject..NashvilleHousing


alter table NashvilleHousing
add SaleDateConverted Date; 

update NashvilleHousing 
set saledateconverted = convert(date, SaleDate)

select SaleDateConverted, convert(date, SaleDate)
from PortfolioProject..NashvilleHousing




 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
-- Rows with the same ParcellID will have the same address
-- Use the address associated with the ParcellID to populated the missing addresses corresponding to the same ParcellID

select *
from PortfolioProject..NashvilleHousing
where PropertyAddress is null 

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a 
join PortfolioProject..nashvillehousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.propertyaddress is null

update a 
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a 
join PortfolioProject..nashvillehousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.propertyaddress is null





--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from PortfolioProject..NashvilleHousing


-- "-1" removes the comma from the output
select 
substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as Address
, substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress)) as City
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

update PortfolioProject..NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

alter table PortfolioProject..NashvilleHousing
add PropertySplitCity Nvarchar(255);

update PortfolioProject..NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress))

select * 
from PortfolioProject..NashvilleHousing

-- Do something similar, but with ownder address

select OwnerAddress
from PortfolioProject..NashvilleHousing

-- Parsename looks for periods only
-- We need to replace all commas with periods

Select 
parsename(replace(OwnerAddress, ',', '.'), 3)
, parsename(replace(OwnerAddress, ',', '.'), 2)
, parsename(replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject..NashvilleHousing

-- Update tables

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitState Nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1)

select * 
from PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2



-- Use a case statement 

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Redundant Columns

select *
from PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate