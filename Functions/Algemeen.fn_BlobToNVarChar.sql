SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [Algemeen].[fn_BlobToNVarChar] (@sqlBinary [varbinary] (max))
RETURNS [nvarchar] (max)
WITH EXECUTE AS CALLER
EXTERNAL NAME [BlobToText].[BlobToText].[BlobToNVarChar]
GO
