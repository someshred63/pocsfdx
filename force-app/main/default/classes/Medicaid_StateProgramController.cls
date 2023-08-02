public class Medicaid_StateProgramController {

    @AuraEnabled(cacheable=false)
    public static Map<String, List<String>> getPicklistMap(){
        return PicklistHelper.getDependentMap(new Medicaid_Program__c(), 'State__c', 'Program_Name__c');
    }
    
    
    @AuraEnabled(cacheable=false)
    public static Medicaid_Labeler__c getMedicaidLabeler(String parentRecordId){
        return [SELECT Id, Medicaid_State__r.Name FROM Medicaid_Labeler__c WHERE Id = :parentRecordId];
    }
    
    
    @AuraEnabled(cacheable=false)
    public static String createData(String LabelerCode, String State, String StateCode, String ProgramYear,
                                    String Quarter, List<String> selectedProgramList)
    {
        
        String message = 'Success';
        
        try{
            List<Medicaid_Program__c> programList = new List<Medicaid_Program__c>();
            for(String programName : selectedProgramList){
                programList.add(new Medicaid_Program__c(Labeler__c = LabelerCode,
                                                        Program_Year__c = ProgramYear,
                                                        Quarter__c = Quarter,
                                                        State__c = State,
                                                        State_Code__c = StateCode,
                                                        Program_Name__c = programName));
            }
            if(programList.size() > 0){
                insert programList;
            }
        }catch(DmlException e){
            throw new AuraHandledException(e.getDmlMessage(0));
        }catch (Exception e) {
            System.debug('Line no '+e.getLineNumber() +'  '+'Message '+e.getMessage());
            throw new AuraHandledException(e.getLineNumber()+'  '+e.getMessage());
        }
        return message;
        
    }
}