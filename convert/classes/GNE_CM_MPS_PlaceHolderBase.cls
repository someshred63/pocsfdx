public virtual without sharing class GNE_CM_MPS_PlaceHolderBase 
{
    public String firstNamePH {get; private set;}
    public String lastNamePH {get; private set;}
    public String emailPH {get; private set;}
    public String emailPH2 {get; private set;}
    public String phoneNumberPH {get; private set;}
    public String extensionPH {get; private set;}
    public String addressSuitePH {get; private set;}
    public String addressCityPH {get; private set;}
    public String addressZipPH {get; private set;}
    public String addressStreetPH {get; private set;}
    public String shipContactNamePH {get; private set;}
    public String shipDeliverDatePH {get; private set;}
    public String anticpatedDateOfServicePH {get; private set;}//PS:08/30/213 MDME
    public String npiPH {get; private set;}
    public String stateLicensePH {get; private set;}
    public String dob{get; private set;}    
    
    protected void initPlaceHolderValues()
    {
        firstNamePH = 'First Name';
        lastNamePH = 'Last Name';
        emailPH = 'example: janedoe@practicename.com';
        emailPH2 = 'janedoe@email.com';
        phoneNumberPH = 'example: (415) 555-1212';
        extensionPH = 'Extension';
        addressSuitePH = 'Suite #';
        addressCityPH = 'City';
        addressZipPH = 'Zip Code';
        addressStreetPH = 'example:123 Main Street,'; 
        shipContactNamePH = 'example: Full Name';
        shipDeliverDatePH = 'example: 10/23/2011';
        anticpatedDateOfServicePH = 'example: 10/23/2011';//PS:08/30/213 MDME
        npiPH = 'NPI #';
        stateLicensePH = 'State License #';
        dob='03/25/1800';       
    }
}