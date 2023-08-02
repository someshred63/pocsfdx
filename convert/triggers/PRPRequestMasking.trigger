trigger PRPRequestMasking on PRP_Request__c (before insert,before update) {
     /* This trigger is not used anymore.
     for(PRP_Request__c  prpRequest:Trigger.new){
        if(Trigger.isBefore){
         for(PRP_Request__c prpReq :Trigger.new){
             if(prpReq.Product_Name__c=='Xolair'    ){
                 prpReq.ownerid=label.PRP_Request_owner_for_Xolair;
             }else if(prpReq.Product_Name__c=='Actemra')    {
                 prpReq.ownerid=label.PRP_Request_owner_for_Acterma;
             }
             else if(prpReq.Product_Name__c=='Rituxen') {
                 prpReq.ownerid=label.PRP_Request_owner_for_Rituxen;
             }
             else if(prpReq.Product_Name__c=='Lucentis')    {
                 prpReq.ownerid=label.PRP_Request_owner_for_Lucentis;
             }
        }
         
        if(!String.isBlank(prpRequest.Account_Number__c) || !String.isBlank(prpRequest.Routing_Number__c) )
        {
            if(!String.isBlank(prpRequest.Account_Number__c)){
                prpRequest.Account_Number_UnMasked__c=prpRequest.Account_Number__c;
                String accNum=prpRequest.Account_Number__c;
                String accMasked=accNum.substring(accNum.length()-4,accNum.length());
                for(Integer i=0; i<accNum.length()-4;i++){
                    accMasked='X'+accMasked;
                }
                prpRequest.Account_Number__c   =accMasked;
            }
            if(!String.isBlank(prpRequest.Routing_Number__c)){
                prpRequest.ABA_Routing_Number_UnMasked__c=prpRequest.Routing_Number__c;
                String routingNum=prpRequest.Routing_Number__c;
                String routingMasked=routingNum.substring(routingNum.length()-4,routingNum.length());
                for(Integer i=0; i<routingNum.length()-4;i++){
                    routingMasked='X'+routingMasked;
                }
                prpRequest.Routing_Number__c=routingMasked;
            }
        }
     }
     */
}