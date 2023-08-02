/**
* @File Name:   Medicaid_eWorkflow_WithdrawContrlr
* @Description: Controller for  Aura component
* @group:       Apex Class
* @Author:     Rabindranath
* @Modification Log  :
______________________________________________________________________________________
* Ver       Date         Modification
* 1.0       2022-04-28   Created the Component
**/
public class Medicaid_eWorkflow_WithdrawContrlr {
    @AuraEnabled
    public static SPCM_Medicaid_Payment_Packet__c retrieveMedicaidInfo(String recordId){
       try{
            SPCM_Medicaid_Payment_Packet__c med= new SPCM_Medicaid_Payment_Packet__c();
            
            med=[select id,Initiated_By__c,Approval_Status__c from SPCM_Medicaid_Payment_Packet__c where id=: recordId limit 1];
            return med;
        }
        catch(exception exp){
            throw new AuraHandledException(exp.getMessage());
        }
    }
      @AuraEnabled
    public static void changeStatusToWithdraw(String recordId){
        
        try{
            SPCM_Medicaid_Payment_Packet__c med= new SPCM_Medicaid_Payment_Packet__c(id=recordId);
            med.Approval_Status__c='Withdrawn';
            update med;
        }
        catch(exception exp){
            throw new AuraHandledException(exp.getMessage());
        }
    }
    // The below 2 methods are for SPCM GP eWorkflow
     @AuraEnabled
    public static SPCM_GP_Payment_Packet__c retrieveMedicaidInfoGP(String recordId){
       try{
            SPCM_GP_Payment_Packet__c med= new SPCM_GP_Payment_Packet__c();
            
            med=[select id,Initiated_By__c,Approval_Status__c from SPCM_GP_Payment_Packet__c where id=: recordId limit 1];
            return med;
        }
        catch(exception exp){
            throw new AuraHandledException(exp.getMessage());
        }
    }
      @AuraEnabled
    public static void changeStatusToWithdrawGP(String recordId){
        
        try{
            SPCM_GP_Payment_Packet__c med= new SPCM_GP_Payment_Packet__c(id=recordId);
            med.Approval_Status__c='Withdrawn';
            update med;
        }
        catch(exception exp){
            throw new AuraHandledException(exp.getMessage());
        }
    }
}