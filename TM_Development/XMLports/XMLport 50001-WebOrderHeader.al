xmlport 50001 WebOrderHeader
{

    schema
    {
        textelement(root)
        {
            tableelement("WEB Order Header"; "WEB Order Header")
            {
                RequestFilterFields = "Order ID", "Index No.";
                XmlName = 'WebOrderHeader';
                fieldelement(OrderDate; "WEB Order Header"."Order Date")
                {
                }
                fieldelement(OrderID; "WEB Order Header"."Order ID")
                {
                }
                fieldelement(Store; "WEB Order Header".Store)
                {
                }
                fieldelement(ShippingMethod; "WEB Order Header"."Shipping Method")
                {
                }
                fieldelement(ShippingDescription; "WEB Order Header"."Shipping Description")
                {
                }
                fieldelement(DiscountCode; "WEB Order Header"."Discount Code")
                {
                }
                fieldelement(Subtotal; "WEB Order Header".Subtotal)
                {
                }
                fieldelement(ShippingHanding; "WEB Order Header"."Shipping & Handling")
                {
                }
                fieldelement(DiscountAmount; "WEB Order Header"."Discount Amount")
                {
                }
                fieldelement(VAT; "WEB Order Header".VAT)
                {
                }
                fieldelement(GrandTotal; "WEB Order Header"."Grand Total")
                {
                }
                fieldelement(CustomerComments; "WEB Order Header"."Customer Comments")
                {
                }
                fieldelement(PaymentMethod; "WEB Order Header"."Payment Method")
                {
                }
                fieldelement(CustomerID; "WEB Order Header"."Customer ID")
                {
                }
                fieldelement(CustomerEmail; "WEB Order Header"."Customer Email")
                {
                }
                fieldelement(Type; "WEB Order Header"."LineType")
                {
                }
                fieldelement(DateTime; "WEB Order Header"."Date Time")
                {
                }
                fieldelement(IndexNo; "WEB Order Header"."Index No.")
                {

                    trigger OnAfterAssignField()
                    begin
                        IndexCode := "WEB Order Header"."Index No.";
                    end;
                }
                fieldelement(Receipted; "WEB Order Header".Receipted)
                {
                }

                trigger OnAfterInsertRecord()
                begin
                    "WEB Order Header"."Index No." := IndexCode;
                    "WEB Order Header".MODIFY;
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

