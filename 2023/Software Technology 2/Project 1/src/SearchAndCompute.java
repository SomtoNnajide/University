import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Objects;

public class SearchAndCompute {
    private String mFile;
    private String fFile;
    private final double RATE = 0.205;
    private final int METER_LIMIT = 1000000;

    public SearchAndCompute(String meterfile, String flatfile){
        this.mFile = meterfile;
        this.fFile = flatfile;
    }

    public String getmFile() {return mFile;}

    public void setmFile(String mFile) {this.mFile = mFile;}

    public String getfFile() {return fFile;}

    public void setfFile(String fFile) {this.fFile = fFile;}

    public void searchAndCompute(){
        int usage;
        double base;
        double diff;
        double metered_total;
        double adjusted_total;

        //instantiate and pass files
        FlatFile ff = new FlatFile(fFile);
        MeterFile mf = new MeterFile(mFile);

        //call and create object lists
        ArrayList<TenantObject> tenantobjlist = mf.readTenantObjectIntoArrayList();
        ArrayList<AdjustedTenantObject> atolist = new ArrayList<>();

        FlatObject flatobj = ff.billForOneFlat();

        //foreach meter in flat tenant meters
        //foreach tenant in tenant objlist
        //if the two meters are equal (tenant in flat)
        //calculate/retrieve details
        //create object and add to object list
        for(String meter: flatobj.getTenant_meters()){
            for(TenantObject tenant: tenantobjlist){
                if(Objects.equals(meter, tenant.getMeternumber())){
                    String tenant_name = tenant.getHonorific() + " " + tenant.getFname() + " " + tenant.getLname();

                    if(tenant.getCurrent_meter_reading() < tenant.getPrevious_meter_reading()){
                        usage = (METER_LIMIT - tenant.getPrevious_meter_reading()) + tenant.getCurrent_meter_reading();
                    }else{
                        usage = tenant.getCurrent_meter_reading() - tenant.getPrevious_meter_reading();
                    }

                    base = (double) usage * RATE;

                    AdjustedTenantObject ato = new AdjustedTenantObject(tenant_name,
                            tenant.getMeternumber(),
                            tenant.getCurrent_meter_reading(),
                            tenant.getPrevious_meter_reading(),
                            usage,
                            base,
                            0.0,
                            0.0,
                            0.0);

                    atolist.add(ato);
                }
            }
        }

        metered_total = calcMeteredTotal(atolist);

        diff = ff.bill_usage - metered_total;

        adjusted_total = updateObject(atolist, diff, metered_total);

        printFormat(atolist, metered_total, diff, adjusted_total);
    }

    public double calcMeteredTotal(ArrayList<AdjustedTenantObject> list){
        double metered_total = 0.0;

        for(AdjustedTenantObject ato: list){
            metered_total += ato.getBase();
        }

        return metered_total;
    }

    public double updateObject(ArrayList<AdjustedTenantObject> list, double diff, double mt){
        double percent;
        double adj;
        double total;
        double adjusted_total = 0.0;

        for(AdjustedTenantObject ato: list){
            percent = (ato.getBase()/mt) * 100;
            ato.setPercent(percent);

            if(diff > 0.0){
                adj = (ato.getPercent()/100) * diff;
                ato.setAdj(adj);

                total = ato.getBase() + ato.getAdj();
                ato.setTotal(total);

                adjusted_total += ato.getTotal();
            }
            else{
                adj = 0.0;
                ato.setAdj(adj);

                total = ato.getBase();
                ato.setTotal(total);

                adjusted_total += ato.getTotal();
            }
        }

        return adjusted_total;
    }

    public void printFormat(ArrayList<AdjustedTenantObject> list, double mt, double diff, double at){
        NumberFormat nf = NumberFormat.getCurrencyInstance();

        System.out.println("\n\nCompute Adjusted bill for one Block of flats");
        System.out.printf("%-30s %-7s %-6s %-6s %-6s %-7s %-10s %-7s %-10s\n", "Tenant", "meter", "curr", "prev", "usage", "pcnt%", "$base", "$adj", "$total");
        System.out.println("-----------------------------------------------------------------------------------------------");

        for(AdjustedTenantObject ato: list){
            System.out.printf("%-30s %-7s %-6d %-6d %-6d %%%-7.2f %-10s %-7s %-10s\n",
                    ato.getTenant(), ato.getMeter(), ato.getCurr(), ato.getPrev(), ato.getUsage(), ato.getPercent(),
                    nf.format(Double.valueOf(String.format("%.2f", ato.getBase()))),
                    nf.format(Double.valueOf(String.format("%.2f", ato.getAdj()))),
                    nf.format(Double.valueOf(String.format("%.2f", ato.getTotal()))));
        }

        System.out.printf("\n%-40s %10.2f\n", "Total Tenant bills (metered)", mt);
        System.out.printf("%-40s %10.2f\n", "Total Tenant bills Diff", diff);
        System.out.printf("%-40s %10.2f\n", "Total Tenant bills Adjusted", at);
    }
}
