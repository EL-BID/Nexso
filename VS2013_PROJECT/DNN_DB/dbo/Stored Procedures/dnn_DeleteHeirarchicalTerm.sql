CREATE PROCEDURE [dbo].[dnn_DeleteHeirarchicalTerm]	
    @TermId			int    
AS
BEGIN
    DECLARE @Left int, @Right int, @VocabularyID int, @Width int

	SELECT
		@Left = tt.TermLeft
		, @Right = tt.TermRight
		, @VocabularyID = tt.VocabularyID
		, @Width = @Right - @Left + 1
	FROM
		dbo.dnn_Taxonomy_Terms tt
	WHERE
		tt.TermID = @TermID

	BEGIN TRANSACTION

	-- Delete term(s)
	DELETE FROM dbo.dnn_Taxonomy_Terms
	WHERE TermLeft > = @Left AND TermLeft > 0
	  AND TermRight <= @Right AND TermRight > 0
	  AND VocabularyID = @VocabularyID

	IF @@ERROR = 0
	BEGIN
		-- Update Left values for all items that are after deleted term
		UPDATE dbo.dnn_Taxonomy_Terms
	    SET TermLeft = TermLeft - @Width
		WHERE TermLeft >= @Left + @Width
			AND VocabularyID = @VocabularyID

        IF @@ERROR = 0
        BEGIN
            -- Update Right values for all items that are after deleted term
            UPDATE dbo.dnn_Taxonomy_Terms
            SET TermRight = TermRight - @Width
            WHERE TermRight >= @Right
                AND VocabularyID = @VocabularyID

            IF @@ERROR = 0
            BEGIN
                COMMIT TRANSACTION
                RETURN
            END
        END
    END
    
	ROLLBACK TRANSACTION
END

