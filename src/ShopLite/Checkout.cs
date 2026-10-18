namespace ShopLite;

public static class Checkout
{
    public static decimal CalculateVip(decimal subtotal)
    {
        const decimal percent = 10m;
        return Calculate(subtotal, percent);
    }

    public static decimal Subtotal(decimal unitPrice, int quantity)
    {
        if (unitPrice < 0m) throw new ArgumentOutOfRangeException(nameof(unitPrice));
        if (quantity < 1) throw new ArgumentOutOfRangeException(nameof(quantity));
        return unitPrice * quantity;
    }

    public static decimal Calculate(decimal subtotal, decimal discountPercent = 0m)
    {
        if (subtotal < 0m) throw new ArgumentOutOfRangeException(nameof(subtotal));
        if (discountPercent < 0m || discountPercent > 100m) throw new ArgumentOutOfRangeException(nameof(discountPercent));
        var shipping = subtotal >= DeliveryPolicy.FreeShippingThreshold ? 0m : DeliveryPolicy.ShippingFee;
        var discounted = decimal.Round(subtotal * (1m - discountPercent / 100m), 2, MidpointRounding.AwayFromZero);
        return discounted + shipping;
    }
}
