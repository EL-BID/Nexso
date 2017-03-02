CREATE FUNCTION [dbo].[dnn_GetUsersByPropertyName]
(
	@PropertyName nvarchar(100),
	@PropertyValue nvarchar(max),
	@PortalID int
)
RETURNS TABLE
AS
	RETURN
		SELECT *
			FROM dbo.[dnn_vw_Profile]
			WHERE PropertyName = @PropertyName 
				AND PropertyValue LIKE @PropertyValue
				AND PortalID = @PortalID

