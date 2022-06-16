SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [Eenheden].[fn_ContactbeheerNaam] (@RelatieNr varchar(20))
RETURNS VARCHAR(100)
AS

/* #####################################################################################
VAN			JvdW
BETREFT	Te gebruiken in combinatie met ITCFContactbeheer: daar staat alleen RLST-nr
----------------------------------------------------------------------------------------
WIJZIGINGEN	
20201119 JvdW
20210201 JvdW Kopie van empire_staedion_data: relevante functies en views en procedures in 1 database met schema's onderbrengen

##################################################################################### */

BEGIN
	Declare @Name as nvarchar(100)
	select @Name = Name from empire_data.dbo.Contact where No_ = @RelatieNr
	RETURN 
		@Name
END
GO
