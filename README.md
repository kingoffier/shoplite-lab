# ShopLite — Git production lab

Учебный магазин на C# / .NET 8: сумма заказа, доставка, купоны и VIP-скидка.
Это небольшой консольный проект для изучения Git в Visual Studio.

История создана специально для тренировки. Имена разработчиков вымышлены;
обозначения review в документах — сценарий, а не настоящие PR на GitHub.
Локальные staging и production — папки с опубликованными сборками, не облачные серверы.
Все учебные коммиты и реальные локальные проверки созданы в ходе одной сессии.

## Запуск

Откройте ShopLite.sln в Visual Studio 2022 с поддержкой .NET 8.

```powershell
dotnet run --project src/ShopLite
dotnet run --project tests/ShopLite.Checks
```

Проверки — собственный консольный runner без внешних NuGet-пакетов.
Он возвращает ненулевой код при ошибке. `dotnet test` их не запускает.

Полный курс: [docs/LAB.md](docs/LAB.md).
История релизов: [CHANGELOG.md](CHANGELOG.md).
