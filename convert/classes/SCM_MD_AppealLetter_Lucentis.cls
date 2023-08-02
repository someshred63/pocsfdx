// Added By: Deepak Yadav
// Doc Name: CMGT-FAX-58 - Appeal Letter Form Analysis v1.1-FINAL
// Modified by Sridhar
public class SCM_MD_AppealLetter_Lucentis extends SCM_MergeDocument {
    
    public SCM_MD_AppealLetter_Lucentis(String caseID,String argLookupID) {
        super(caseID, argLookupID);          
    } 
    
    public override void createMergeFields() 
    {
        //1. CaseID(It Has Only One Field)
        
        SCM_MF_CaseNumber casNum = new SCM_MF_CaseNumber(selectedCase);
        string casNumVal = casNum.getFieldValue();          
        casNum.fieldValue = casNumVal;
        this.mergeRecipientInfo.add(casNum);
        
        // Patient Id
        SCM_MF_PatientId patId = new SCM_MF_PatientId(selectedCase);
        this.mergeRecipientInfo.add(patId);                
         
    }

}