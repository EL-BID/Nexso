CREATE PROCEDURE [dbo].[dnn_EasyDNNfieldsEventRegistrationGetValues]
(
	@EventUserItemID INT,
	@FieldsTemplateID INT,
	@LocaleCode	NVARCHAR(20) = NULL,
	@ShowHiddenFields BIT
)
AS
SET NOCOUNT ON;    
SELECT fv.[EventUserItemID], cf.[CustomFieldID],cf.[ControlTypeID],cf.[Token],cf.[ShowLabel],cf.[LabelValue],cf.[LabelHelp],cf.[IsParent],cf.[IconURL],cf.[ACode],cf.[DisplayFormat],fv.[RText],fv.[Decimal],fv.[Int],fv.[Bit],NULL AS [FieldElementID],fv.[Text],gt.[Position],NULL AS [MEPosition]
FROM dbo.[dnn_EasyDNNfields] AS cf
	INNER JOIN dbo.[dnn_EasyDNNfieldsTemplateItems] AS gt ON cf.[CustomFieldID] = gt.[CustomFieldID]
	INNER JOIN dbo.[dnn_EasyDNNfieldsRegistrationValues] as fv ON cf.[CustomFieldID] = fv.[CustomFieldID]
WHERE cf.[IsPublished] = 1 AND (@ShowHiddenFields = 1 OR cf.[IsHidden] = @ShowHiddenFields) AND gt.[FieldsTemplateID] = @FieldsTemplateID AND fv.[EventUserItemID] = @EventUserItemID
UNION ALL
SELECT fms.[EventUserItemID], cf.[CustomFieldID],cf.[ControlTypeID],cf.[Token],cf.[ShowLabel],cf.[LabelValue],cf.[LabelHelp],cf.[IsParent],cf.[IconURL],NULL AS [ACode],NULL AS [DisplayFormat],NULL as [RText], NULL AS [Decimal],NULL AS [Int],NULL AS [Bit],fme.[FieldElementID],fme.[Text],gt.[Position],fme.[Position] AS [MEPosition]
FROM dbo.[dnn_EasyDNNfields] as cf INNER JOIN dbo.[dnn_EasyDNNfieldsTemplateItems] AS gt ON cf.[CustomFieldID] = gt.[CustomFieldID]
	INNER JOIN dbo.[dnn_EasyDNNfieldsMultiElements] as fme ON cf.[CustomFieldID] = fme.[CustomFieldID]
	LEFT OUTER JOIN dbo.[dnn_EasyDNNfieldsRegistrationMultiSelected] as fms ON cf.[CustomFieldID] = fms.[CustomFieldID] AND fme.[FieldElementID] = fms.[FieldElementID] AND ((cf.[ShowAllMultiElements] = 0 AND fms.[EventUserItemID] = @EventUserItemID) OR (cf.[ShowAllMultiElements] = 1 AND (fms.[EventUserItemID] = @EventUserItemID OR (fms.[EventUserItemID] IS NULL AND cf.[ControlTypeID] = 23))))
WHERE cf.[IsPublished] = 1 AND (@ShowHiddenFields = 1 OR cf.[IsHidden] = @ShowHiddenFields) AND gt.[FieldsTemplateID] = @FieldsTemplateID AND ((cf.[ShowAllMultiElements] = 0 AND fms.[EventUserItemID] = @EventUserItemID) OR (cf.[ShowAllMultiElements] = 1 AND (fms.[EventUserItemID] = @EventUserItemID OR (fms.[EventUserItemID] IS NULL AND cf.[ControlTypeID] = 23))))
ORDER BY [Position], [MEPosition];

