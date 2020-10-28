xmlport 50002 WebOrderLines
{

    schema
    {
        textelement(root)
        {
            tableelement("WEB Order Lines"; "WEB Order Lines")
            {
                RequestFilterFields = "Order ID";
                XmlName = 'WebOrderLines';
                fieldelement(Sku; "WEB Order Lines".Sku)
                {
                }
                fieldelement(Name; "WEB Order Lines".Name)
                {
                }
                fieldelement(Size; "WEB Order Lines".Size)
                {
                }
                fieldelement(QTY; "WEB Order Lines".QTY)
                {
                }
                fieldelement(ProductOptions; "WEB Order Lines"."Product Options")
                {
                }
                fieldelement(CalculatorSettings; "WEB Order Lines"."Calculator Settings")
                {
                }
                fieldelement(OrderID; "WEB Order Lines"."Order ID")
                {
                }
                fieldelement(LineNo; "WEB Order Lines"."Line No")
                {
                }
                fieldelement(Subtotal; "WEB Order Lines".Subtotal)
                {
                }
                fieldelement(ShippingHandling; "WEB Order Lines"."Shipping & Handling")
                {
                }
                fieldelement(DiscountAmount; "WEB Order Lines"."Discount Amount")
                {
                }
                fieldelement(VAT; "WEB Order Lines".VAT)
                {
                }
                fieldelement(Type; "WEB Order Lines"."LineType")
                {
                }
                fieldelement(DateTime; "WEB Order Lines"."Date Time")
                {
                }
                fieldelement(UnitPrice; "WEB Order Lines"."Unit Price")
                {
                }
                fieldelement(ItemNoExists; "WEB Order Lines"."Item No. Exists")
                {
                }
                fieldelement(Receipted; "WEB Order Lines".Receipted)
                {
                }
                fieldelement(CutSize; "WEB Order Lines"."Cut Size")
                {
                }
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }
}

