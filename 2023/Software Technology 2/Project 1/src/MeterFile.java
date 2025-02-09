import java.io.FileNotFoundException;
import java.io.FileReader;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Objects;
import java.util.Scanner;

public class MeterFile {
    private String file;
    Scanner infile;

    public MeterFile(String meterfile) {
        this.file = meterfile;
    }

    public String getFile() {
        return file;
    }

    public void setFile(String file) {
        this.file = file;
    }

    public int getFileLength(){
        int filelength = 0;

        //calculate file length
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

    public ArrayList<TenantObject> readTenantObjectIntoArrayList(){
        ArrayList<TenantObject> objlist = new ArrayList<>();
        String cleanline;

        try{
            infile = new Scanner(new FileReader(file));

            while(infile.hasNextLine()){
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

                    int current_meter_reading = Integer.parseInt(splitline[5]);
                    int previous_meter_reading = Integer.parseInt(splitline[7]);

                    //create tenant object
                    TenantObject tenantobj = new TenantObject(splitline[0],
                            splitline[1],
                            splitline[2],
                            splitline[3],
                            splitline[4],
                            current_meter_reading,
                            splitline[6],
                            previous_meter_reading,
                            splitline[8]);

                    //add obj to list
                    objlist.add(tenantobj);
                }
            }
        }
        //error handler
        catch(FileNotFoundException e){
            System.out.printf("Error %s was not found", file);
        }
        infile.close();

        return objlist;
    }

    public int calculateChecksum(){
        int checksum = 0;
        ArrayList<TenantObject> objlist = readTenantObjectIntoArrayList();

        //loop objects and calculate checksum
        for(TenantObject obj: objlist){
            checksum += obj.getCurrent_meter_reading();
        }
        return checksum;
    }

    public void printMeterRead(){
        int filelength = getFileLength();
        int checksum = calculateChecksum();

        NumberFormat nf = new DecimalFormat("0.#######E0");

        System.out.printf("Reading meter file %s\n", file);
        System.out.printf("Number of meters read in is: %d\n", filelength);
        System.out.printf("Total sum (checksum) of all current meter readings is: %s\n", nf.format(checksum));
        System.out.printf("Total sum (checksum) of all current meter readings is: %d\n", checksum);
    }
}
