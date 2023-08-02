/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2013-01-17
*  Description: This is a controller extension for GNE_SFA2_Brand_Aff_Layout page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Brand_Aff_Ext extends GNE_SFA2_DynamicVFLoader {   
    public GNE_SFA2_Brand_Aff_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_Brand_Aff_Layout');
        
        visualforceIncludesMap.put('GNE_SFA2_BA_AdvocacyAssessments', false);
        visualforceIncludesMap.put('GNE_SFA2_BA_ResourceCenter', false);        
    }

    public PageReference edit(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_Brand_Aff_Edit_Create_Layout?id='+myObject.id);
        pageref.setredirect(true);
        return pageref;
    }
    
    private PageReference newSurveyClick(){
        PageReference pageref = new PageReference('/apex/GNE_SFA2_Create_Survey_Layout?objectId='+myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }
    
    //relatedList Custom Buttons     
     public override PageReference callMethod(String methodName){ 
        if('newSurveyClick'.compareTo(methodName) == 0){
            return newSurveyClick(); 
        }
        return super.callMethod(methodName);      
     }    
}