SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [Dashboard].[sp_update_autorisatie]
AS
BEGIN

	BEGIN

	DELETE
	FROM [Dashboard].[Autorisatie]
	WHERE [Account] IN
	(SELECT [Werk email] FROM [Medewerker].[TalentVisma] WHERE [Datum Uit Dienst] < GETDATE() AND [Werk email] IS NOT NULL)

	END
END
GO
