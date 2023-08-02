public with sharing class EDM_AABP_List_View_Controller extends GNE_SFA2_List_View_Base_Controller {

    public GNE_SFA2_List_View_Base_Controller thisController { get; set; }
    private List<EDM_AABP_gne__c> aabps;
    public String notFinalizedAABPs{get;set;}
    public Boolean isABPManager{get;set;}
     
    public EDM_AABP_List_View_Controller () {
        super('EDM_AABP_gne__c');
        thisController = this;

        aabps = new List<EDM_AABP_gne__c>([Select name from EDM_AABP_gne__c where EDM_Finalized_gne__c=false]);
        notFinalizedAABPs='';
        Integer i = 0;
        for(EDM_AABP_gne__c aabp : aabps){
        	if(i>0){
        		notFinalizedAABPs+=';';
        	}
        	i++;
        	notFinalizedAABPs+=aabp.Name;
        }
        try{
        	String s = [SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId() AND PermissionSet.Name = 'EDM_ABS_Manager'].PermissionSetId;
        	if(s!=''){
        		isABPManager=true;
        	}
        } catch(Exception e){
        	isABPManager=false;
        }
        
    }

    public PageReference createEdit(){
    	PageReference pr = new PageReference('/apex/EDM_AABP_Edit_Create');
    	pr.setRedirect(true);
    	return pr;
    }

    public String getListViewLabel(){
    	try{
    		List<PermissionSetAssignment> ps = new List<PermissionSetAssignment>([SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId()]);
    		List<String> psNames = new List<String>();
    		for(PermissionSetAssignment p : ps){
    			psNames.add(p.PermissionSet.Name);
    		}
    		List<SFA2_User_Group_Mapping_gne__c> ugm = new List<SFA2_User_Group_Mapping_gne__c>([select Role_gne__c from SFA2_User_Group_Mapping_gne__c WHERE Application_gne__c = 'ABM' AND Permission_Set_Name_gne__c in :psNames]);
    		List<String> roleNames = new List<String>();
    		for(SFA2_User_Group_Mapping_gne__c r : ugm){
    			roleNames.add(r.Role_gne__c);
    		}
        	return [SELECT View_Name_gne__c FROM SFA2_View_Config_gne__c WHERE Role_gne__c in :roleNames and Page_Name_gne__c=:getListPageName() LIMIT 1].View_Name_gne__c;
        } catch(Exception e){
        	System.debug('No list viewes found');
        	return '';
        }
    }
/*    public PageReference newClick() {
        PageReference newEvent = Page.GNE_SFA2_PROSPECT_Event_Edit_Create;
        newEvent.getParameters().put('retURL', '/apex/GNE_SFA2_PROSPECT_MyEvents');
        return newEvent;
    }*/
}