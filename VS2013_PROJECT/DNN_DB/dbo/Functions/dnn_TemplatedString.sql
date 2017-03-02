-- added for easier string handling
CREATE FUNCTION [dbo].[dnn_TemplatedString]
(
    @template nVarChar(3500), -- use tokens @1, @2, @3, @4, @5 to be replaced by param1 .. param5
    @param1   nVarChar( 100) = '', -- empty param values will just remove token!
	@param2	  nVarChar( 100) = '',
	@param3	  nVarChar( 100) = '',
	@param4	  nVarChar( 100) = '',
	@param5	  nVarChar( 100) = ''
)
	RETURNS   nVarChar(4000)
AS
BEGIN
    RETURN REPLACE(
			REPLACE(
			 REPLACE(
			  REPLACE(
			   REPLACE(IsNull(@template, ''), 
					   N'@1', IsNull(@param1,'')), 
					  N'@2', IsNull(@param2,'')), 
					 N'@3', IsNull(@param3,'')), 
					N'@4', IsNull(@param4,'')), 
				   N'@5', IsNull(@param5,''))
END

