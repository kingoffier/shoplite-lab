using ShopLite;

if (args.Contains("--smoke"))
{
    var ok = Checkout.Calculate(1000m) == 1300m;
    Console.WriteLine(ok ? "SMOKE OK" : "SMOKE FAILED");
    return ok ? 0 : 1;
}
if (args.Contains("--probe-loyalty"))
{
    var actual = Checkout.CalculateVip(10000m);
    Console.WriteLine($"VIP probe: expected=9000 actual={actual}");
    return actual == 9000m ? 0 : 2;
}
Console.WriteLine("ShopLite — учебный магазин");
Console.WriteLine($"Товары: 1 000 руб. Итог с доставкой: {Checkout.Calculate(1000m):F2} руб.");
Console.WriteLine($"VIP order 10 000 RUB: {Checkout.CalculateVip(10000m):F2} RUB");
return 0;
