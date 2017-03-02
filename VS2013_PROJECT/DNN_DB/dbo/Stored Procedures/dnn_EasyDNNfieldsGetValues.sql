CREATE PROCEDURE [dbo].[dnn_EasyDNNfieldsGetValues]
(
	@ArticleID INT,
	@FieldsTemplateID INT,
	@LocaleCode	NVARCHAR(20) = NULL,
	@ShowHiddenFields BIT
)
AS
SET NOCOUNT ON;
IF @LocaleCode IS NULL
BEGIN
	SELECT fv.[ArticleID], cf.[CustomFieldID],cf.[ControlTypeID],cf.[Token],cf.[ShowLabel],cf.[LabelValue],cf.[LabelHelp],cf.[IsParent],cf.[IconURL],cf.[ACode],cf.[DisplayFormat],fv.[RText],fv.[Decimal],fv.[Int],fv.[Bit],NULL AS [FieldElementID],fv.[Text],gt.[Position],NULL AS [MEPosition]
	FROM dbo.[dnn_EasyDNNfields] AS cf
		INNER JOIN dbo.[dnn_EasyDNNfieldsTemplateItems] AS gt ON cf.[CustomFieldID] = gt.[CustomFieldID]
		INNER JOIN dbo.[dnn_EasyDNNfieldsValues] as fv ON cf.[CustomFieldID] = fv.[CustomFieldID]
	WHERE cf.[IsPublished] = 1 AND (@ShowHiddenFields = 1 OR cf.[IsHidden] = @ShowHiddenFields) AND gt.[FieldsTemplateID] = @FieldsTemplateID AND fv.[ArticleID] = @ArticleID
	UNION ALL
	SELECT fms.[ArticleID], cf.[CustomFieldID],cf.[ControlTypeID],cf.[Token],cf.[ShowLabel],cf.[LabelValue],cf.[LabelHelp],cf.[IsParent],cf.[IconURL],NULL AS [ACode],NULL AS [DisplayFormat],NULL as [RText], NULL AS [Decimal],NULL AS [Int],NULL AS [Bit],fme.[FieldElementID],fme.[Text],gt.[Position],fme.[Position] AS [MEPosition]
	FROM dbo.[dnn_EasyDNNfields] as cf INNER JOIN dbo.[dnn_EasyDNNfieldsTemplateItems] AS gt ON cf.[CustomFieldID] = gt.[CustomFieldID]
		INNER JOIN dbo.[dnn_EasyDNNfieldsMultiElements] as fme ON cf.[CustomFieldID] = fme.[CustomFieldID]
		LEFT OUTER JOIN dbo.[dnn_EasyDNNfieldsMultiSelected] as fms ON cf.[CustomFieldID] = fms.[CustomFieldID] AND fme.[FieldElementID] = fms.[FieldElementID] AND ((cf.[ShowAllMultiElements] = 0 AND fms.[ArticleID] = @ArticleID) OR (cf.[ShowAllMultiElements] = 1 AND (fms.[ArticleID] = @ArticleID OR (fms.[ArticleID] IS NULL AND cf.[ControlTypeID] = 23))))
	WHERE cf.[IsPublished] = 1 AND (@ShowHiddenFields = 1 OR cf.[IsHidden] = @ShowHiddenFields) AND gt.[FieldsTemplateID] = @FieldsTemplateID AND ((cf.[ShowAllMultiElements] = 0 AND fms.[ArticleID] = @ArticleID) OR (cf.[ShowAllMultiElements] = 1 AND (fms.[ArticleID] = @ArticleID OR (fms.[ArticleID] IS NULL AND cf.[ControlTypeID] = 23))))
	ORDER BY [Position], [MEPosition];
END
ELSE
BEGIN
	;WITH AllValues ([ArticleID],[CustomFieldID],[ControlTypeID],[Token],[ShowLabel],[LabelValue],[LabelHelp],[IsParent],[IconURL],[ACode],[DisplayFormat],[RText],[Decimal],[Int],[Bit],[FieldElementID],[Text],[Position],[MEPosition])AS (
		SELECT fv.[ArticleID], cf.[CustomFieldID],cf.[ControlTypeID],cf.[Token],cf.[ShowLabel],cf.[LabelValue],cf.[LabelHelp],cf.[IsParent],cf.[IconURL],cf.[ACode],cf.[DisplayFormat],fv.[RText],fv.[Decimal],fv.[Int],fv.[Bit],NULL AS [FieldElementID],fv.[Text],gt.[Position],NULL AS [MEPosition]
		FROM dbo.[dnn_EasyDNNfields] AS cf INNER JOIN dbo.[dnn_EasyDNNfieldsTemplateItems] AS gt ON cf.[CustomFieldID] = gt.[CustomFieldID]
			INNER JOIN dbo.[dnn_EasyDNNfieldsValues] as fv ON cf.[CustomFieldID] = fv.[CustomFieldID]
		WHERE cf.[IsPublished] = 1 AND (@ShowHiddenFields = 1 OR cf.[IsHidden] = @ShowHiddenFields) AND gt.[FieldsTemplateID] = @FieldsTemplateID AND fv.[ArticleID] = @ArticleID
		UNION ALL
		SELECT fms.[ArticleID], cf.[CustomFieldID],cf.[ControlTypeID],cf.[Token],cf.[ShowLabel],cf.[LabelValue],cf.[LabelHelp],cf.[IsParent],cf.[IconURL],NULL AS [ACode],NULL AS [DisplayFormat],NULL as [RText], NULL AS [Decimal],NULL AS [Int],NULL AS [Bit],fme.[FieldElementID],fme.[Text],gt.[Position],fme.[Position] AS [MEPosition]
		FROM dbo.[dnn_EasyDNNfields] as cf INNER JOIN dbo.[dnn_EasyDNNfieldsTemplateItems] AS gt ON cf.[CustomFieldID] = gt.[CustomFieldID]
			INNER JOIN dbo.[dnn_EasyDNNfieldsMultiElements] as fme ON cf.[CustomFieldID] = fme.[CustomFieldID]
			LEFT OUTER JOIN dbo.[dnn_EasyDNNfieldsMultiSelected] as fms ON cf.[CustomFieldID] = fms.[CustomFieldID] AND fms.[FieldElementID] = fme.[FieldElementID] AND ((cf.[ShowAllMultiElements] = 0 AND fms.[ArticleID] = @ArticleID) OR (cf.[ShowAllMultiElements] = 1 AND (fms.[ArticleID] = @ArticleID OR (fms.[ArticleID] IS NULL AND cf.[ControlTypeID] = 23))))
		WHERE cf.[IsPublished] = 1 AND (@ShowHiddenFields = 1 OR cf.[IsHidden] = @ShowHiddenFields) AND gt.[FieldsTemplateID] = @FieldsTemplateID AND ((cf.[ShowAllMultiElements] = 0 AND fms.[ArticleID] = @ArticleID) OR (cf.[ShowAllMultiElements] = 1 AND (fms.[ArticleID] = @ArticleID OR (fms.[ArticleID] IS NULL AND cf.[ControlTypeID] = 23))))
	),
	LocalizedSingleValues ([ArticleID],[CustomFieldID],[ControlTypeID],[Token],[ShowLabel],[LabelValue],[LabelHelp],[IsParent],[IconURL],[ACode],[DisplayFormat],[RText],[Decimal],[Int],[Bit],[FieldElementID],[Text],[Position],[MEPosition]) AS(
		SELECT av.[ArticleID], av.[CustomFieldID],av.[ControlTypeID],av.[Token],av.[ShowLabel],av.[LabelValue],av.[LabelHelp],av.[IsParent],av.[IconURL],av.[ACode],av.[DisplayFormat],fvl.[RText],av.[Decimal],av.[Int],av.[Bit],av.[FieldElementID],fvl.[Text],av.[Position],av.[MEPosition]
		FROM AllValues as av
			INNER JOIN dbo.[dnn_EasyDNNfieldsValuesLocalization] AS fvl ON av.CustomFieldID = fvl.CustomFieldID AND fvl.ArticleID = @ArticleID AND fvl.LocaleCode = @LocaleCode
		WHERE (av.ControlTypeID = 1 OR av.ControlTypeID = 2)
	),
	LocalizedMultiValues ([ArticleID],[CustomFieldID],[ControlTypeID],[Token],[ShowLabel],[LabelValue],[LabelHelp],[IsParent],[IconURL],[ACode],[DisplayFormat],[RText],[Decimal],[Int],[Bit],[FieldElementID],[Text],[Position],[MEPosition]) AS(
		SELECT av.[ArticleID], av.[CustomFieldID],av.[ControlTypeID],av.[Token],av.[ShowLabel],av.[LabelValue],av.[LabelHelp],av.[IsParent],
			av.[IconURL],av.[ACode],av.[DisplayFormat],av.[RText],av.[Decimal],av.[Int],av.[Bit],av.[FieldElementID],fmel.[Text],av.[Position],av.[MEPosition]
		FROM AllValues as av
			INNER JOIN dbo.[dnn_EasyDNNfieldsMultiElementsLocalization] AS fmel ON av.FieldElementID = fmel.FieldElementID AND fmel.LocaleCode = @LocaleCode
	),
	CombinedValues ([ArticleID],[CustomFieldID],[ControlTypeID],[Token],[ShowLabel],[LabelValue],[LabelHelp],[IsParent],[IconURL],[ACode],[DisplayFormat],[RText],[Decimal],[Int],[Bit],[FieldElementID],[Text],[Position],[MEPosition]) AS(
		--u zadnjem redu ovo field element is nul null to je zato jer se prilikom joina maknul,.. jer se pretpostavlja da je null
		SELECT * FROM LocalizedSingleValues
		UNION ALL
		SELECT * FROM LocalizedMultiValues
		UNION ALL
		SELECT * FROM AllValues WHERE (CustomFieldID NOT IN (SELECT CustomFieldID FROM LocalizedSingleValues)) AND ((FieldElementID NOT IN (SELECT FieldElementID FROM LocalizedMultiValues)) OR FieldElementID IS NULL)
	),
	LocalizedLabelsAndFinalize ([ArticleID],[CustomFieldID],[ControlTypeID],[Token],[ShowLabel],[LabelValue],[LabelHelp],[IsParent],[IconURL],[ACode],[DisplayFormat],[RText],[Decimal],[Int],[Bit],[FieldElementID],[Text],[Position],[MEPosition]) AS(
		SELECT cv.[ArticleID],cv.[CustomFieldID],cv.[ControlTypeID],cv.[Token],cv.[ShowLabel],fl.[LabelValue],fl.[LabelHelp],cv.[IsParent],
			cv.[IconURL],cv.[ACode],cv.[DisplayFormat],cv.[RText],cv.[Decimal],cv.[Int],cv.[Bit],cv.[FieldElementID],cv.[Text],cv.[Position],cv.[MEPosition]
		FROM CombinedValues as cv
			INNER JOIN dbo.[dnn_EasyDNNfieldsLocalization] AS fl ON cv.CustomFieldID = fl.CustomFieldID AND fl.LocaleCode = @LocaleCode
	)
	SELECT * FROM LocalizedLabelsAndFinalize
	UNION ALL
	SELECT * FROM CombinedValues WHERE CustomFieldID NOT IN (SELECT CustomFieldID FROM LocalizedLabelsAndFinalize)  ORDER BY [Position], [MEPosition];
END

