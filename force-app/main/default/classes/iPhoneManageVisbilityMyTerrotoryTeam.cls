@RestResource(urlMapping='/iPhoneManageVisbilityMyTerrotoryTeam/*')
global with sharing class iPhoneManageVisbilityMyTerrotoryTeam {
    @HttpPost
     global static iPhone_Commons_gne.RestResponse processRequest(String tmmunixId, String terrNumber, Boolean isVisible) {
        return iPhone_Commons_gne.buildResponse(
                new ManageVisbilityResponseBuilder(),
                new RequestArgs(tmmunixId, terrNumber, isVisible) 
        );
    }
    
    class ManageVisbilityResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {
        String ERROR_MESSAGE_ARG_ISMISSING = 'Argument missing';
        public iPhone_Commons_gne.RestResponse build(Object args){
            RequestArgs processArgs = (RequestArgs)args;
            if(processArgs.unixId == null || processArgs.terrNumber == null || processArgs.isVisible == null) {
                throw new ArgumentException(ERROR_MESSAGE_ARG_ISMISSING);
            }
            User user = iPhone_DAO.getUserByExternalId(processArgs.unixId);            
            List<My_Territory_Team_gne__c> teamTerritories = GNE_My_Territory_Team_DAO.getTerritoryTeamByTerritoryAndUnixId(processArgs.terrNumber, processArgs.unixId);
            
            if(teamTerritories.isEmpty() && processArgs.isVisible){
                My_Territory_Team_gne__c mtt = new My_Territory_Team_gne__c();
                mtt.isManualAdded_gne__c = true;
                mtt.Territory_Number_gne__c = processArgs.terrNumber;
                mtt.Unix_User_Id_gne__c = processArgs.unixId;
                mtt.UserId_gne__c = user != null ? user.Id : null;
                
                insert mtt;
                return new VisbilityRestResponse(mtt);
            } else if(teamTerritories.isEmpty() && !processArgs.isVisible) {
                return new VisbilityRestResponse('Record does not exist. No reason for create only to hide record.');
            }else if(teamTerritories[0].isManuallyRemoved_gne__c == processArgs.isVisible) {
                teamTerritories[0].isManuallyRemoved_gne__c = !processArgs.isVisible;
                update teamTerritories[0];
                //to do if record size > 1 ?
            }

            return new VisbilityRestResponse(teamTerritories[0]);
        }
    }
    
    class RequestArgs {
        String unixId; 
        String terrNumber; 
        Boolean isVisible;
        
        public RequestArgs(String unixId, String terrNumber, Boolean isVisible) {
            this.unixId = unixId;
            this.terrNumber = terrNumber;
            this.isVisible = isVisible;
        }
    }

    public class VisbilityRestResponse extends iPhone_Commons_gne.RestResponse {
        public String comment;
        public My_Territory_Team_gne__c result;
        
        public VisbilityRestResponse(My_Territory_Team_gne__c result){
            this.result = result;
        }
        
        public VisbilityRestResponse(String comment){
            this.comment = comment;
        }
    }
    
    public class ArgumentException extends Exception {}
}