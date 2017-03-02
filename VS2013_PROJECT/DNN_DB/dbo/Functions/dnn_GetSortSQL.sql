CREATE FUNCTION [dbo].[dnn_GetSortSQL]
(   -- deprecated, please call SortFieldSQL and FormattedString instead
    @SortBy        nVarChar(100),
    @SortAscending Bit,
    @Default       nVarChar(100)
)
	RETURNS 	   nVarChar(120)
AS
	BEGIN
		RETURN dbo.[dnn_FormattedString](dbo.[dnn_SortFieldSQL](@SortBy, @SortAscending, @Default), N'ORDER BY @0')
	END

