xmlport 50004 WebShipmentLines
{

    schema
    {
        textelement(root)
        {
            tableelement("WEB Shipment Lines"; "WEB Shipment Lines")
            {
                RequestFilterFields = "Order ID", "Shipment ID";
                XmlName = 'WebShipmentLine';
                fieldelement(Sku; "WEB Shipment Lines".Sku)
                {
                }
                fieldelement(Name; "WEB Shipment Lines".Name)
                {
                }
                fieldelement(Size; "WEB Shipment Lines".Size)
                {
                }
                fieldelement(QTY; "WEB Shipment Lines".QTY)
                {
                }
                fieldelement(ProductOptions; "WEB Shipment Lines"."Product Options")
                {
                }
                fieldelement(CalculatorSettings; "WEB Shipment Lines"."Calculator Settings")
                {
                }
                fieldelement(OrderID; "WEB Shipment Lines"."Order ID")
                {
                }
                fieldelement(LineNo; "WEB Shipment Lines"."Line No")
                {
                }
                fieldelement(Subtotal; "WEB Shipment Lines".Subtotal)
                {
                }
                fieldelement(ShippingHandling; "WEB Shipment Lines"."Shipping & Handling")
                {
                }
                fieldelement(DiscountAmount; "WEB Shipment Lines"."Discount Amount")
                {
                }
                fieldelement(VAT; "WEB Shipment Lines".VAT)
                {
                }
                fieldelement(Type; "WEB Shipment Lines"."LineType")
                {
                }
                fieldelement(DateTime; "WEB Shipment Lines"."Date Time")
                {
                }
                fieldelement(ShipmentID; "WEB Shipment Lines"."Shipment ID")
                {
                }
                fieldelement(Receipted; "WEB Shipment Lines".Receipted)
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

