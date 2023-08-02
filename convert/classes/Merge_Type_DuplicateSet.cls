public class Merge_Type_DuplicateSet {

    public String winnerRecordId    = null;
    public Set<String> LoserIdSet   = null;

    // code, error desc list per loser Id
    public Map<String,List<String>> LoserToExceptionCodeList = null;
    public Map<String,List<String>> LoserToErrorDescList=null;

    public void initialize() {
        LoserToExceptionCodeList = new Map<String,List<String>>();
        LoserToErrorDescList     = new Map<String,List<String>>();
    }

}