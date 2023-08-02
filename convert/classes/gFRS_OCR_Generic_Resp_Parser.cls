public class gFRS_OCR_Generic_Resp_Parser {
	
	public String name;
	//public List<Forms> forms;
	public Integer workflow_id;
	public Integer batch_id;
	public Integer id;
	//public Metadata metadata;

	
	public static gFRS_OCR_Generic_Resp_Parser parse(String json) {
		return (gFRS_OCR_Generic_Resp_Parser) System.JSON.deserialize(json, gFRS_OCR_Generic_Resp_Parser.class);
	}
}