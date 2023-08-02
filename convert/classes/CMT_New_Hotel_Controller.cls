public with sharing class CMT_New_Hotel_Controller
{    
    private ApexPages.StandardController ctrl;
    private CMT_Hotel_gne__c newHotel;
    private CMT_Hotel_Address_gne__c newAddress = new CMT_Hotel_Address_gne__c();
    public String meetingId { get; set; }
    
    public CMT_Hotel_Address_gne__c getNewAddress()
    {
        return newAddress;
    }
    
    public CMT_New_Hotel_Controller(ApexPages.StandardController ctrl)
    {
        this.ctrl = ctrl;
        newHotel = (CMT_Hotel_gne__c)ctrl.getRecord();
    }
    
    public PageReference init()
    {
    	meetingId = System.currentPageReference().getParameters().get('meetingId');
    	return null;
    }
    
    public PageReference save()
    {
    	newHotel.Meeting_gne__c = meetingId;
    	PageReference pageRef = ctrl.save();
        newHotel = (CMT_Hotel_gne__c)ctrl.getRecord();
        system.debug('hotel id = ' + newHotel.Id);
        //saveAddress(newHotel.Id);
        return pageRef;
    }
    
    private void saveAddress(Id hotelId)
    {
        newAddress.Meeting_gne__c = meetingId;
        newAddress.Hotel_gne__c = hotelId;
        insert newAddress;
    }
}