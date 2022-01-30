select *
from [Nashville Housing Data].dbo.nash

---Standardize date format
select SaleDate, CONVERT(date,SaleDate)
from [Nashville Housing Data].dbo.nash

update [Nashville Housing Data].dbo.nash
set SaleDate= CONVERT(date,SaleDate)

Alter table dbo.nash
Add SaleDates Date;
update [Nashville Housing Data].dbo.nash
set SaleDates= CONVERT(date,SaleDate)

Alter table [Nashville Housing Data].dbo.nash
drop column SaleDate

--populate property address data
select PropertyAddress
from [Nashville Housing Data].dbo.nash
where PropertyAddress is null

select a.[UniqueID ],a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Nashville Housing Data].dbo.nash a
join [Nashville Housing Data].dbo.nash b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Nashville Housing Data].dbo.nash a
join [Nashville Housing Data].dbo.nash b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]


--change Y and N to Yes and No
select DISTINCT SoldAsVacant
from [Nashville Housing Data].dbo.nash

select SoldAsVacant
, CASE when SoldAsVacant = 'N' then 'No'
       when SoldAsVacant = 'Y' then 'Yes'
	   ELSE SoldAsVacant
	   END
from [Nashville Housing Data].dbo.nash

update [Nashville Housing Data].dbo.nash
set SoldAsVacant = CASE when SoldAsVacant = 'N' then 'No'
       when SoldAsVacant = 'Y' then 'Yes'
	   ELSE SoldAsVacant
	   END


--remove duplicate
WITH CTE as(
select *,
		ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					 PropertyAddress,
					 PropertyCity,
					 SalePrice,
					 SaleDates,
					 LegalReference
					 ORDER BY
					   UniqueID) row_num
from [Nashville Housing Data].dbo.nash
)
select *
from CTE
where row_num>1