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
// Additional regression cases are added as the product evolves.
foreach (var failure in failures) Console.Error.WriteLine("FAIL " + failure);
return failures.Count == 0 ? 0 : 1;
