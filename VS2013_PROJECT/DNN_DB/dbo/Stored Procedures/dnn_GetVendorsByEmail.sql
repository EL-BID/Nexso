CREATE procedure [dbo].[dnn_GetVendorsByEmail]
	@Filter nvarchar(50),
	@PortalID int,
	@PageSize int,
	@PageIndex int
AS

	DECLARE @PageLowerBound int
	DECLARE @PageUpperBound int
	-- Set the page bounds
	SET @PageLowerBound = @PageSize * @PageIndex
	SET @PageUpperBound = @PageLowerBound + @PageSize + 1

	CREATE TABLE #PageIndex 
	(
		IndexID		int IDENTITY (1, 1) NOT NULL,
		VendorId	int
	)

	INSERT INTO #PageIndex (VendorId)
	SELECT VendorId
	FROM dbo.dnn_Vendors
	WHERE ( (Email like @Filter + '%') AND ((PortalId = @PortalID) or (@PortalID is null and PortalId is null)) )
	ORDER BY VendorId DESC


	SELECT COUNT(*) as TotalRecords
	FROM #PageIndex


	SELECT dbo.dnn_Vendors.*,
       		( select count(*) from dbo.dnn_Banners where dbo.dnn_Banners.VendorId = dbo.dnn_Vendors.VendorId ) AS 'Banners'
	FROM dbo.dnn_Vendors
	INNER JOIN #PageIndex PageIndex
		ON dbo.dnn_Vendors.VendorId = PageIndex.VendorId
	WHERE ( (PageIndex.IndexID > @PageLowerBound) OR @PageLowerBound is null )	
		AND ( (PageIndex.IndexID < @PageUpperBound) OR @PageUpperBound is null )	
	ORDER BY
		PageIndex.IndexID

