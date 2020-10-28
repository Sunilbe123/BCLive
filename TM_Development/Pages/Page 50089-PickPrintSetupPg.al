page 50089
 "Pick Print Setup"
{
    //version MITL2235
    PageType = List;
    SourceTable = "Pick Print Setup";
    UsageCategory = Tasks;
    ApplicationArea = All;
    Editable = true;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Printer ID"; "Printer ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL2235';
                }
                field("Server URL"; "Server URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL2235';
                }
                field(Port; Port)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL2235';
                }
                field(Command; Command)
                {
                    ApplicationArea = All;
                    ToolTip = 'Page Field';
                    Description = 'MITL2235';
                }

            }
        }
    }

    actions
    {
    }
}