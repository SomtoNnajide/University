import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Objects;

public class ComputeAndSummarise {
    private String mFile;
    private String fFile;
    private final double RATE = 0.205;
    private final int METER_LIMIT = 1000000;

    public ComputeAndSummarise(String meterfile, String flatfile){
        this.mFile = meterfile;
        this.fFile = flatfile;
    }

    public String getmFile() {return mFile;}

    public void setmFile(String mFile) {this.mFile = mFile;}

    public String getfFile() {return fFile;}

    public void setfFile(String fFile) {this.fFile = fFile;}

    public void computeAndSummarise(){
        String flat_name = "";
        double metered_total = 0.0;
        double base = 0.0;
        double flat_bill = 0.0;
        int flat_usage;
        int tenant_usage;

        //instantiate and pass files
        MeterFile mf = new MeterFile(mFile);
        FlatFile ff = new FlatFile(fFile);

        //get/create object arraylists
        ArrayList<TenantObject> tenantobjlist = mf.readTenantObjectIntoArrayList();
        ArrayList<FlatObject> flatobjlist = ff.readFlatObjectIntoArrayList();
        ArrayList<SummarisedFlatObject> sfolist = new ArrayList<>();

        //look at each tenant in a flat and create an object of them
        for(FlatObject flatobj: flatobjlist){
            for(String meters: flatobj.getTenant_meters()){
                for(TenantObject tenantobj: tenantobjlist){
                    if(Objects.equals(meters, tenantobj.getMeternumber())) {
                        if(tenantobj.getCurrent_meter_reading() < tenantobj.getPrevious_meter_reading()){
                            tenant_usage = (METER_LIMIT - tenantobj.getPrevious_meter_reading()) + tenantobj.getCurrent_meter_reading();
                        }else{
                            tenant_usage = tenantobj.getCurrent_meter_reading() - tenantobj.getPrevious_meter_reading();
                        }
                        base = (double) tenant_usage * RATE;
                    }
                }
                //on the flat line
                //before the loop jumps to next line
                //create object with flat name, flat bill and metered total for current line(flat)
                flat_name = flatobj.getBuilding_number() + " " + flatobj.getStreet();
                metered_total += base;

                //calculate flat usage/bill
                if(flatobj.getCurrent_reading() < flatobj.getPrevious_reading()){
                    flat_usage = (METER_LIMIT - flatobj.getPrevious_reading()) + flatobj.getCurrent_reading();
                }
                else{
                    flat_usage = flatobj.getCurrent_reading() - flatobj.getPrevious_reading();
                }

                flat_bill = (double) flat_usage * RATE;
            }
            //on new line(flat)
            //create object of previous line(flat)
            //reset flat bill and metered total for new line(flat)
            //add obj to list
            SummarisedFlatObject sfo = new SummarisedFlatObject(flat_name, flat_bill, 0.0, 0.0, 0.0, metered_total);
            sfolist.add(sfo);
            flat_bill = 0.0;
            metered_total = 0.0;
        }

        updateObject(sfolist);

        double[] totalsarr = calculateTotals(sfolist);

        printFormat(sfolist, totalsarr[0], totalsarr[1], totalsarr[2], totalsarr[3]);
    }

    public void updateObject(ArrayList<SummarisedFlatObject> list) {
        double tenant_bill;
        double diff;
        double diffadj;

        //loop objects
        //calculate values and add to object using set() methods
        for (SummarisedFlatObject sfo : list) {
            tenant_bill = Math.max(sfo.getMetered_total(), sfo.getFlat_bill());
            sfo.setTenant_bill(tenant_bill);

            double check_diff = sfo.getFlat_bill() - sfo.getMetered_total();

            if (check_diff < 0.0) {
                diff = 0.0;
                diffadj = check_diff;

                sfo.setDiff(diff);
                sfo.setDiff_adj(diffadj);
            } else {
                diffadj = check_diff;

                sfo.setDiff(check_diff);
                sfo.setDiff_adj(diffadj);
            }
        }
    }

    public double[] calculateTotals(ArrayList<SummarisedFlatObject> list){
        double total_flat_bill = 0.0;
        double total_diff = 0.0;
        double total_diff_adj = 0.0;
        double total_tenant_bill = 0.0;

        double[] totalsarr = new double[4];

        //loop objects
        //calculate required totals
        for(SummarisedFlatObject sfo: list){
            total_flat_bill += sfo.getFlat_bill();
            total_diff += sfo.getDiff();
            total_diff_adj += sfo.getDiff_adj();
            total_tenant_bill += sfo.getTenant_bill();
        }

        totalsarr[0] = total_flat_bill;
        totalsarr[1] = total_diff;
        totalsarr[2] = total_diff_adj;
        totalsarr[3] = total_tenant_bill;

        return totalsarr;
    }

    public void printFormat(ArrayList<SummarisedFlatObject> list, double tfb, double td, double tda, double ttb){
        NumberFormat nf = NumberFormat.getCurrencyInstance();

        System.out.println("List Adjusted bill for all Blocks of flats");
        System.out.printf("%-30s %-15s %-15s %-15s %-15s\n", "Flat Address", "BC Bill", "Difference", "DiffAdj", "Tenant Bill");
        System.out.println("------------------------------------------------------------------------------------------");

        for(SummarisedFlatObject sfo: list){
            System.out.printf("%-30s %-15s %-15s %-15s %-15s\n", sfo.getFlat_address(),
                    nf.format(Double.valueOf(String.format("%.2f", sfo.getFlat_bill()))),
                    nf.format(Double.valueOf(String.format("%.2f", sfo.getDiff()))),
                    nf.format(Double.valueOf(String.format("%.2f", sfo.getDiff_adj()))),
                    nf.format(Double.valueOf(String.format("%.2f", sfo.getTenant_bill()))));
        }

        System.out.println("------------------------------------------------------------------------------------------");
        System.out.printf("%-30s %-15s %-15s %-15s %-15s\n", "Total",
                nf.format(Double.valueOf(String.format("%.2f", tfb))),
                nf.format(Double.valueOf(String.format("%.2f", td))),
                nf.format(Double.valueOf(String.format("%.2f", tda))),
                nf.format(Double.valueOf(String.format("%.2f", ttb))));
    }
}

