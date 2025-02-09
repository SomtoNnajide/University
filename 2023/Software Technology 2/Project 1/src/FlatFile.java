import java.awt.*;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Objects;
import java.util.Scanner;

public class FlatFile {
    private String file;
    private final double RATE = 0.205;
    private final int METER_LIMIT = 1000000;
    public double bill_usage = 0.0;
    Scanner infile;
    Scanner in = new Scanner(System.in);

    public FlatFile(String flatfile) {
        this.file = flatfile;
    }

    public String getFile() {
        return file;
    }

    public void setFile(String file) {
        this.file = file;
    }

    public int getFileLength(){
        int filelength = 0;

        //calculate length of file
        try{
            infile = new Scanner(new FileReader(file));

            while(infile.hasNextLine()){
                if(!Objects.equals(infile.nextLine(), "")){
                    filelength++;
                }
            }
        }
        catch(FileNotFoundException e) {
            System.out.printf("Error %s was not found", file);
        }
        return filelength;
    }

    public ArrayList<FlatObject> readFlatObjectIntoArrayList(){
        ArrayList<FlatObject> objlist = new ArrayList<>();

        String cleanline;

        try{
            infile = new Scanner(new FileReader(file));

            while(infile.hasNextLine()){
                ArrayList<String> tenant_meters = new ArrayList<>(); //create new list of flat tenants on each new line(flat), will be added to flat object

                String line = infile.nextLine().trim();

                //check for blank line
                if(line.equals("")){
                    break;
                }
                else{
                    //check for trailing comma
                    //if trailing, remove comma
                    //else line is already valid
                    if(line.endsWith(",")){
                        StringBuffer sb = new StringBuffer(line);

                        cleanline = String.valueOf(sb.deleteCharAt(sb.length()-1));
                    }
                    else{
                        cleanline = line;
                    }

                    //split and parse
                    String[] splitline = cleanline.split(",");

                    int building_number = Integer.parseInt(splitline[1]);
                    int current_reading = Integer.parseInt(splitline[3]);
                    int previous_reading = Integer.parseInt(splitline[5]);

                    //loop tenants in line
                    //add to tenant meters list
                    for(int i = 7; i < splitline.length; i++){
                        tenant_meters.add(splitline[i]);
                    }

                    //create flat object
                    FlatObject flatobj = new FlatObject(splitline[0],
                            building_number,
                            splitline[2],
                            current_reading,
                            splitline[4],
                            previous_reading,
                            splitline[6],
                            tenant_meters);

                    //add obj to list
                    objlist.add(flatobj);
                }
            }
        }
        //exception handler
        catch(FileNotFoundException e){
            System.out.printf("Error %s was not found", file);
        }
        infile.close();

        return objlist;
    }

    public int calculateChecksum(){
        int checksum = 0;

        ArrayList<FlatObject> objlist = readFlatObjectIntoArrayList();

        //loop objects and calculate checksum
        for(FlatObject obj: objlist){
            checksum += obj.getCurrent_reading();
        }
        return checksum;
    }

    public int countMetersRead(){
        int metersread = 0;

        ArrayList<FlatObject> objlist = readFlatObjectIntoArrayList();

        //loop objects and calculate total meters read
        for(FlatObject obj: objlist){
            metersread += obj.getTenant_meters().size();
        }

        return metersread;
    }

    public FlatObject billForOneFlat(){
        int usage;
        FlatObject flatObject = null;

        System.out.print("Enter street number: ");
        int street_number = Integer.parseInt(in.nextLine().trim());

        System.out.print("Enter street name: ");
        String street_name = in.nextLine().trim();

        //validate input
        String clean_name = cleanStreetName(street_name);

        ArrayList<FlatObject> objlist = readFlatObjectIntoArrayList();

        //loop flat objects
        for(FlatObject obj: objlist){
            //check which flat was entered
            if(obj.getBuilding_number() == street_number && Objects.equals(obj.getStreet(), clean_name)){
                flatObject = obj; //returned obj to be used in search and compute

                //calculate usage for flat
                if(obj.getCurrent_reading() < obj.getPrevious_reading()){
                    usage = (METER_LIMIT - obj.getPrevious_reading()) + obj.getCurrent_reading();
                }
                else{
                    usage = obj.getCurrent_reading() - obj.getPrevious_reading();
                }

                bill_usage = (double) usage * RATE;

                //output format
                formatBillForOneFlat(street_number,
                        clean_name,
                        obj.getCurrent_reading(),
                        obj.getCurrent_reading_date(),
                        obj.getPrevious_reading(),
                        obj.getPrevious_reading_date(),
                        usage,
                        bill_usage);
                
            }
        }
        return flatObject;
    }

    public String cleanStreetName(String street){
        //convert the first letter of each word to uppercase
        String clean;

        //check for whitespace
        //if whitespace => multi-word street name
        //split input on whitespace
        //convert the first letter of each split to uppercase
        //rejoin and return
        //else
        //no whitespace => single word street name
        //convert first letter to uppercase
        //return
        if(street.contains(" ")){
            String[] str = street.split(" ");

            String first_word = str[0].substring(0,1).toUpperCase() + str[0].substring(1);
            String second_word = str[1].substring(0,1).toUpperCase() + str[1].substring(1);
            clean = first_word + " " + second_word;
        }
        else{
            clean = street.substring(0,1).toUpperCase() + street.substring(1);
        }

        return clean;
    }

    public void formatBillForOneFlat(int number, String street, int cr, String crd, int pr, String prd, int usage, double bu){
        NumberFormat nf = NumberFormat.getCurrencyInstance();

        System.out.printf("\n%-16s %2d %-20s\n", "Showing Bill for", number, street);
        System.out.println("------------------------------------------");
        System.out.printf("%-7s %6s %-8s %-6d  %-10s\n", "Current", "meter", "reading", cr, crd);
        System.out.printf("%-8s %-5s %-7s %7d  %-10s\n", "Previous", "meter", "reading", pr, prd);
        System.out.printf("%-5s %36d\n", "Usage", usage);
        System.out.printf("%-4s %33.3f/kwh\n", "Rate", RATE);
        System.out.printf("%-9s %32s\n", "BillUsage", nf.format(Double.valueOf(String.format("%.2f", bu))));
    }

    public void billForAllFlats(){
        int usage;
        int total_usage = 0;
        int records_processed = getFileLength();

        System.out.println("Compute bill for all Blocks of flats\n");

        ArrayList<FlatObject> objlist = readFlatObjectIntoArrayList();

        //loop objects and calculate usage
        for(FlatObject obj: objlist){
            if(obj.getCurrent_reading() < obj.getPrevious_reading()){
                usage = (METER_LIMIT - obj.getPrevious_reading()) + obj.getCurrent_reading();
            }
            else{
                usage = obj.getCurrent_reading() - obj.getPrevious_reading();
            }
            total_usage += usage;
            bill_usage = (double) total_usage * RATE;
        }

        //output format
        formatBillForAllFlats(records_processed);
    }

    public void formatBillForAllFlats(int rp){
        System.out.printf("%27s\n", "Total For All Flats");
        System.out.print("----------------------------------\n");
        System.out.printf("%-17s : %,14.2f\n", "Total", bill_usage);
        System.out.printf("%17s : %14d\n", "Records Processed", rp);
    }

    public void printFlatRead(){
        int filelength = getFileLength();
        int checksum = calculateChecksum();
        int metersread = countMetersRead();

        NumberFormat nf = new DecimalFormat("0.#######E0");

        System.out.printf("Reading flat file %s\n", file);
        System.out.printf("Number of flats read in is: %d\n", filelength);
        System.out.printf("Number of meters read in is: %d\n", metersread);
        System.out.printf("Total sum (checksum) of all current flats readings is: %s\n", nf.format(checksum));
        System.out.printf("Total sum (checksum) of all current flats readings is: %d\n", checksum);
    }
}
