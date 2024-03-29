CREATE TABLE [Casix].[Opname]
(
[ID] [bigint] NULL,
[Opnamenummer] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[DatumAfspraak] [datetime2] (0) NULL,
[TijdsduurUren] [float] NULL,
[PostcodeNieuw] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[HuisnummerNieuw] [bigint] NULL,
[HuisnummerToevoegingNieuw] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[StraatNieuw] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[PlaatsNieuw] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[LandNieuw] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[ElektriciteitStand1] [bigint] NULL,
[ElektriciteitStand2] [bigint] NULL,
[ElektriciteitTerugleveringStand1] [bigint] NULL,
[ElektriciteitTerugleveringStand2] [bigint] NULL,
[GasStand] [bigint] NULL,
[WarmteStand] [float] NULL,
[WarmTapwaterStand] [bigint] NULL,
[OpmerkingOpname] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[HuurderAkkoord] [bit] NULL,
[Opnamestatus] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[OpnamestatusDatum] [datetime2] (0) NULL,
[BedragHuurderVertrekkendTeBetalenHerstelVerhuurder] [float] NULL,
[BedragHuurderVertrekkendTeBetalenHerstelHuurder] [float] NULL,
[BedragHuurderVertrekkendTeBetalenZAVTegemoetkoming] [float] NULL,
[BedragHuurderVertrekkendTeBetalenZAVMagNietAchterblijven] [float] NULL,
[BedragHuurderVertrekkendTeBetalenSleutelsOntbrekend] [float] NULL,
[BedragHuurderVertrekkendTeBetalen] [float] NULL,
[BedragHuurderVertrekkendBetaald] [float] NULL,
[BedragHuurderVertrekkendNogTeBetalen] [float] NULL,
[BedragHuurderNieuwTeBetalen] [float] NULL,
[BedragHuurderNieuwBetaald] [float] NULL,
[BedragHuurderNieuwNogTeBetalen] [float] NULL,
[IsHuurderOverleden] [bit] NULL,
[IsMedehuurderOverleden] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[AdresVolledigNieuw] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[ZaakExternID] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[ExternID] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[AansluitendVerhuurbaar] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[BeschikbaarNieuweVerhuur] [datetime2] (0) NULL,
[BeschikbaarNieuweVerhuurderDefinitief] [bit] NULL,
[BeschikbaarWerkzaamheden] [datetime2] (0) NULL,
[ExternIDAfrekeningKosten] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[ExternIDAfrekeningVergoedingen] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[OpnameIntakeWerkzaamhedenDatumAfspraak] [datetime2] (0) NULL,
[OpleveringGeaccepteerd] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Opname_Opnametype] [bigint] NULL,
[Opname_Opnamestatus] [bigint] NULL,
[Opname_Verblijfsobject] [bigint] NULL,
[Opname_Huurcontract] [bigint] NULL,
[Opname__Taal] [bigint] NULL,
[Opname_AannemerOplevering] [bigint] NULL,
[TypeOpname] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Opname_Onderhoudsverzoek] [bigint] NULL,
[WaterStand1] [bigint] NULL,
[WaterStand2] [bigint] NULL,
[Opname_ExtraWerkzaamhedentypeOplevering] [bigint] NULL,
[Adres] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[Opname_GebruikerOpzichter] [bigint] NULL,
[changedDate] [datetime2] (0) NULL,
[Warmtepomp] [bigint] NULL
) ON [PRIMARY]
GO
