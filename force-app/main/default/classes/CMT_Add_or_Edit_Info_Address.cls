public with sharing class CMT_Add_or_Edit_Info_Address 
{
	private ApexPages.StandardController controller;
	public String meetingId;
	public String infoId;
	public String addressId;
	public CMT_Information_Address_gne__c infoAddress {get; set;}
	
	public CMT_Add_or_Edit_Info_Address(ApexPages.StandardController controller)
	{
		PageReference pageRef = System.currentPageReference();
		meetingId = pageRef.getParameters().get('mid');
		infoId = pageRef.getParameters().get('iid');
		addressId = pageRef.getParameters().get('aid');
		if(addressId == null || addressId == '')
		{
			infoAddress = new CMT_Information_Address_gne__c();
		}
		else
		{
			getInfoAddress(addressId);
		}
	}
	private CMT_Information_Address_gne__c getInfoAddress(String addressId)
	{
		infoAddress = new CMT_Information_Address_gne__c();
		infoAddress = [Select Id, Name_gne__c, City_gne__c,	Phone_gne__c, State_gne__c, Street_gne__c, Zip_gne__c from  CMT_Information_Address_gne__c where Id =: addressId];
		return infoAddress;
	}
	public PageReference saveInfoAddress()
	{
		String latitude = '';
		String longitude = '';
		if(infoAddress.Street_gne__c != '' && infoAddress.City_gne__c != '' && infoAddress.State_gne__c !='' && infoAddress.Street_gne__c != null && infoAddress.City_gne__c != null && infoAddress.State_gne__c !=null)
		{
			String tmpCords = getCoordinates(infoAddress.Street_gne__c, infoAddress.City_gne__c, String.valueOf(infoAddress.State_gne__c));
			Integer colonIdx = tmpCords.lastIndexOf(',');
			Integer strLenght = tmpCords.length();
		    latitude = tmpCords.substring(0, colonIdx);
			longitude = tmpCords.substring(colonIdx+1, strLenght);
		}
		if(addressId == null || addressId == '')
		{
			infoAddress.Meeting_gne__c = meetingId;
			infoAddress.Information_gne__c = infoId;
			if(latitude != '' && longitude != '')
			{
				infoAddress.Latitude_gne__c = latitude;
				infoAddress.Longitude_gne__c = longitude;
			}
			insert infoAddress;
		}
		else
		{
			if(latitude != '' && longitude != '')
			{
				infoAddress.Latitude_gne__c = latitude;
				infoAddress.Longitude_gne__c = longitude;
			}
			update infoAddress;
		} 
		String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_Info_View?meetingId='+meetingId+'&id='+infoId;
        if(meetingId != null && meetingId !='' && infoId !='' && infoId !=null)
        {
            PageReference pageRef = new PageReference(redirectURL);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else
        {
            return null;
        }
	}
	public PageReference cancel()
	{
		String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_Info_View?mid='+meetingId+'&id='+infoId;
        if(meetingId != null && meetingId !='' && infoId !='' && infoId !='')
        {
            PageReference pageRef = new PageReference(redirectURL);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else
        {
            return null;
        }
	}
	private String getCoordinates(String Street, String City, String State)
	{
		Double cord1;
		Double cord2;
		Double cord3;
		String environment = getEnvironment();
		String key='';
		String yelpCords ='';
		if(environment =='dev')
		{
			key = 'ABQIAAAAW1D4PzyJcb8u6_0nlzvYdxQ0tqbuZOJmCG4efPyWiDnWAZraEBSCeJyvNWLzQSJU9gDb0xBpDybbQQ';
		}
		if(environment == 'sqa')
		{
			key = 'ABQIAAAAW1D4PzyJcb8u6_0nlzvYdxSQjenr-1DNx21BmqujZ7j3XuP8lhQOV7hMHyeNYzVI-7RjWJjOBi38Yw';
		}
		if(environment == 'uat')
		{
			key = 'ABQIAAAAW1D4PzyJcb8u6_0nlzvYdxQ4hZBRKujLa20gdgk6BGq02b_7dRRi5Tk92eYsydNBpbom0m38s-csSA';
		}
		if(environment == 'prod')
		{
			key ='ABQIAAAAW1D4PzyJcb8u6_0nlzvYdxTwZth5GdZI-P7ekoe_gyhfzl1yZhTovBSFn07NnnO3s_0fcH28WNYFBg';
		}
		String url = 'http://maps.google.com/maps/geo?q='+ Encodingutil.urlEncode(Street, 'UTF-8')+',+'+ Encodingutil.urlEncode(City, 'UTF-8')+',+'+ Encodingutil.urlEncode(State, 'UTF-8')+'&output=json&sensor=false&key='+key;
		Http http = new Http();		
		Httprequest req = new Httprequest();	
		req.setMethod('GET');
		req.setEndpoint(url);
		Httpresponse resp = http.send(req);
		String jsonContent = resp.getBody();
		JSONParser parser = JSON.createParser( jsonContent);
		while(parser.nextToken() != null)
		{
			if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'coordinates')) 
			{
				parser.nextToken();
				parser.nextValue();
				cord1 = parser.getDoubleValue();
				parser.nextValue();
				cord2 = parser.getDoubleValue();
				parser.nextValue();
				cord3 = parser.getDoubleValue();
			}
		}
		yelpCords = String.valueof(cord1)+','+String.valueof(cord2);
		return yelpCords;	
	}
	private String getEnvironment()
	{
		String env ='';
        String userName = Userinfo.getUsername();
        if(userName !='')
        {
            if(userName.indexOf('@gene.com') > 0 && userName.indexOf('@gene.com.') <0)
                env = 'prod';
            else if(userName.indexOf('@gene.com.') >0)
                env = userName.substring(userName.indexOf('@gene.com.')+10, userName.length());
        }
        return env;
	}
}