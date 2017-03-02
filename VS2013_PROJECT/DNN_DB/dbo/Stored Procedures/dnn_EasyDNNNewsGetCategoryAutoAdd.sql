CREATE PROCEDURE [dbo].[dnn_EasyDNNNewsGetCategoryAutoAdd]
	@PortalID int,
    @ModuleID int
AS 
;WITH hierarchy AS (
	SELECT CategoryID, ParentCategory, CategoryName
	FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
	WHERE (cl.ParentCategory IN (
		SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @ModuleID
		) OR cl.CategoryID IN (
		SELECT [CategoryID] FROM dbo.[dnn_EasyDNNNewsModuleCategoryItems] WHERE ModuleID = @ModuleID)
	) AND PortalID = @PortalID

	UNION ALL

	SELECT c.CategoryID, c.ParentCategory, c.[CategoryName]
	FROM dbo.[dnn_EasyDNNNewsCategoryList] AS c INNER JOIN hierarchy AS p ON c.ParentCategory = p.CategoryID
	WHERE c.PortalID = @PortalID
)
SELECT DISTINCT CategoryID FROM hierarchy;

