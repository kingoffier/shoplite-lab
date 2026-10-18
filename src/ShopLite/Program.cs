using ShopLite;

if (args.Contains("--smoke"))
{
    var ok = Checkout.Calculate(1000m) == 1300m;
    Console.WriteLine(ok ? "SMOKE OK" : "SMOKE FAILED");
    return ok ? 0 : 1;
}
Console.WriteLine("ShopLite — учебный магазин");
Console.WriteLine($"Товары: 1 000 руб. Итог с доставкой: {Checkout.Calculate(1000m):F2} руб.");
return 0;
