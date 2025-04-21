{
    "baseUrls": {
        "apiBase": "https://${ API_URL }/api/",
        "webBase": "https://${ WEB_URL }/"
    },
    "ConnectionStrings": {
        "CatalogConnection": "Server=tcp:your-server-name.database.windows.net,1433;Initial Catalog=Microsoft.eShopOnWeb.CatalogDb;Persist Security Info=False;User ID=your-username;Password=your-password;MultipleActiveResultSets=True;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;",
        "IdentityConnection": "Server=tcp:your-server-name.database.windows.net,1433;Initial Catalog=Microsoft.eShopOnWeb.Identity;Persist Security Info=False;User ID=your-username;Password=your-password;MultipleActiveResultSets=True;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    },
    "UseOnlyInMemoryDatabase": false,
    "CatalogBaseUrl": "",
    "Logging": {
        "IncludeScopes": false,
        "LogLevel": {
            "Default": "Warning",
            "Microsoft": "Warning",
            "System": "Warning"
        },
        "AllowedHosts": "*"
    }
}


