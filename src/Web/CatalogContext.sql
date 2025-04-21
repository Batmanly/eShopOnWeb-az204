IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
CREATE SEQUENCE [catalog_brand_hilo] START WITH 1 INCREMENT BY 10 NO CYCLE;

CREATE SEQUENCE [catalog_hilo] START WITH 1 INCREMENT BY 10 NO CYCLE;

CREATE SEQUENCE [catalog_type_hilo] START WITH 1 INCREMENT BY 10 NO CYCLE;

CREATE TABLE [Baskets] (
    [Id] int NOT NULL IDENTITY,
    [BuyerId] nvarchar(40) NOT NULL,
    CONSTRAINT [PK_Baskets] PRIMARY KEY ([Id])
);

CREATE TABLE [CatalogBrands] (
    [Id] int NOT NULL,
    [Brand] nvarchar(100) NOT NULL,
    CONSTRAINT [PK_CatalogBrands] PRIMARY KEY ([Id])
);

CREATE TABLE [CatalogTypes] (
    [Id] int NOT NULL,
    [Type] nvarchar(100) NOT NULL,
    CONSTRAINT [PK_CatalogTypes] PRIMARY KEY ([Id])
);

CREATE TABLE [Orders] (
    [Id] int NOT NULL IDENTITY,
    [BuyerId] nvarchar(max) NULL,
    [OrderDate] datetimeoffset NOT NULL,
    [ShipToAddress_Street] nvarchar(180) NULL,
    [ShipToAddress_City] nvarchar(100) NULL,
    [ShipToAddress_State] nvarchar(60) NULL,
    [ShipToAddress_Country] nvarchar(90) NULL,
    [ShipToAddress_ZipCode] nvarchar(18) NULL,
    CONSTRAINT [PK_Orders] PRIMARY KEY ([Id])
);

CREATE TABLE [BasketItems] (
    [Id] int NOT NULL IDENTITY,
    [UnitPrice] decimal(18,2) NOT NULL,
    [Quantity] int NOT NULL,
    [CatalogItemId] int NOT NULL,
    [BasketId] int NOT NULL,
    CONSTRAINT [PK_BasketItems] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_BasketItems_Baskets_BasketId] FOREIGN KEY ([BasketId]) REFERENCES [Baskets] ([Id]) ON DELETE CASCADE
);

CREATE TABLE [Catalog] (
    [Id] int NOT NULL,
    [Name] nvarchar(50) NOT NULL,
    [Description] nvarchar(max) NULL,
    [Price] decimal(18,2) NOT NULL,
    [PictureUri] nvarchar(max) NULL,
    [CatalogTypeId] int NOT NULL,
    [CatalogBrandId] int NOT NULL,
    CONSTRAINT [PK_Catalog] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Catalog_CatalogBrands_CatalogBrandId] FOREIGN KEY ([CatalogBrandId]) REFERENCES [CatalogBrands] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_Catalog_CatalogTypes_CatalogTypeId] FOREIGN KEY ([CatalogTypeId]) REFERENCES [CatalogTypes] ([Id]) ON DELETE CASCADE
);

CREATE TABLE [OrderItems] (
    [Id] int NOT NULL IDENTITY,
    [ItemOrdered_CatalogItemId] int NULL,
    [ItemOrdered_ProductName] nvarchar(50) NULL,
    [ItemOrdered_PictureUri] nvarchar(max) NULL,
    [UnitPrice] decimal(18,2) NOT NULL,
    [Units] int NOT NULL,
    [OrderId] int NULL,
    CONSTRAINT [PK_OrderItems] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_OrderItems_Orders_OrderId] FOREIGN KEY ([OrderId]) REFERENCES [Orders] ([Id]) ON DELETE NO ACTION
);

CREATE INDEX [IX_BasketItems_BasketId] ON [BasketItems] ([BasketId]);

CREATE INDEX [IX_Catalog_CatalogBrandId] ON [Catalog] ([CatalogBrandId]);

CREATE INDEX [IX_Catalog_CatalogTypeId] ON [Catalog] ([CatalogTypeId]);

CREATE INDEX [IX_OrderItems_OrderId] ON [OrderItems] ([OrderId]);

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20201202111507_InitialModel', N'9.0.3');

DECLARE @var0 sysname;
SELECT @var0 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Orders]') AND [c].[name] = N'BuyerId');
IF @var0 IS NOT NULL EXEC(N'ALTER TABLE [Orders] DROP CONSTRAINT [' + @var0 + '];');
UPDATE [Orders] SET [BuyerId] = N'' WHERE [BuyerId] IS NULL;
ALTER TABLE [Orders] ALTER COLUMN [BuyerId] nvarchar(256) NOT NULL;
ALTER TABLE [Orders] ADD DEFAULT N'' FOR [BuyerId];

DECLARE @var1 sysname;
SELECT @var1 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Baskets]') AND [c].[name] = N'BuyerId');
IF @var1 IS NOT NULL EXEC(N'ALTER TABLE [Baskets] DROP CONSTRAINT [' + @var1 + '];');
ALTER TABLE [Baskets] ALTER COLUMN [BuyerId] nvarchar(256) NOT NULL;

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20211026175614_FixBuyerId', N'9.0.3');

DECLARE @var2 sysname;
SELECT @var2 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Orders]') AND [c].[name] = N'ShipToAddress_ZipCode');
IF @var2 IS NOT NULL EXEC(N'ALTER TABLE [Orders] DROP CONSTRAINT [' + @var2 + '];');
UPDATE [Orders] SET [ShipToAddress_ZipCode] = N'' WHERE [ShipToAddress_ZipCode] IS NULL;
ALTER TABLE [Orders] ALTER COLUMN [ShipToAddress_ZipCode] nvarchar(18) NOT NULL;
ALTER TABLE [Orders] ADD DEFAULT N'' FOR [ShipToAddress_ZipCode];

DECLARE @var3 sysname;
SELECT @var3 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Orders]') AND [c].[name] = N'ShipToAddress_Street');
IF @var3 IS NOT NULL EXEC(N'ALTER TABLE [Orders] DROP CONSTRAINT [' + @var3 + '];');
UPDATE [Orders] SET [ShipToAddress_Street] = N'' WHERE [ShipToAddress_Street] IS NULL;
ALTER TABLE [Orders] ALTER COLUMN [ShipToAddress_Street] nvarchar(180) NOT NULL;
ALTER TABLE [Orders] ADD DEFAULT N'' FOR [ShipToAddress_Street];

DECLARE @var4 sysname;
SELECT @var4 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Orders]') AND [c].[name] = N'ShipToAddress_Country');
IF @var4 IS NOT NULL EXEC(N'ALTER TABLE [Orders] DROP CONSTRAINT [' + @var4 + '];');
UPDATE [Orders] SET [ShipToAddress_Country] = N'' WHERE [ShipToAddress_Country] IS NULL;
ALTER TABLE [Orders] ALTER COLUMN [ShipToAddress_Country] nvarchar(90) NOT NULL;
ALTER TABLE [Orders] ADD DEFAULT N'' FOR [ShipToAddress_Country];

DECLARE @var5 sysname;
SELECT @var5 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Orders]') AND [c].[name] = N'ShipToAddress_City');
IF @var5 IS NOT NULL EXEC(N'ALTER TABLE [Orders] DROP CONSTRAINT [' + @var5 + '];');
UPDATE [Orders] SET [ShipToAddress_City] = N'' WHERE [ShipToAddress_City] IS NULL;
ALTER TABLE [Orders] ALTER COLUMN [ShipToAddress_City] nvarchar(100) NOT NULL;
ALTER TABLE [Orders] ADD DEFAULT N'' FOR [ShipToAddress_City];

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20211231093753_FixShipToAddress', N'9.0.3');

DECLARE @var6 sysname;
SELECT @var6 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Orders]') AND [c].[name] = N'ShipToAddress_State');
IF @var6 IS NOT NULL EXEC(N'ALTER TABLE [Orders] DROP CONSTRAINT [' + @var6 + '];');
UPDATE [Orders] SET [ShipToAddress_State] = N'' WHERE [ShipToAddress_State] IS NULL;
ALTER TABLE [Orders] ALTER COLUMN [ShipToAddress_State] nvarchar(60) NOT NULL;
ALTER TABLE [Orders] ADD DEFAULT N'' FOR [ShipToAddress_State];

DECLARE @var7 sysname;
SELECT @var7 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[OrderItems]') AND [c].[name] = N'ItemOrdered_ProductName');
IF @var7 IS NOT NULL EXEC(N'ALTER TABLE [OrderItems] DROP CONSTRAINT [' + @var7 + '];');
UPDATE [OrderItems] SET [ItemOrdered_ProductName] = N'' WHERE [ItemOrdered_ProductName] IS NULL;
ALTER TABLE [OrderItems] ALTER COLUMN [ItemOrdered_ProductName] nvarchar(50) NOT NULL;
ALTER TABLE [OrderItems] ADD DEFAULT N'' FOR [ItemOrdered_ProductName];

DECLARE @var8 sysname;
SELECT @var8 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[OrderItems]') AND [c].[name] = N'ItemOrdered_PictureUri');
IF @var8 IS NOT NULL EXEC(N'ALTER TABLE [OrderItems] DROP CONSTRAINT [' + @var8 + '];');
UPDATE [OrderItems] SET [ItemOrdered_PictureUri] = N'' WHERE [ItemOrdered_PictureUri] IS NULL;
ALTER TABLE [OrderItems] ALTER COLUMN [ItemOrdered_PictureUri] nvarchar(max) NOT NULL;
ALTER TABLE [OrderItems] ADD DEFAULT N'' FOR [ItemOrdered_PictureUri];

DECLARE @var9 sysname;
SELECT @var9 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[OrderItems]') AND [c].[name] = N'ItemOrdered_CatalogItemId');
IF @var9 IS NOT NULL EXEC(N'ALTER TABLE [OrderItems] DROP CONSTRAINT [' + @var9 + '];');
UPDATE [OrderItems] SET [ItemOrdered_CatalogItemId] = 0 WHERE [ItemOrdered_CatalogItemId] IS NULL;
ALTER TABLE [OrderItems] ALTER COLUMN [ItemOrdered_CatalogItemId] int NOT NULL;
ALTER TABLE [OrderItems] ADD DEFAULT 0 FOR [ItemOrdered_CatalogItemId];

DECLARE @var10 sysname;
SELECT @var10 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Catalog]') AND [c].[name] = N'Description');
IF @var10 IS NOT NULL EXEC(N'ALTER TABLE [Catalog] DROP CONSTRAINT [' + @var10 + '];');
UPDATE [Catalog] SET [Description] = N'' WHERE [Description] IS NULL;
ALTER TABLE [Catalog] ALTER COLUMN [Description] nvarchar(max) NOT NULL;
ALTER TABLE [Catalog] ADD DEFAULT N'' FOR [Description];

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250207163746_MissingMigration20250207', N'9.0.3');

DECLARE @var11 sysname;
SELECT @var11 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Orders]') AND [c].[name] = N'ShipToAddress_State');
IF @var11 IS NOT NULL EXEC(N'ALTER TABLE [Orders] DROP CONSTRAINT [' + @var11 + '];');
UPDATE [Orders] SET [ShipToAddress_State] = N'' WHERE [ShipToAddress_State] IS NULL;
ALTER TABLE [Orders] ALTER COLUMN [ShipToAddress_State] nvarchar(60) NOT NULL;
ALTER TABLE [Orders] ADD DEFAULT N'' FOR [ShipToAddress_State];

DECLARE @var12 sysname;
SELECT @var12 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[OrderItems]') AND [c].[name] = N'ItemOrdered_ProductName');
IF @var12 IS NOT NULL EXEC(N'ALTER TABLE [OrderItems] DROP CONSTRAINT [' + @var12 + '];');
UPDATE [OrderItems] SET [ItemOrdered_ProductName] = N'' WHERE [ItemOrdered_ProductName] IS NULL;
ALTER TABLE [OrderItems] ALTER COLUMN [ItemOrdered_ProductName] nvarchar(50) NOT NULL;
ALTER TABLE [OrderItems] ADD DEFAULT N'' FOR [ItemOrdered_ProductName];

DECLARE @var13 sysname;
SELECT @var13 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[OrderItems]') AND [c].[name] = N'ItemOrdered_PictureUri');
IF @var13 IS NOT NULL EXEC(N'ALTER TABLE [OrderItems] DROP CONSTRAINT [' + @var13 + '];');
UPDATE [OrderItems] SET [ItemOrdered_PictureUri] = N'' WHERE [ItemOrdered_PictureUri] IS NULL;
ALTER TABLE [OrderItems] ALTER COLUMN [ItemOrdered_PictureUri] nvarchar(max) NOT NULL;
ALTER TABLE [OrderItems] ADD DEFAULT N'' FOR [ItemOrdered_PictureUri];

DECLARE @var14 sysname;
SELECT @var14 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[OrderItems]') AND [c].[name] = N'ItemOrdered_CatalogItemId');
IF @var14 IS NOT NULL EXEC(N'ALTER TABLE [OrderItems] DROP CONSTRAINT [' + @var14 + '];');
UPDATE [OrderItems] SET [ItemOrdered_CatalogItemId] = 0 WHERE [ItemOrdered_CatalogItemId] IS NULL;
ALTER TABLE [OrderItems] ALTER COLUMN [ItemOrdered_CatalogItemId] int NOT NULL;
ALTER TABLE [OrderItems] ADD DEFAULT 0 FOR [ItemOrdered_CatalogItemId];

DECLARE @var15 sysname;
SELECT @var15 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Catalog]') AND [c].[name] = N'Description');
IF @var15 IS NOT NULL EXEC(N'ALTER TABLE [Catalog] DROP CONSTRAINT [' + @var15 + '];');
UPDATE [Catalog] SET [Description] = N'' WHERE [Description] IS NULL;
ALTER TABLE [Catalog] ALTER COLUMN [Description] nvarchar(max) NOT NULL;
ALTER TABLE [Catalog] ADD DEFAULT N'' FOR [Description];

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20250310153034_Updates', N'9.0.3');

COMMIT;
GO

