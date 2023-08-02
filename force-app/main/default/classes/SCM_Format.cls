public class SCM_Format {
	public static string ToCurrency(decimal Num)
	{
		string  ret = string.valueof(num);
		return toCurrency(ret);
	}
	public static string ToCurrency(string Num)
	{
		
	try {
		string  ret = string.valueof(num);
		string dec = '';
		try {
			dec = ret.substring(ret.lastIndexOf('.'));
			ret = ret.substring(0, ret.lastIndexOf('.'));
		}	
		catch (exception ex)
		{
			
		}	
		
		integer cnt = 1;
		 string fin = '';
		for (integer i=ret.length();i > 0;i--)
		{
			fin = ret.substring(i-1, i) + fin;
			if (cnt == 3){
				if (i != 1){
					fin = ',' + fin;
					cnt =0;
				}
			}
			cnt +=1;
		}
		
		if (dec.length() == 1) {
			dec += '.00';
			
		}
		if (dec.length() == 2) {
			dec += '0';
			
		}
		
		return '$' + fin + dec;
		}
		catch (exception ex2)
		{
			return '';
		}
	}


}