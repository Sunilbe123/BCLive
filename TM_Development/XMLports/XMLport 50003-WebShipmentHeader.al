xmlport 50003 WebShipmentHeader
{

    schema
    {
        textelement(root)
        {
            tableelement("WEB Shipment Header"; "WEB Shipment Header")
            {
                RequestFilterFields = "Shipment ID", "Order ID", "Index No.";
                XmlName = 'WebShipmentHeader';
                fieldelement(ShipmentDate; "WEB Shipment Header"."Shipment Date")
                {
                }
                fieldelement(ShipmentID; "WEB Shipment Header"."Shipment ID")
                {
                }
                fieldelement(Store; "WEB Shipment Header".Store)
                {
                }
                fieldelement(OrderID; "WEB Shipment Header"."Order ID")
                {
                }
                fieldelement(ShippingMethod; "WEB Shipment Header"."Shipping Method")
                {
                }
                fieldelement(ShippingDescription; "WEB Shipment Header"."Shipping Description")
                {
                }
                fieldelement(DiscountCode; "WEB Shipment Header"."Discount Code")
                {
                }
                fieldelement(Subtotal; "WEB Shipment Header".Subtotal)
                {
                }
                fieldelement(ShippingHandling; "WEB Shipment Header"."Shipping & Handling")
                {
                }
                fieldelement(DiscountAmount; "WEB Shipment Header"."Discount Amount")
                {
                }
                fieldelement(VAT; "WEB Shipment Header".VAT)
                {
                }
                fieldelement(GrandTotal; "WEB Shipment Header"."Grand Total")
                {
                }
                fieldelement(CustomerComments; "WEB Shipment Header"."Customer Comments")
                {
                }
                fieldelement(PaymentMethod; "WEB Shipment Header"."Payment Method")
                {
                }
                fieldelement(CustomerID; "WEB Shipment Header"."Customer ID")
                {
                }
                fieldelement(CustomerEmail; "WEB Shipment Header"."Customer Email")
                {
                }
                fieldelement(TrackingCarrier; "WEB Shipment Header"."Tracking Carrier")
                {
                }
                fieldelement(TrackingNumber; "WEB Shipment Header"."Tracking Number")
                {
                }
                fieldelement(Weight; "WEB Shipment Header".Weight)
                {
                }
                fieldelement(Type; "WEB Shipment Header"."LineType")
                {
                }
                fieldelement(DateTime; "WEB Shipment Header"."Date Time")
                {
                }
                fieldelement(IndexNo; "WEB Shipment Header"."Index No.")
                {

                    trigger OnAfterAssignField()
                    begin
                        IndexCode := "WEB Shipment Header"."Index No.";
                    end;
                }
                fieldelement(OrderExists; "WEB Shipment Header"."Order Exists")
                {
                }
                fieldelement(ShipmentCount; "WEB Shipment Header"."Shipment Count")
                {
                }
                fieldelement(Receipted; "WEB Shipment Header".Receipted)
                {
                }

                trigger OnAfterInsertRecord()
                begin
                    "WEB Shipment Header"."Index No." := IndexCode;
                    "WEB Shipment Header".MODIFY;
                end;
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

    var
        IndexCode: Code[20];
}

