/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-09-26
*  Description: This is a controller extension for GNE_SFA2_Address_Layout page
*  
*  Modification History
*  Date        Name        Description
*  2012-12-12  lewandj2	   New approach with configuration object
*            
*************************************************************/
public with sharing class GNE_SFA2_Address_Ext extends GNE_SFA2_DynamicVFLoader {   
    public GNE_SFA2_Address_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_Address_Layout');
        
        // we have to put all possible included pages into the map with "false" value to fix sf bug with maps on vf pages
        visualforceIncludesMap.put('GNE_Merge_UI_AddressButtonPanel', false);
    }

    public PageReference edit(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_Address_Edit_Create_Layout?id='+myObject.id);
        pageref.setredirect(true);
        return pageref;
    }
    
	public PageReference dataChangeRequestClick(){
        String sbcURL = '/apex/GNE_SFA2_AddressDCR?id='+myObject.Id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
    }
}