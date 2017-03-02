CREATE PROCEDURE [dbo].[dnn_DeleteTab]
    @TabId Int  -- ID of tab to delete; Not Null and > 0
AS
BEGIN
    DECLARE @TabOrder Int
    DECLARE @ParentId Int
    DECLARE @ContentItemId Int
    SELECT @TabOrder = TabOrder, @ParentId = ParentID, @ContentItemID = ContentItemID FROM dbo.[dnn_Tabs] WHERE TabID = @TabId

    -- Delete Tab --
    DELETE FROM dbo.[dnn_Tabs] WHERE  TabID = @TabId

    -- Update TabOrder of remaining Tabs --
    UPDATE dbo.[dnn_Tabs]
        SET TabOrder = TabOrder - 2
        WHERE IsNull(ParentID, -1) = IsNull(@ParentId , -1) AND TabOrder > @TabOrder

    -- Delete Content Item --
    DELETE FROM dbo.[dnn_ContentItems] WHERE ContentItemID = @ContentItemId
END

