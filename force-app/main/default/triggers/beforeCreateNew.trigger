trigger beforeCreateNew on C_Ops_SPLOA_Product__c (before insert) {
    C_Ops_SPLOA_Product__c newOne;
    List <C_Ops_SPLOA_Product__c> ps= trigger.new;
    
    if(ps!=null && ps.size()>0) {
        newOne=ps[0];
        List<C_Ops_SPLOA_Product__c> curOnes = [select name from C_Ops_SPLOA_Product__c where name=:newOne.name];
        if(curOnes !=null && curOnes.size()>0)
            newOne.addError('Product '+newOne.name+' is already created');
    }
}