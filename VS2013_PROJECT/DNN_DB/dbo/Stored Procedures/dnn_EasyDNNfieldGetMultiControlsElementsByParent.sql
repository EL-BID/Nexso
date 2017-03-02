-- treba nadograditi da se dobi i CustomFieldID od parenta tj ko stvara selected index changed
CREATE PROCEDURE [dbo].[dnn_EasyDNNfieldGetMultiControlsElementsByParent]
    @parentCustomFieldID int,
    @FieldElementID int, -- FieldElementID pomocu kojeg se dobije CustomFieldID element parent ID -- element koji je parent tj na temelju kojeg se dohvacaju childeovi
    @ControlTypeID int,
    @ParentList nvarchar(1000) = '',
    @FieldsTemplateID int, -- template id,
    @LocaleCode nvarchar(20) = null
AS
SET NOCOUNT ON;
-- dohvati parent custom field
IF @ControlTypeID = 20
BEGIN
	IF @LocaleCode IS NULL
	BEGIN
		-- ovo su cf koji imaju zadanog parenta i nalaze se u grupi 
		-- treba dobiti childove sa childe elementima
		IF @parentCustomFieldID = 0 -- ovo se moze izbaciti, al u kod negdije nije dostupan parent custom field ID
		BEGIN
			SELECT TOP 1 @parentCustomFieldID = [CustomFieldID] FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE FieldElementID = @FieldElementID
		END	
		
		;WITH FieldsWithParent AS(  -- sadrzi childe custom fieldove tj oni koji imaju zadani parentID i nalaze se u istoj template grupi
			SELECT f.[CustomFieldID],fti.[Position]
			FROM dbo.[dnn_EasyDNNfields] AS f INNER JOIN dbo.[dnn_EasyDNNfieldsTemplateItems] AS fti ON f.CustomFieldID = fti.CustomFieldID AND fti.FieldsTemplateID = @FieldsTemplateID
			WHERE fti.FieldsTemplateID = @FieldsTemplateID AND f.[CustomFieldID] IN (SELECT DISTINCT fme.CustomFieldID FROM dbo.[dnn_EasyDNNfieldsMultiElements] AS fme WHERE fme.FEParentID IN (SELECT [FieldElementID] FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE [CustomFieldID] = @parentCustomFieldID))
		)
		SELECT fwp.[CustomFieldID],me.[FieldElementID],me.[FEParentID],me.[Text],me.[DefSelected],
		CASE WHEN me.[FieldElementID] IS NOT NULL THEN CAST ((SELECT CASE WHEN COUNT([FEParentID]) > 0 THEN 1 ELSE 0 END FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE FEParentID = me.FieldElementID) AS BIT) ELSE NULL END AS [HasChildes]
		FROM FieldsWithParent AS fwp
			LEFT OUTER JOIN dbo.[dnn_EasyDNNfieldsMultiElements] as me ON fwp.CustomFieldID = me.CustomFieldID AND (me.FEParentID = @FieldElementID OR FEParentID IS NULL)-- left outer zato jer je moguce da cf nema niti jedan childe onda se stavlja null
		--WHERE me.FEParentID = @FieldElementID OR FEParentID IS NULL
		ORDER BY fwp.Position,me.Position ASC;
	END
	ELSE -- lokalizirani
	BEGIN
		;WITH FieldsWithParent AS(  -- sadrzi childe custom fieldove tj oni koji imaju zadani parentID i nalaze se u istoj template grupi
			SELECT f.[CustomFieldID],fti.[Position]
			FROM dbo.[dnn_EasyDNNfields] AS f INNER JOIN dbo.[dnn_EasyDNNfieldsTemplateItems] AS fti ON f.CustomFieldID = fti.CustomFieldID AND fti.FieldsTemplateID = @FieldsTemplateID
			WHERE fti.FieldsTemplateID = @FieldsTemplateID AND f.[CustomFieldID] IN (SELECT DISTINCT fme.CustomFieldID FROM dbo.[dnn_EasyDNNfieldsMultiElements] AS fme WHERE fme.FEParentID IN (SELECT [FieldElementID] FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE [CustomFieldID] = @parentCustomFieldID))
		),
		AllElements AS (
		SELECT fwp.[CustomFieldID],me.[FieldElementID],me.[FEParentID],me.[Text],me.[DefSelected],fwp.Position AS parentPosition ,me.Position,
		CASE WHEN me.[FieldElementID] IS NOT NULL THEN CAST ((SELECT CASE WHEN COUNT([FEParentID]) > 0 THEN 1 ELSE 0 END FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE FEParentID = me.FieldElementID) AS BIT) ELSE NULL END AS [HasChildes]
		FROM FieldsWithParent AS fwp
			LEFT OUTER JOIN dbo.[dnn_EasyDNNfieldsMultiElements] as me ON fwp.CustomFieldID = me.CustomFieldID AND (me.FEParentID = @FieldElementID OR FEParentID IS NULL)-- left outer zato jer je moguce da cf nema niti jedan childe onda se stavlja null
		--WHERE me.FEParentID = @FieldElementID OR FEParentID IS NULL
		),
		LocalizedValues AS(
		SELECT allelem.[CustomFieldID],allelem.[FieldElementID],allelem.[FEParentID],allelem.parentPosition,allelem.Position,CASE WHEN mel.[Text] IS NULL THEN allelem.[Text] ELSE mel.[Text] END AS [Text] ,allelem.[DefSelected],allelem.[HasChildes]
		FROM AllElements AS allelem LEFT OUTER JOIN dbo.[dnn_EasyDNNfieldsMultiElementsLocalization] AS mel ON allelem.FieldElementID = mel.FieldElementID AND mel.LocaleCode = @LocaleCode	
		)
		SELECT [CustomFieldID],[FieldElementID],[FEParentID],[Text],[DefSelected],[HasChildes] FROM LocalizedValues
		ORDER BY parentPosition,Position ASC;
	END
END
ELSE IF @ControlTypeID = 23
BEGIN
	DECLARE @CheckedParentsElementsAndPosition TABLE (ParentID INT NOT NULL PRIMARY KEY, Position INT);
	IF @ParentList <> ''
	BEGIN
		INSERT INTO @CheckedParentsElementsAndPosition SELECT cp.KeyID, fme.Position FROM dbo.[dnn_EDS_StringListToTable](@ParentList) AS cp INNER JOIN dbo.[dnn_EasyDNNfieldsMultiElements] AS fme ON cp.KeyID = fme.FieldElementID
	END
	IF @parentCustomFieldID = 0 -- ovo se moze izbaciti, al u kod negdije nije dostupan parent custom field ID
	BEGIN
		SELECT TOP 1 @ParentCustomFieldID = [CustomFieldID] FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE FieldElementID IN (SELECT TOP 1 ParentID FROM @CheckedParentsElementsAndPosition)
	END
	IF @LocaleCode IS NULL
	BEGIN
		-- ovo su cf koji imaju zadanog parenta i nalaze se u grupi 
		-- treba dobiti childove sa childe elementima
		;WITH FieldsWithParent AS(  -- sadrzi childe custom fieldove tj oni koji imaju zadani parentID i nalaze se u istoj template grupi
			SELECT f.[CustomFieldID],fti.[Position]
			FROM dbo.[dnn_EasyDNNfields] AS f INNER JOIN dbo.[dnn_EasyDNNfieldsTemplateItems] AS fti ON f.CustomFieldID = fti.CustomFieldID AND fti.FieldsTemplateID = @FieldsTemplateID
			WHERE fti.FieldsTemplateID = @FieldsTemplateID AND f.[CustomFieldID] IN (SELECT DISTINCT fme.CustomFieldID FROM dbo.[dnn_EasyDNNfieldsMultiElements] AS fme WHERE fme.FEParentID IN (SELECT [FieldElementID] FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE [CustomFieldID] = @parentCustomFieldID))
		),
		ResultPrijeSortiranja AS(
		SELECT me.[CustomFieldID],me.[FieldElementID],me.[FEParentID],me.[Text],me.[DefSelected], fwp.Position AS parentCFposition,me.Position AS elementPosition,
		CAST ((SELECT CASE WHEN COUNT([FEParentID]) > 0 THEN 1 ELSE 0 END FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE FEParentID = me.FieldElementID) AS BIT) AS [HasChildes]
		FROM FieldsWithParent AS fwp
			LEFT OUTER JOIN dbo.[dnn_EasyDNNfieldsMultiElements] as me ON fwp.CustomFieldID = me.CustomFieldID -- nije mi bas jasno ovo left outer - da se dobiju i oni koji su nall
		WHERE me.FEParentID IN (SELECT ParentID FROM @CheckedParentsElementsAndPosition) OR FEParentID IS NULL
		)
		SELECT me.[CustomFieldID],me.[FieldElementID],me.[FEParentID],me.[Text],me.[DefSelected],me.[HasChildes]
		FROM ResultPrijeSortiranja AS me LEFT OUTER JOIN @CheckedParentsElementsAndPosition as peap ON me.FEParentID = peap.ParentID
		ORDER BY me.parentCFposition,peap.Position,me.elementPosition ASC;
	END
	ELSE
	BEGIN
		;WITH FieldsWithParent AS(  -- sadrzi childe custom fieldove tj oni koji imaju zadani parentID i nalaze se u istoj template grupi
			SELECT f.[CustomFieldID],fti.[Position]
			FROM dbo.[dnn_EasyDNNfields] AS f INNER JOIN dbo.[dnn_EasyDNNfieldsTemplateItems] AS fti ON f.CustomFieldID = fti.CustomFieldID AND fti.FieldsTemplateID = @FieldsTemplateID
			WHERE fti.FieldsTemplateID = @FieldsTemplateID AND f.[CustomFieldID] IN (SELECT DISTINCT fme.CustomFieldID FROM dbo.[dnn_EasyDNNfieldsMultiElements] AS fme WHERE fme.FEParentID IN (SELECT [FieldElementID] FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE [CustomFieldID] = @parentCustomFieldID))
		),
		ResultPrijeSortiranja AS(
		SELECT me.[CustomFieldID],me.[FieldElementID],me.[FEParentID],me.[Text],me.[DefSelected], fwp.Position AS parentCFposition,me.Position AS elementPosition,
		CAST ((SELECT CASE WHEN COUNT([FEParentID]) > 0 THEN 1 ELSE 0 END FROM dbo.[dnn_EasyDNNfieldsMultiElements] WHERE FEParentID = me.FieldElementID) AS BIT) AS [HasChildes]
		FROM FieldsWithParent AS fwp
			LEFT OUTER JOIN dbo.[dnn_EasyDNNfieldsMultiElements] as me ON fwp.CustomFieldID = me.CustomFieldID -- nije mi bas jasno ovo left outer - da se dobiju i oni koji su nall
		WHERE me.FEParentID IN (SELECT ParentID FROM @CheckedParentsElementsAndPosition) OR FEParentID IS NULL
		),
		LocalizedValues AS(
			SELECT allelem.[CustomFieldID],allelem.[FieldElementID],allelem.[FEParentID],allelem.parentCFposition,allelem.elementPosition,CASE WHEN mel.[Text] IS NULL THEN allelem.[Text] ELSE mel.[Text] END AS [Text],allelem.[DefSelected],allelem.[HasChildes]
			FROM ResultPrijeSortiranja AS allelem LEFT OUTER JOIN dbo.[dnn_EasyDNNfieldsMultiElementsLocalization] AS mel ON allelem.FieldElementID = mel.FieldElementID AND mel.LocaleCode = @LocaleCode	
		)
		SELECT me.[CustomFieldID],me.[FieldElementID],me.[FEParentID],me.[Text],me.[DefSelected],me.[HasChildes]
		FROM LocalizedValues AS me LEFT OUTER JOIN @CheckedParentsElementsAndPosition as peap ON me.FEParentID = peap.ParentID
		ORDER BY me.parentCFposition,peap.Position,me.elementPosition ASC;
	END
END

