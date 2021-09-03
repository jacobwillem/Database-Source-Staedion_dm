CREATE TABLE [Projecten].[BudgetRegelStatus]
(
[id] [int] NOT NULL,
[RegelStatus] [nvarchar] (30) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Projecten].[BudgetRegelStatus] ADD CONSTRAINT [PK_BudgetRegelStatus] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
