xmlport 50000 "Web Index"
{

    schema
    {
        textelement(root)
        {
            tableelement("WEB Index"; "WEB Index")
            {
                RequestFilterFields = "Line no.", "Key Field 1", "Key Field 2", "Key Field 3";
                XmlName = 'WebIndex';
                fieldelement(LineNo; "WEB Index"."Line no.")
                {
                }
                fieldelement(TableNo; "WEB Index"."Table No.")
                {
                }
                fieldelement(KeyField1; "WEB Index"."Key Field 1")
                {
                }
                fieldelement(KeyField2; "WEB Index"."Key Field 2")
                {
                }
                fieldelement(KeyField3; "WEB Index"."Key Field 3")
                {
                }
                fieldelement(KeyField4; "WEB Index"."Key Field 4")
                {
                }
                fieldelement(KeyField5; "WEB Index"."Key Field 5")
                {
                }
                fieldelement(Status; "WEB Index".Status)
                {
                }
                fieldelement(Error; "WEB Index".Error)
                {
                }
                fieldelement(TableName; "WEB Index"."Table Name")
                {
                }
                fieldelement(Test; "WEB Index".Test)
                {
                }
                fieldelement(DateTimeInserted; "WEB Index"."DateTime Inserted")
                {
                }
                fieldelement(OrderID; "WEB Index"."Order ID")
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

