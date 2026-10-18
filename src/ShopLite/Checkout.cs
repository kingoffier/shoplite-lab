namespace ShopLite;

public static class Checkout
{
    public static decimal Subtotal(decimal unitPrice, int quantity)
    {
        if (unitPrice < 0m) throw new ArgumentOutOfRangeException(nameof(unitPrice));
        if (quantity < 1) throw new ArgumentOutOfRangeException(nameof(quantity));
        return unitPrice * quantity;
    }

    public static decimal Calculate(decimal subtotal)
    {
        if (subtotal < 0m) throw new ArgumentOutOfRangeException(nameof(subtotal));
        var shipping = subtotal > DeliveryPolicy.FreeShippingThreshold ? 0m : DeliveryPolicy.ShippingFee;
        return subtotal + shipping;
    }
}
