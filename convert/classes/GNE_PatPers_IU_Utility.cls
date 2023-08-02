public class GNE_PatPers_IU_Utility
{

    public Integer countSegments(String listVal)
    {
        Integer howMany = 0;
        String[] strings = listVal.split(';');
        if (strings.size() == 0)
            return 0;
            
        return strings.size();
    
    }
    
    public List<GNE_PatPers_IU_SurveyInfo> killDuplicates(List<GNE_PatPers_IU_SurveyInfo> pList)
    {
        List<GNE_PatPers_IU_SurveyInfo> dataSet = new List<GNE_PatPers_IU_SurveyInfo>();
    
        for(GNE_PatPers_IU_SurveyInfo info : pList)
        {
            string question = info.questionNumber;
            string answer = info.answerNumber;
            string answerText = info.answerText;
            
            boolean bfound = false;
            integer indexOfExisting = -1;
            
            for (GNE_PatPers_IU_SurveyInfo copy : dataSet)
            {
                indexOfExisting = indexOfExisting + 1;
                
                if ((copy.answerNumber.equals(answer)) && 
                        (copy.questionNumber.equals(question)) && 
                                (copy.answerText!= null && copy.answerText.equals(answerText)))
                    bFound = true;
                if (bFound)
                    break;
            }   
            
            if (! bFound)
            {
                dataSet.add(info);
            }
 
        } // end for loop
        return dataSet;
    }

}