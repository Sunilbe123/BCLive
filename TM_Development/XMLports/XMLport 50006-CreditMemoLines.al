xmlport 50006 CreditMemoLines
{

    schema
    {
        textelement(root)
        {
            tableelement("WEB Credit Lines"; "WEB Credit Lines")
            {
                RequestFilterFields = "Order ID", "Credit Memo ID", "Index No.";
                XmlName = 'WebCreditLine';
                fieldelement(Sku; "WEB Credit Lines".Sku)
                {
                }
                fieldelement(Name; "WEB Credit Lines".Name)
                {
                }
                fieldelement(Size; "WEB Credit Lines".Size)
                {
                }
                fieldelement(QTY; "WEB Credit Lines".QTY)
                {
                }
                fieldelement(ProductOptions; "WEB Credit Lines"."Product Options")
                {
                }
                fieldelement(CalculatorSettings; "WEB Credit Lines"."Calculator Settings")
                {
                }
                fieldelement(OrderID; "WEB Credit Lines"."Order ID")
                {
                }
                fieldelement(LineNo; "WEB Credit Lines"."Line No")
                {
                }
                fieldelement(Subtotal; "WEB Credit Lines".Subtotal)
                {
                }
                fieldelement(ShippingHandling; "WEB Credit Lines"."Shipping & Handling")
                {
                }
                fieldelement(DiscountAmount; "WEB Credit Lines"."Discount Amount")
                {
                }
                fieldelement(VAT; "WEB Credit Lines".VAT)
                {
                }
                fieldelement(Type; "WEB Credit Lines"."LineType")
                {
                }
                fieldelement(DateTime; "WEB Credit Lines"."Date Time")
                {
                }
                fieldelement(UnitPrice; "WEB Credit Lines"."Unit Price")
                {
                }
                fieldelement(CareditMemoID; "WEB Credit Lines"."Credit Memo ID")
                {
                }
                fieldelement(IndexNo; "WEB Credit Lines"."Index No.")
                {
                }
                fieldelement(Receipted2; "WEB Credit Lines".Receipted2)
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

