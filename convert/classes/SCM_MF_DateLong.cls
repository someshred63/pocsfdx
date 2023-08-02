//Generates today's date in Month DD, YYYY format

public class SCM_MF_DateLong extends SCM_MergeField {
  public SCM_MF_DateLong() {
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        setKey('DateLong');
        className = 'SCM_MF_DateLong';
    
        Date d = Date.today();
        Integer monthNumber = d.month();
        String month = '';
        
        if (monthNumber == 1)
            month = 'January';
        else if (monthNumber == 2)
            month = 'February';
        else if (monthNumber == 3)
            month = 'March';
        else if (monthNumber == 4)
            month = 'April';
        else if (monthNumber == 5)
            month = 'May';
        else if (monthNumber == 6)
            month = 'June';
        else if (monthNumber == 7)
            month = 'July';
        else if (monthNumber == 8)
            month = 'August';
        else if (monthNumber == 9)
            month = 'September';
        else if (monthNumber == 10)
            month = 'October';
        else if (monthNumber == 11)
            month = 'November';
        else if (monthNumber == 12)
            month = 'December';
            
        fieldValue = month + ' ' + d.day() + ', ' + d.year();   
  }  
}