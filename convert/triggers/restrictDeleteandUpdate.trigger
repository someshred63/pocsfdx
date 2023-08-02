trigger restrictDeleteandUpdate on CHV_Unpublished_Brand__c (before delete, before update) {

    if(Trigger.isUpdate){
        for(CHV_Unpublished_Brand__c obj: Trigger.new){
            if(obj.Published__c && Trigger.oldmap.get(obj.id).Published__c) {
            obj.addError('You can not update this record when the record is already Published');
            }
          }
        }
   
    if(Trigger.isDelete){
        for(CHV_Unpublished_Brand__c obj: Trigger.old){
        if(obj.Published__c){
            obj.addError('You can not delete this record when the record is already Published');
            } 
        }
    }
 }