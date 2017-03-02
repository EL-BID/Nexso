CREATE FUNCTION [dbo].[dnn_HasChildTab]
(
   @TabId   Int
) 
	RETURNS Bit
AS
BEGIN
    RETURN CASE WHEN EXISTS (SELECT 1 FROM dbo.dnn_Tabs WHERE ParentId = @TabId) THEN 1 ELSE 0 END
END

