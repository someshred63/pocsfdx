// Added by Jatin Setia
// Merge class for Referral Office

public class SCM_MF_ReferralOffice  extends SCM_MergeField {
    private string case_ID;
    private Case officeOf ;
    private string accountName;
    
    public SCM_MF_ReferralOffice(String caseID) {
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        Key='Referral Office';
        className = 'SCM_MF_ReferralOffice';
        this.case_ID= caseID;
    }
public SCM_MF_ReferralOffice(String caseID, string newkey) {
       this(caseID); 
        key = newkey;
    }
    public override String getFieldValue() {
        
        List<Case> officeOfList;
        try
        {
         officeOfList = [Select c.Referred_By_Party_gne__r.Name From Case c
        				where c.id=:case_ID LIMIT 100];   
        }catch(Exception e){
        	  return '';
        }
        if(officeOfList.size()>=1) {
            officeOf = officeOfList[0]; 
            accountName = officeOf.Referred_By_Party_gne__r.Name; 
            accountName=(accountName==null)?'':accountName;
            
            return accountName;
        } 
        else 
        {
            return '';
        }
    }      

}