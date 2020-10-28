xmlport 50005 WebCreditHeader
{

    schema
    {
        textelement(root)
        {
            tableelement("WEB Credit Header"; "WEB Credit Header")
            {
                RequestFilterFields = "Credit Memo ID", "Order ID", "Index No.";
                XmlName = 'WebCreditHeader';
                fieldelement(CreditMemoDate; "WEB Credit Header"."Credit Memo Date")
                {
                }
                fieldelement(CreditMemoID; "WEB Credit Header"."Credit Memo ID")
                {
                }
                fieldelement(Store; "WEB Credit Header".Store)
                {
                }
                fieldelement(ShippingMethod; "WEB Credit Header"."Shipping Method")
                {
                }
                fieldelement(ShippingDescription; "WEB Credit Header"."Shipping Description")
                {
                }
                fieldelement(DiscountCode; "WEB Credit Header"."Discount Code")
                {
                }
                fieldelement(Subtotal; "WEB Credit Header".Subtotal)
                {
                }
                fieldelement(ShippingHandling; "WEB Credit Header"."Shipping & Handling")
                {
                }
                fieldelement(DiscountAmount; "WEB Credit Header"."Discount Amount")
                {
                }
                fieldelement(VAT; "WEB Credit Header".VAT)
                {
                }
                fieldelement(GrandTotal; "WEB Credit Header"."Grand Total")
                {
                }
                fieldelement(CustomerComments; "WEB Credit Header"."Customer Comments")
                {
                }
                fieldelement(PaymentMethod; "WEB Credit Header"."Payment Method")
                {
                }
                fieldelement(CustomerID; "WEB Credit Header"."Customer ID")
                {
                }
                fieldelement(CustomerEmail; "WEB Credit Header"."Customer Email")
                {
                }
                fieldelement(OrderID; "WEB Credit Header"."Order ID")
                {
                }
                fieldelement(AdjustmentRefundAmount; "WEB Credit Header"."Adjustment Refund Amount")
                {
                }
                fieldelement(AdjustmentFeeAmount; "WEB Credit Header"."Adjustment Fee Amount")
                {
                }
                fieldelement(Type; "WEB Credit Header"."LineType")
                {
                }
                fieldelement(DateTime; "WEB Credit Header"."Date Time")
                {
                }
                fieldelement(IndexNo; "WEB Credit Header"."Index No.")
                {

                    trigger OnAfterAssignField()
                    begin
                        IndexCode := "WEB Credit Header"."Index No.";
                    end;
                }
                fieldelement(ShipmentID; "WEB Credit Header"."Shipment ID")
                {
                }
                fieldelement(Receipted2; "WEB Credit Header".Receipted2)
                {
                }

                trigger OnAfterInsertRecord()
                begin
                    "WEB Credit Header"."Index No." := IndexCode;
                    "WEB Credit Header".MODIFY;
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

