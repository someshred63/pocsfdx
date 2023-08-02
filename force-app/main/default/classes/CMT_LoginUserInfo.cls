public class CMT_LoginUserInfo
{
	public String Username { get; set; }
	public String Password { get; set; }
	
	public CMT_LoginUserInfo (String username, String password)
	{
		this.Username = username;
		this.Password = password;
	}
}