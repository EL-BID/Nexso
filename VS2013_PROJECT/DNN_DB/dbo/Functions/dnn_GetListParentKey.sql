CREATE FUNCTION [dbo].[dnn_GetListParentKey]
(
	@ParentID AS int,
	@ListName as nvarchar(500),
	@Type as nvarchar(50),
	@Count as int 
)
RETURNS nvarchar(2000)

AS
	BEGIN
		DECLARE @KeyValue nvarchar(2000)
		DECLARE @ListValue nvarchar(2000)
		DECLARE @TextValue nvarchar(2000)
		DECLARE @ReturnValue nvarchar(2000)
		DECLARE @Key nvarchar(2000)
		
		IF @ParentID = 0
			IF @Count = 0
				SET @ReturnValue = ''
			ELSE
				SET @ReturnValue = @ListName
		ELSE
			BEGIN
				SELECT	@KeyValue = ListName + '.' + [Value],
						@TextValue = ListName + '.' + [Text], 
						@ListValue = ListName, 
						@ParentID = ParentID  
					FROM dbo.dnn_Lists 
					WHERE EntryID = @ParentID
				If @Type = 'ParentKey' Or (@Type = 'ParentList' AND @Count > 0)
					SET @ReturnValue = @KeyValue
				ELSE 
					IF @Type = 'ParentList'
						SET @ReturnValue = @ListValue
					ELSE
						SET @ReturnValue = @TextValue
				IF @Count > 0
					If @Count = 1 AND @Type = 'ParentList'
						SET @ReturnValue = @ReturnValue + ':' + @ListName
					ELSE
						SET @ReturnValue = @ReturnValue + '.' + @ListName
				SET @ReturnValue = dbo.dnn_GetListParentKey(@ParentID, @ReturnValue, @Type, @Count+1)
			END

		RETURN    @ReturnValue
	END

