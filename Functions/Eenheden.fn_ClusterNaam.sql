SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE function [Eenheden].[fn_ClusterNaam] (@ClusterNr varchar(20))
RETURNS VARCHAR(100)
AS

/* #####################################################################################
VAN			JvdW
BETREFT	Te gebruiken in combinatie met fn_CLusterBouwblok
----------------------------------------------------------------------------------------
WIJZIGINGEN	
20220512 JvdW

##################################################################################### */

BEGIN
	Declare @Name as nvarchar(100)
	select @Name = Naam from empire_data.dbo.Staedion$Cluster where Nr_ = @ClusterNr
	RETURN 
		coalesce(@Name,'')
END
GO
