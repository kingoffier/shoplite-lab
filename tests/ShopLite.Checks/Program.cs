using ShopLite;

var failures = new List<string>();
void Equal(string name, decimal expected, decimal actual)
{
    if (expected != actual) failures.Add($"{name}: expected {expected}, actual {actual}");
    else Console.WriteLine($"PASS {name}");
}
#pragma warning disable CS8321
void Throws(string name, Action action)
{
    try { action(); failures.Add($"{name}: expected ArgumentOutOfRangeException"); }
    catch (ArgumentOutOfRangeException) { Console.WriteLine($"PASS {name}"); }
}
Equal("small order includes delivery", 1300m, Checkout.Calculate(1000m));
Equal("large order has free delivery", 5000m, Checkout.Calculate(5000m));
Equal("quantity", 1500m, Checkout.Subtotal(500m, 3));
Throws("negative subtotal", () => Checkout.Calculate(-1m));
Throws("invalid quantity", () => Checkout.Subtotal(500m, 0));
Throws("negative unit price", () => Checkout.Subtotal(-1m, 2));
Equal("ten percent coupon", 1200m, Checkout.Calculate(1000m, 10m));
Equal("currency rounding", 300.91m, Checkout.Calculate(1.01m, 10m));
Throws("invalid coupon", () => Checkout.Calculate(1000m, 101m));
Equal("exact free shipping threshold", 3500m, Checkout.Calculate(3500m));
Equal("just below threshold", 3799.99m, Checkout.Calculate(3499.99m));
Equal("ordinary VIP order", 4500m, Checkout.CalculateVip(5000m));
Equal("high value VIP order", 9000m, Checkout.CalculateVip(10000m));
Equal("above boundary VIP order", 18000m, Checkout.CalculateVip(20000m));
// Additional regression cases are added as the product evolves.
foreach (var failure in failures) Console.Error.WriteLine("FAIL " + failure);
return failures.Count == 0 ? 0 : 1;
