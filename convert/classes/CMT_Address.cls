global class CMT_Address extends CMT_JSONWrapper
{
    public String City { get; set; }
    public String State { get; set; }
    public String Phone { get; set; }
    public String Street { get; set; }
    public String Zip { get; set; }
    public String Yelp { get; set; }
    public String Longitude { get; set; }
    public String Latitude { get; set; }
    public String Name { get; set; }
    
    public CMT_Address (CMT_Information_Address_gne__c address)
    {
        if (address != null)
        {
            Id = address.Id;
            Name = address.Name_gne__c;
            City = address.City_gne__c;
            State = address.State_gne__c;
            Phone = address.Phone_gne__c;
            Street = address.Street_gne__c;
            Zip = address.Zip_gne__c;
            Yelp = address.Yelp_gne__c;
            Longitude = address.Longitude_gne__c;
            Latitude = address.Latitude_gne__c;
        }
    }
    
    public CMT_Address (CMT_Address_gne__c address)
    {
        if (address != null)
        {
            Id = address.Id;
            City = address.City_gne__c;
            State = address.State_gne__c;
            Phone = address.Phone_gne__c;
            Street = address.Street_gne__c;
            Zip = address.Zip_gne__c;
            Yelp = address.Yelp_gne__c;
        }
    }
    
    public CMT_Address (CMT_Hotel_Address_gne__c address)
    {
        if (address != null)
        {
            Id = address.Id;
            City = address.City_gne__c;
            State = address.State_gne__c;
            Phone = address.Phone_gne__c;
            Street = address.Street_gne__c;
            Zip = address.Zip_gne__c;
            Yelp = address.Yelp_gne__c;
        }
    }
    
    public CMT_Address (CMT_Yelp_Address_gne__c address)
    {
        if (address != null)
        {
            Id = address.Id;
            City = address.City_gne__c;
            //State = address.State_gne__c;
            Phone = address.Phone_gne__c;
            Street = address.Street_gne__c;
            Zip = address.Zip_gne__c;
            Yelp = address.Yelp_gne__c;
        }
    }
}