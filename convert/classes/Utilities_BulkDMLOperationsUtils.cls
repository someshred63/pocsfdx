/***********************************************************************************
    
   Created from sqa
    
    ************************************************************************************/
global class Utilities_BulkDMLOperationsUtils {
    private enum DMLOperation {ins,upd}
    public class BulkDMLOperationsUtilsException extends Exception {}

    private static Database.SaveResult[] batchDMLOperation(List<sObject> listObj,DMLOperation operation , boolean allOrNone){
        boolean completed=false;
        integer executedChunks=0;
        integer plannedChunks=Math.floor(listObj.size()/Limits.getLimitDmlRows()).intValue()+1;
        if(isSingleDMLListOverGovernorLimits(listObj)){
            throw new BulkDMLOperationsUtilsException('Batch Upsert not executed since the operation would exceed DML governor limits.');
        }
        List<Database.SaveResult> results=new List<Database.SaveResult>();
        List<Database.SaveResult> chunkResults=new List<Database.SaveResult>();
        for(integer i=0; i<plannedChunks; i++){
            try{
                List<sObject> chunk=subSet(listObj,i*Limits.getLimitDmlRows(),Limits.getLimitDmlRows());
                if(operation==DMLOperation.ins) chunkResults=Database.insert(chunk,allOrNone);
                else if(operation==DMLOperation.upd) chunkResults=Database.update(chunk,allOrNone);
                results.addAll(chunkResults);
            } catch(DmlException e){
                throw e;
            }
        }
        return results;
    }   

    public static Database.DeleteResult[] batchDMLdelete(List<sObject> listObj, boolean allOrNone){ 
        boolean completed=false;
        integer executedChunks=0;
        integer plannedChunks=Math.floor(listObj.size()/Limits.getLimitDmlRows()).intValue()+1;
        if(isSingleDMLListOverGovernorLimits(listObj)){
            throw new BulkDMLOperationsUtilsException('Batch Delete not executed since the operation would exceed DML governor limits.');
        }
        List<Database.DeleteResult> results=new List<Database.DeleteResult>();
        List<Database.DeleteResult> chunkResults=new List<Database.DeleteResult>();
        for(integer i=0; i<plannedChunks; i++){
            try{
                List<sObject> chunk=subSet(listObj,i*Limits.getLimitDmlRows(),Limits.getLimitDmlRows());
                chunkResults=Database.delete(chunk,allOrNone);
                results.addAll(chunkResults);
            } catch(DmlException e){
                throw e;
            }
        }
        return results;
    }   
    public static Database.SaveResult[] batchDMLinsert(List<sObject> listObj, boolean allOrNone){ return batchDMLOperation(listObj, DMLOperation.ins, allOrNone); }
    public static Database.SaveResult[] batchDMLupdate(List<sObject> listObj, boolean allOrNone){ return batchDMLOperation(listObj, DMLOperation.upd, allOrNone); }
    public static Database.UpsertResult[] batchDMLupsert(List<sObject> listObj, boolean allOrNone){
        boolean completed=false;
        integer executedChunks=0;
        integer plannedChunks=Math.floor(listObj.size()/Limits.getLimitDmlRows()).intValue()+1;
        if(isSingleDMLListOverGovernorLimits(listObj)){
            throw new BulkDMLOperationsUtilsException('Batch Upsert not executed since the operation would exceed DML governor limits.');
        }
        List<Database.UpsertResult> results=new List<Database.UpsertResult>();
        List<Database.UpsertResult> chunkResults=new List<Database.UpsertResult>();
        for(integer i=0; i<plannedChunks; i++){
            try{
                List<sObject> chunk=subSet(listObj,i*Limits.getLimitDmlRows(),Limits.getLimitDmlRows());
                chunkResults=Database.upsert(chunk,allOrNone);
                results.addAll(chunkResults);
            } catch(DmlException e){
                throw e;
            }
        }
        return results;
    }
    
    
    /***********************************************************************************
    
    Utilities 
    
    ************************************************************************************/
    public static boolean isDMLBatchSizesOverGovernorLimits(List<integer> objectSizes){
        integer plannedChunks=0;
        for(integer i=0;i<objectSizes.size(); i++){
            //plannedChunks+=Integer.valueOf(Math.floor(objectSizes[i]/Limits.getLimitDmlRows())+1);
            plannedChunks+=objectSizes[i];
        }
        return plannedChunks>Limits.getLimitDmlRows();
    }
    public static boolean isSingleDMLListOverGovernorLimits(List<sObject> listObj){
        return (listObj.size() + Limits.getDMLRows() > Limits.getLimitDmlRows());
    }
    public static List<sObject> subSet(List<sObject> listObj,integer lowerBound,integer length){
        List<sObject> result=listObj.deepClone();
        if(lowerBound==0 && length>=listObj.size())return result;
        result.clear();
        for(integer i=lowerBound; i<lowerBound+length && i<listObj.size(); i++) result.add(listObj[i]);
        return result;
    } 
}