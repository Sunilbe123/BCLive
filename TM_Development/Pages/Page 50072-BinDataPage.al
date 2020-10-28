page 50072 "Bin Data List"
{
    Caption = 'Bin Data List';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;
    PageType = List;
    SourceTable = "Bin Data Update";
    UsageCategory = Tasks;
    ApplicationArea = All;
    Editable = false; //MITL.AJ.03032020 On request of MATT stock values will be read from SQL now.

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Total Stock In Picking Bins"; "Total Stock In Picking Bins")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Total Stock In Put-Away Bins"; "Total Stock In Put-Away Bins")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Available Stock"; "Available Stock")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }

                field("Modified DateTime"; "Modified DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
                field("Magento Update"; "Magento Update")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {

        }
    }

    trigger OnAfterGetRecord()
    begin
    end;

    var
        ErrorLine: Text;
}

