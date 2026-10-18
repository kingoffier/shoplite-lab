namespace ShopLite;

public static class Checkout
{
    public static decimal Calculate(decimal subtotal)
    {
        var shipping = subtotal > DeliveryPolicy.FreeShippingThreshold ? 0m : DeliveryPolicy.ShippingFee;
        return subtotal + shipping;
    }
}
