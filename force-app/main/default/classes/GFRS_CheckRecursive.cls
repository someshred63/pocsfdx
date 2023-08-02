public with sharing class GFRS_CheckRecursive {

    private static Boolean run = true;
    private static Boolean runAfterTrigger = true;

    public static Boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }

    public static Boolean runOnceAfter(){
        if(runAfterTrigger){
            runAfterTrigger=false;
            return true;
        }else{
            return runAfterTrigger;
        }
    }
}