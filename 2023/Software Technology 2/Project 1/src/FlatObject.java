import java.util.ArrayList;

public class FlatObject {
    private String street, building_meter, current_reading_date, previous_reading_date;
    private int building_number, current_reading, previous_reading;
    private ArrayList<String> tenant_meters;

    public FlatObject(String street,
                      int building_number,
                      String building_meter,
                      int current_reading,
                      String current_reading_date,
                      int previous_reading,
                      String previous_reading_date,
                      ArrayList<String> tenant_meters)
    {
        this.street = street;
        this.building_number = building_number;
        this.building_meter = building_meter;
        this.current_reading = current_reading;
        this.current_reading_date = current_reading_date;
        this.previous_reading = previous_reading;
        this.previous_reading_date = previous_reading_date;
        this.tenant_meters = tenant_meters;
    }

    public String getStreet() {return street;}

    public void setStreet(String street) {this.street = street;}

    public String getBuilding_meter() {return building_meter;}

    public void setBuilding_meter(String building_meter) {this.building_meter = building_meter;}

    public String getCurrent_reading_date() {return current_reading_date;}

    public void setCurrent_reading_date(String current_reading_date) {this.current_reading_date = current_reading_date;}

    public String getPrevious_reading_date() {return previous_reading_date;}

    public void setPrevious_reading_date(String previous_reading_date) {this.previous_reading_date = previous_reading_date;}

    public int getBuilding_number() {return building_number;}

    public void setBuilding_number(int building_number) {this.building_number = building_number;}

    public int getCurrent_reading() {return current_reading;}

    public void setCurrent_reading(int current_reading) {this.current_reading = current_reading;}

    public int getPrevious_reading() {return previous_reading;}

    public void setPrevious_reading(int previous_reading) {this.previous_reading = previous_reading;}

    public ArrayList<String> getTenant_meters() {return tenant_meters;}

    public void setTenant_meters(ArrayList<String> tenant_meters) {this.tenant_meters = tenant_meters;}
}
