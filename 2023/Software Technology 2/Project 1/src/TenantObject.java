public class TenantObject {
    private String honorific, fname, lname, corponame, meternumber, current_reading_date, previous_reading_date;
    private int current_meter_reading, previous_meter_reading;

    public TenantObject(String honorific,
                        String fname,
                        String lname,
                        String corponame,
                        String meternumber,
                        int current_meter_reading,
                        String current_reading_date,
                        int previous_meter_reading,
                        String previous_reading_date)
    {
        this.honorific = honorific;
        this.fname = fname;
        this.lname = lname;
        this.corponame = corponame;
        this.meternumber = meternumber;
        this.current_meter_reading = current_meter_reading;
        this.current_reading_date = current_reading_date;
        this.previous_meter_reading = previous_meter_reading;
        this.previous_reading_date = previous_reading_date;
    }

    public String getHonorific() {return honorific;}

    public void setHonorific(String honorific) {this.honorific = honorific;}

    public String getFname() {return fname;}

    public void setFname(String fname) {this.fname = fname;}

    public String getLname() {return lname;}

    public void setLname(String lname) {this.lname = lname;}

    public String getCorponame() {return corponame;}

    public void setCorponame(String corponame) {this.corponame = corponame;}

    public String getMeternumber() {return meternumber;}

    public void setMeternumber(String meternumber) {this.meternumber = meternumber;}

    public String getCurrent_reading_date() {return current_reading_date;}

    public void setCurrent_reading_date(String current_reading_date) {this.current_reading_date = current_reading_date;}

    public String getPrevious_reading_date() {return previous_reading_date;}

    public void setPrevious_reading_date(String previous_reading_date) {this.previous_reading_date = previous_reading_date;}

    public int getCurrent_meter_reading() {return current_meter_reading;}

    public void setCurrent_meter_reading(int current_meter_reading) {this.current_meter_reading = current_meter_reading;}

    public int getPrevious_meter_reading() {return previous_meter_reading;}

    public void setPrevious_meter_reading(int previous_meter_reading) {this.previous_meter_reading = previous_meter_reading;}
}
