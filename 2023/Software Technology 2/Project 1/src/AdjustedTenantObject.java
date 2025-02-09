public class AdjustedTenantObject {
    private String tenant, meter;
    private int curr, prev, usage;
    private double base;
    private double percent;
    private double adj;
    private double total;

    public AdjustedTenantObject(String tenant,
                                String meter,
                                int curr,
                                int prev,
                                int usage,
                                double base,
                                double percent,
                                double adj,
                                double total)
    {
        this.tenant = tenant;
        this.meter = meter;
        this.curr = curr;
        this.prev = prev;
        this.usage = usage;
        this.base = base;
        this.percent = percent;
        this.adj = adj;
        this.total = total;
    }

    public String getTenant() {
        return tenant;
    }

    public void setTenant(String tenant) {
        this.tenant = tenant;
    }

    public String getMeter() {
        return meter;
    }

    public void setMeter(String meter) {
        this.meter = meter;
    }

    public int getCurr() {
        return curr;
    }

    public void setCurr(int curr) {
        this.curr = curr;
    }

    public int getPrev() {
        return prev;
    }

    public void setPrev(int prev) {
        this.prev = prev;
    }

    public int getUsage() {
        return usage;
    }

    public void setUsage(int usage) {
        this.usage = usage;
    }

    public double getBase() {
        return base;
    }

    public void setBase(double base) {
        this.base = base;
    }

    public double getPercent() {
        return percent;
    }

    public void setPercent(double percent) {
        this.percent = percent;
    }

    public double getAdj() {
        return adj;
    }

    public void setAdj(double adj) {
        this.adj = adj;
    }

    public double getTotal() {
        return total;
    }

    public void setTotal(double total) {
        this.total = total;
    }
}
