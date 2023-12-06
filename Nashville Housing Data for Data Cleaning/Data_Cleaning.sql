USE NashvilleHousing;

-- Let's see all the data
Select *
From dbo.NashvilleHousing;
--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data >> remove NULL
Select *
From dbo.NashvilleHousing
order by ParcelID ;

-- Select rows where a.PropertyAddress is NULL and join with corresponding rows from table b
-- Display relevant information including ParcelID, PropertyAddress from both tables, and an updated PropertyAddress
SELECT 
    a.ParcelID, 
    a.PropertyAddress, 
    b.ParcelID AS b_ParcelID, 
    b.PropertyAddress AS b_PropertyAddress, 
    ISNULL(a.PropertyAddress, b.PropertyAddress) AS UpdatedPropertyAddress
FROM 
    dbo.NashvilleHousing a
JOIN 
    dbo.NashvilleHousing b 
ON 
    a.ParcelID = b.ParcelID AND a.[UniqueID] <> b.[UniqueID]
WHERE 
    a.PropertyAddress IS NULL;

-- Update rows in table a where PropertyAddress is NULL
-- Set a.PropertyAddress to a non-null value from either table a or b using the ISNULL function
UPDATE 
    a
SET 
    a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM 
    dbo.NashvilleHousing a
JOIN 
   dbo.NashvilleHousing b 
ON 
    a.ParcelID = b.ParcelID AND a.[UniqueID] <> b.[UniqueID]
WHERE 
    a.PropertyAddress IS NULL;

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select 
    PropertyAddress
From 
    dbo.NashvilleHousing

-- extract different parts of the PropertyAddress column using the SUBSTRING and CHARINDEX functions
SELECT
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
    , SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From 
   dbo.NashvilleHousing

-- Add 2 New column
-- column 1
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);
Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

-- column 2
ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);
Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From dbo.NashvilleHousing

-- make it again with OwnerAddress
Select 
     OwnerAddress
From 
     dbo.NashvilleHousing

-- splitting OwnerAddress into three parts using periods as separators and returning them in reverse order.
Select
    PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
   ,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
   ,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From 
   dbo.NashvilleHousing

-- Add 3 columns
-- column 1 >> Adress
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

-- column 2 >> City
ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

--Column 3 >> State
ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

-- Let's see the whole data again
Select *
From dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
-- Create a Common Table Expression (CTE) named RowNumCTE
WITH RowNumCTE AS (
    -- Select all columns from dbo.NashvilleHousing and add a calculated column 'row_num'
    SELECT *,
           ROW_NUMBER() OVER (
               -- Define the partition to identify duplicates based on these columns
               PARTITION BY ParcelID,
                            PropertyAddress,
                            SalePrice,
                            SaleDate,
                            LegalReference
               -- Order the rows within each partition by UniqueID
               ORDER BY UniqueID
           ) AS row_num
    -- Select from the dbo.NashvilleHousing table
    FROM dbo.NashvilleHousing
)
-- Delete rows from the CTE where row_num is greater than 1
DELETE FROM RowNumCTE
WHERE row_num > 1;


Select *
From dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------