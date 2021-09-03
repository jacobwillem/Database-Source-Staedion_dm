SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create VIEW [Medewerker].[ActiveDirectory]
AS
-- Roelof: Krijg je wel de volledige lijst. 
-- ADSI heeft de onhebbelijkheid maximaal 901 records op te kunnen halen, daar werk ik omheen door het in 2 delen op te halen eerst inlogcodes < ‘m’ 
-- en vervolgens met een union >= ‘m’ mocht het aantal ad user boven de 2500 uit gaan komen moet je het misschien wel in 3 of nog meer delen opsplitsen.

SELECT displayName,
       sAMAccountName,
       sn,
       givenName,
       title,
       department,
       mail,
       ipPhone,
       employeeNumber,
       telephoneNumber,
       mobile,
       facsimileTelephoneNumber,
       info,
       accountExpires
FROM OPENQUERY(ADSI,
       '<LDAP://staedion.local/DC=STAEDION,DC=LOCAL>;
       (&(objectCategory=person)(objectClass=user)(sAMAccountName<=m));
displayName,sAMAccountName,sn,givenName,title,department,mail,ipPhone,employeeNumber,telephoneNumber,mobile,facsimileTelephoneNumber,info,accountExpires,
       cn,ADsPath;subtree')
union
SELECT displayName,
       sAMAccountName,
       sn,
       givenName,
       title,
       department,
       mail,
       ipPhone,
       employeeNumber,
       telephoneNumber,
       mobile,
       facsimileTelephoneNumber,
       info,
       accountExpires
FROM OPENQUERY(ADSI,
       '<LDAP://staedion.local/DC=STAEDION,DC=LOCAL>;
       (&(objectCategory=person)(objectClass=user)(sAMAccountName>=m*));
displayName,sAMAccountName,sn,givenName,title,department,mail,ipPhone,employeeNumber,telephoneNumber,mobile,facsimileTelephoneNumber,info,accountExpires,
       cn,ADsPath;subtree')

GO
