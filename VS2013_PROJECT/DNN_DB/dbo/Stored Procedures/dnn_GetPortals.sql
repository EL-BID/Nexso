CREATE PROCEDURE [dbo].[dnn_GetPortals]
	@CultureCode	nVarChar(50) -- pass Null | '' to return portal default language
AS
BEGIN
	SELECT * 
	FROM  dbo.[dnn_vw_Portals]
	WHERE CultureCode = 
		CASE 
			WHEN IsNull(@CultureCode, N'') = N'' THEN DefaultLanguage
			ELSE @CultureCode 
		END 
	ORDER BY PortalName;
END
