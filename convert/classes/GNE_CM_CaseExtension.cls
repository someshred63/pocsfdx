/*********---------------------------------------------------------------**********/
//This class is created to replicate change owner on Case and to preserve any manual
//record sharing records in CaseShare object when Case Owner is changed.
//Also, the code will update owner on related tasks based on EV values 
/********----------------------------------------------------------------*********/
public without sharing class GNE_CM_CaseExtension{
    List<CaseShare>caseshare_list = new List<CaseShare>();
    List<CaseShare>csh_list = new List<CaseShare>();    
    String caseOwner;
    String caseNum;
    private final Case caseItem;
    Integer taskFlag=1;
    List<Environment_Variables__c> ev_list = new List<Environment_Variables__c>();
    Map<String,String> Profilemap = new Map<String,String>();
    Map<String,String> Valuemap = new Map<String,String>();
    Set<String>profileset = new Set<String>();
    List<Task> task_list = new List<Task>();
    List<Task> taskupdate_list = new List<Task>();
    String case_record_type = '';
    String querystring;
    private List<GNE_CM_Case_Owner_FRM_Alignment__c> caseAlignList = new List<GNE_CM_Case_Owner_FRM_Alignment__c>();
    private ApexPages.StandardController controller;
    
    public Boolean autoAlignPromptDisplay {get; set;}
    public Boolean noAlignmentFoundDisplay {get; set;}
    public String editCaseModeButtonsMessage {get; set;}
    public String noAlignmentFoundMessage {get; set;}
    
    
    //private static final String editCaseModeButtonsMessageBegin = 'Alignment does not match:';
    //private static final String editCaseModeButtonsMessageEnd = ' Do you want to perform the auto-match (Choosing NO will change CaseOwner to selected user)?';

    public GNE_CM_CaseExtension(ApexPages.StandardController stdController) 
    {
        this.caseItem = (Case)stdController.getRecord();
        controller = stdController;
        caseOwner = caseItem.OwnerId;
        caseItem.OwnerId = null;
        caseNum = caseItem.CaseNumber;
        case_record_type = caseItem.recordtype.Name;
        autoAlignPromptDisplay = false;
        noAlignmentFoundDisplay = false;
        noAlignmentFoundMessage = 'The zip code alignment is missing. Do you still want to proceed?';
        
    }

    public PageReference save()  
    { 
        PageReference casePage;     
        if(GNE_CM_FRM_Alignment_Helper.getProductsForAlignment().contains(caseItem.Product_gne__c))
        {
            Boolean alignmentNotMatching = changeOwnerWithRealignment();
            if(alignmentNotMatching)
            {
                casePage = null;
                system.debug('Inside If');
            }
            else
            {
                casePage = standardChangeOwner();
                system.debug('Inside else');
            }
        }
        else
        {
            casePage = standardChangeOwner();   
        }
        // Case_Page.setRedirect(true); 
        return casePage;  
    }
    
    public PageReference changeAlign()
    {
        autoAlignPromptDisplay = false;
        
        if(case_record_type == 'C&R - Standard Case')
        {
            caseItem.Secondary_Case_Manager_gne__c = caseAlignList[0].GNE_CM_Secondary_Case_Manager_gne__c;
            caseItem.FRM_gne__c = caseAlignList[0].GNE_CM_FRM_gne__c;
            caseItem.CS_gne__c = caseAlignList[0].GNE_CM_CS_gne__c;
            if(caseItem.Case_Manager__c != caseAlignList[0].GNE_CM_Primary_Case_Manager_gne__c
                || caseItem.OwnerId != caseAlignList[0].GNE_CM_Primary_Case_Manager_gne__c)
            {
                try
                {                   
                    GNE_CM_FRM_Alignment_Helper.changeOwner(caseItem.Case_Manager__c, caseAlignList[0].GNE_CM_Primary_Case_Manager_gne__c, caseItem);               
                }
                catch(Exception ex)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                }
            }
            
        }
        if(case_record_type == 'GATCF - Standard Case')
        {
            caseItem.GNE_CM_Secondary_Foundation_Specialist__c = caseAlignList[0].GNE_CM_Secondary_Foundation_Specialist__c;
            caseItem.FRM_gne__c = caseAlignList[0].GNE_CM_FRM_gne__c;
            caseItem.CS_gne__c = caseAlignList[0].GNE_CM_CS_gne__c;
            if(caseItem.Foundation_Specialist_gne__c != caseAlignList[0].GNE_CM_Primary_Foundation_Specialist_gne__c
                || caseItem.OwnerId != caseAlignList[0].GNE_CM_Primary_Foundation_Specialist_gne__c)
            {
                try
                {                   
                    GNE_CM_FRM_Alignment_Helper.changeOwner(caseItem.Foundation_Specialist_gne__c, caseAlignList[0].GNE_CM_Primary_Foundation_Specialist_gne__c, caseItem);             
                }
                catch(Exception ex)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                }
            }
        }
        return controller.save();
    }
    
    public PageReference doNotChangeAlign()
    {
        if(case_record_type == 'C&R - Standard Case')
        {
            caseItem.Secondary_Case_Manager_gne__c = null;
            caseItem.FRM_gne__c = null;
            caseItem.CS_gne__c = null;
        }
        if(case_record_type == 'GATCF - Standard Case')
        {
            caseItem.GNE_CM_Secondary_Foundation_Specialist__c = null;
            caseItem.FRM_gne__c = null;
            caseItem.CS_gne__c = null;
        }
        return standardChangeOwner();
    }
    
    private Boolean changeOwnerWithRealignment()
    {
        Boolean hasError = false;
        autoAlignPromptDisplay = true;
        caseAlignList = GNE_CM_FRM_Alignment_Helper.SearchForFRMAlignment(caseItem.Zip_gne__c, caseItem.Product_gne__c);
        if(caseAlignList.size() == 1)
        {
            if(case_record_type == 'C&R - Standard Case')
            {
               // if(caseItem.Case_Manager__c != caseAlignList[0].GNE_CM_Primary_Case_Manager_gne__c
                //            || caseItem.OwnerId != caseAlignList[0].GNE_CM_Primary_Case_Manager_gne__c)
                if(caseItem.OwnerId != caseAlignList[0].GNE_CM_Primary_Case_Manager_gne__c)
                {
                    editCaseModeButtonsMessage = 'The Primary Case Manager does not match the alignment table. Do you want to proceed? If you select "Yes" the new Primary Case Manager will be updated on this case. If you select "No" the Primary Case Manager and all alignment fields will auto-align based on the CM Alignment territory table.';                 
                    autoAlignPromptDisplay = true;
                    hasError = true;
                }
                else 
                {
                    caseItem.Secondary_Case_Manager_gne__c = caseAlignList[0].GNE_CM_Secondary_Case_Manager_gne__c;
                    caseItem.FRM_gne__c = caseAlignList[0].GNE_CM_FRM_gne__c;
                    caseItem.CS_gne__c = caseAlignList[0].GNE_CM_CS_gne__c;
                }
            }
            else if(case_record_type == 'GATCF - Standard Case')
            {
                //if(caseItem.Foundation_Specialist_gne__c != //caseAlignList[0].GNE_CM_Primary_Foundation_Specialist_gne__c
                //            || caseItem.OwnerId != caseAlignList[0].GNE_CM_Primary_Foundation_Specialist_gne__c)
                if(caseItem.OwnerId != caseAlignList[0].GNE_CM_Primary_Foundation_Specialist_gne__c)
                {
                    editCaseModeButtonsMessage = 'The Primary Foundation Specialist does not match the alignment table. Do you want to proceed? If you select "Yes" the new Primary Foundation Specialist will be updated on this case. If you select "No" the Primary Foundation Specialist and all alignment fields will auto-align based on the CM Alignment territory table.';                                                      
                    autoAlignPromptDisplay = true;
                    hasError = true;
                }
                else 
                {
                    caseItem.GNE_CM_Secondary_Foundation_Specialist__c = caseAlignList[0].GNE_CM_Secondary_Foundation_Specialist__c;
                    caseItem.FRM_gne__c = caseAlignList[0].GNE_CM_FRM_gne__c;
                    caseItem.CS_gne__c = caseAlignList[0].GNE_CM_CS_gne__c;
                }
            }
        }
        else
        {
            autoAlignPromptDisplay = false;
            noAlignmentFoundDisplay = true;
            hasError = true;
        }       
        return hasError;
    }
    
    private PageReference standardChangeOwner()
    {
        noAlignmentFoundDisplay = false;
        if(caseItem.OwnerId != caseOwner)
        {
            try {
                caseshare_list = [Select CaseId, UserorGroupId,CaseAccessLevel, RowCause from CaseShare where CaseId=:caseItem.id and RowCause = 'Manual'];
            }catch(exception e)
            {
                ApexPages.addmessages(e);
                return null;
            }
            for(integer i = 0; i< caseshare_list.size(); i++)
            {
                CaseShare csh = new CaseShare();
                csh.CaseId =  caseshare_list[i].CaseId;
                csh.UserorGroupId = caseshare_list[i].UserorGroupId;
                csh.CaseAccessLevel = caseshare_list[i].CaseAccessLevel;
                csh_list.add(csh);
                
            }
        }

        try {
            update caseItem;
            insert csh_list;
            taskFlag = 1;
        }
        catch(DMLException ex)
        {
            ApexPages.addmessages(ex);
            return null;
            taskFlag= 0;
        }

        try{
            if(taskFlag == 1)
            {
                ev_list= [Select Key__c , value__c from Environment_Variables__c  where Key__c IN ('CASE_OWNER_TASK_INCLUDED_PROFILES', 'CASE_OWNER_TASK_REASSIGN_LOGIC') and Description_Name__c = :case_record_type];   

                for(integer j= 0; j<ev_list.size(); j++)
                {
                    if(ev_list[j].Key__c  == 'CASE_OWNER_TASK_INCLUDED_PROFILES' )
                    {
                        Profilemap.put(ev_list[j].value__c,ev_list[j].value__c);
                    }
                    
                    if (ev_list[j].Key__c == 'CASE_OWNER_TASK_REASSIGN_LOGIC')
                    {
                        Valuemap.put(ev_list[j].Key__c, ev_list[j].value__c);
                    }              
                }              

                profileset = Profilemap.keySet();
                if(profileset.size() == 0)
                {
                    querystring = 'select id , ownerid  from task where Isclosed = false and CM_Case_Number_gne__c = :caseNum ';
                }
                else
                {
                    querystring = 'select id , ownerid  from task where Isclosed = false and CM_Case_Number_gne__c = :caseNum AND OwnerId IN (SELECT ID FROM User WHERE Profile.Name IN :profileset)';                                         
                }
                
                task_list  = Database.query(querystring);
                
                if(Valuemap.get('CASE_OWNER_TASK_REASSIGN_LOGIC') == 'Owner Only')
                {
                    for(integer k = 0; k<task_list.size();k++)
                    {
                        if (task_list[k].OwnerId  == caseOwner)
                        { 
                            task_list[k].OwnerId = caseItem.OwnerId ; 
                            taskupdate_list.add(task_list[k]);
                        }
                    }
                }
                else if(Valuemap.get('CASE_OWNER_TASK_REASSIGN_LOGIC') == 'All Tasks')
                {
                    for(integer k = 0; k<task_list.size();k++)
                    {              
                        task_list[k].OwnerId = caseItem.OwnerId ; 
                        taskupdate_list.add(task_list[k]);
                    }
                }
                
                try { 
                    
                    if(taskupdate_list.size()>0)
                    update taskupdate_list;
                }
                catch(DMLException ex)
                {
                    ApexPages.addmessages(ex);
                    return null;           
                }

            }
        }catch(exception e)
        {
            ApexPages.addmessages(e);
            return null;
        }
        PageReference Case_Page = new PageReference('/'+caseItem.Id);               
        return Case_Page;
    }
}