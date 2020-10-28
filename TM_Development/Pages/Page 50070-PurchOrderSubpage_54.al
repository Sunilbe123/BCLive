pageextension 50070 PurchOrderSubpage extends "Purchase Order Subform"
{
    layout
    {
        // Add changes to page layout here
        addafter("Location Code")
        {
            field(Size; Size)
            {
                ApplicationArea = All;
                ToolTip = 'Page Field';
                Description = 'MITL1600';
            }
        }
        //MITL2277 ++
        modify(Quantity)
        {
            trigger OnAfterValidate()
            var

            begin
                CheckUnitCostLCY(Rec);
            end;
        }
        //MITL2277 **
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;


    [IntegrationEvent(false, false)]
    //MITL2277 ++
    local procedure CheckUnitCostLCY(VAR PurchaseLine: Record "Purchase Line")
    begin

    End;
    //MITL2277 **
}