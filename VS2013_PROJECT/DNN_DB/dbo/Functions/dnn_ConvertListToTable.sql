CREATE FUNCTION [dbo].[dnn_ConvertListToTable]
(  
	@Delimiter	nvarchar(5), 
    @List		nvarchar(max)
) 
RETURNS @TableOfValues TABLE 
(  
	RowNumber	smallint IDENTITY(1,1), 
    RowValue	nvarchar(50) 
) 
AS 
   BEGIN
      DECLARE @LenString int 
 
      WHILE len( @List ) > 0 
         BEGIN 
         
            SELECT @LenString = 
               (CASE charindex( @Delimiter, @List ) 
                   WHEN 0 THEN len( @List ) 
                   ELSE ( charindex( @Delimiter, @List ) -1 )
                END
               ) 
                                
            INSERT INTO @TableOfValues 
               SELECT substring( @List, 1, @LenString )
                
            SELECT @List = 
               (CASE ( len( @List ) - @LenString ) 
                   WHEN 0 THEN '' 
                   ELSE right( @List, len( @List ) - @LenString - 1 ) 
                END
               ) 
         END
      RETURN 
   END

