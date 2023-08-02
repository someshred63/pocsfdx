global class iPhone_Ask_An_Expert_Product_Roster_gne 
{
    global class Response
    {
        Webservice List<Ask_An_Expert_Product_gne__c> products;
        Webservice List<Ask_An_Expert_Roster_gne__c> rosters; // some comment
     }
    
   public static List<Ask_An_Expert_Product_gne__c> products()
    {
        List<Ask_An_Expert_Product_gne__c> products = new List<Ask_An_Expert_Product_gne__c>();

                products =
                [
                 Select
                    Name
                 From
                    Ask_An_Expert_Product_gne__c
                ];
         
        return products;
    }
    
    public static List<Ask_An_Expert_Roster_gne__c> rosters() {
        List<Ask_An_Expert_Roster_gne__c> rosters = new List<Ask_An_Expert_Roster_gne__c>();

                rosters =
                [
                 Select
                    Email__c,
                    First_Name__c,
                    Last_Name__c,
                    Mobile__c,
                    Office_Phone__c,
                    Product__c,
                    Role__c,
                    Skype_Id__c
                 From
                    Ask_An_Expert_Roster_gne__c
                ];
         
        return rosters;
    }

    Webservice static Response getProductsAndExpertRosters()
    {
        Response result = new Response();
        result.products = products();
        result.rosters = rosters();
        return result;
    }
}