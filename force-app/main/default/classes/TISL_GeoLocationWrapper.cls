public class TISL_GeoLocationWrapper {
	public Decimal latitude {get; set;}
	public Decimal longitude {get; set;}

	public TISL_GeoLocationWrapper(Decimal latitude, Decimal longitude) {
		this.latitude = latitude;
		this.longitude = longitude;
	}
}