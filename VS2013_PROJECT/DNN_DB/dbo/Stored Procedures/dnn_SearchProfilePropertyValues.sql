CREATE PROCEDURE [dbo].[dnn_SearchProfilePropertyValues]
 @PortalId INT,
 @PropertyName NVARCHAR(50),
 @SearchString NVARCHAR(100)
AS
SELECT DISTINCT
 up.PropertyValue
FROM
 dbo.dnn_UserProfile up
 INNER JOIN dbo.dnn_ProfilePropertyDefinition ppd ON ppd.PropertyDefinitionID = up.PropertyDefinitionID
WHERE
 ppd.PortalID = @PortalId
 AND ppd.PropertyName = @PropertyName
 AND up.PropertyValue LIKE '%' + @SearchString + '%'
 AND up.PropertyValue IS NOT NULL
ORDER BY
 up.PropertyValue
