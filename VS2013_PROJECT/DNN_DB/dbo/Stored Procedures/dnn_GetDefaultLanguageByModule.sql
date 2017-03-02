CREATE PROCEDURE [dbo].[dnn_GetDefaultLanguageByModule]
(
	@ModuleList varchar(1000)
)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @TempList table
	(
		ModuleID int
	)

	DECLARE @ModuleID varchar(10), @Pos int

	SET @ModuleList = LTRIM(RTRIM(@ModuleList))+ ','
	SET @Pos = CHARINDEX(',', @ModuleList, 1)

	IF REPLACE(@ModuleList, ',', '') <> ''
	BEGIN
		WHILE @Pos > 0
		BEGIN
			SET @ModuleID = LTRIM(RTRIM(LEFT(@ModuleList, @Pos - 1)))
			IF @ModuleID <> ''
			BEGIN
				INSERT INTO @TempList (ModuleID) VALUES (CAST(@ModuleID AS int)) 
			END
			SET @ModuleList = RIGHT(@ModuleList, LEN(@ModuleList) - @Pos)
			SET @Pos = CHARINDEX(',', @ModuleList, 1)

		END
	END	

SELECT DISTINCT m.ModuleID, p.DefaultLanguage
FROM            dbo.dnn_Modules  m
INNER JOIN      dbo.dnn_Portals p ON p.PortalID = m.PortalID
WHERE		m.ModuleID in (SELECT ModuleID FROM @TempList)
ORDER BY        m.ModuleID	
		
END

