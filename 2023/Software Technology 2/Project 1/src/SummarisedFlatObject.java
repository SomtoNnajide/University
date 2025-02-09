public class SummarisedFlatObject {
    private String flat_address;
    private double flat_bill;
    private double diff;
    private double diff_adj;
    private double tenant_bill;
    private double metered_total;

    public SummarisedFlatObject(String flat_address, double flat_bill, double diff, double diff_adj, double tenant_bill, double metered_total) {
        this.flat_address = flat_address;
        this.flat_bill = flat_bill;
        this.diff = diff;
        this.diff_adj = diff_adj;
        this.tenant_bill = tenant_bill;
        this.metered_total = metered_total;
    }

    public String getFlat_address() {return flat_address;}

    public void setFlat_address(String flat_address) {this.flat_address = flat_address;}

    public double getFlat_bill() {return flat_bill;}

    public void setFlat_bill(double flat_bill) {this.flat_bill = flat_bill;}

    public double getDiff() {return diff;}

    public void setDiff(double diff) {this.diff = diff;}

    public double getDiff_adj() {return diff_adj;}

    public void setDiff_adj(double diff_adj) {this.diff_adj = diff_adj;}

    public double getTenant_bill() {return tenant_bill;}

    public void setTenant_bill(double tenant_bill) {this.tenant_bill = tenant_bill;}

    public double getMetered_total() {return metered_total;}

    public void setMetered_total(double metered_total) {this.metered_total = metered_total;}
}