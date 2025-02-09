import java.util.ArrayList;
import java.util.Random;

public class QuickSort {
    private String file;
    public QuickSort(String file){this.file = file;}

    public void setFile(String file) {this.file = file;}

    public String getFile() {return file;}

    public int[] callQuickSort(){
        MeterFile mf = new MeterFile(file);
        int filelength = mf.getFileLength();

        ArrayList<TenantObject> meterlist = mf.readTenantObjectIntoArrayList();
        int[] meterarr = readObjMeterIntoArray(meterlist, filelength);

        quickSort(meterarr);

        TenantObject[] sortedobjarr = sortObjects(meterlist, meterarr, filelength);

        showSort(sortedobjarr);

        return meterarr;
    }

    private void quickSort(int[] arr){
        quickSort(arr, 0, arr.length - 1);
    }

    private void quickSort(int[]arr, int li, int hi){
        if(li >= hi){
            return;
        }

        //choose pivot
        int pi = new Random().nextInt(hi - li) + li;
        int pivot = arr[pi];
        swap(arr, pi, hi);

        //partition
        int lp = partition(arr, li, hi, pivot);

        //recursively quicksort sub arrays
        quickSort(arr, li, lp - 1);
        quickSort(arr, lp + 1, hi);
    }

    private int partition(int[] arr, int li, int hi, int pivot) {
        int lp = li;
        int rp = hi;

        while(lp < rp){
            while (arr[lp] <= pivot && lp < rp){
                lp++;
            }

            while(arr[rp] >= pivot && lp < rp){
                rp--;
            }

            swap(arr, lp, rp);
        }

        swap(arr, lp, hi);
        return lp;
    }

    private void swap(int[] arr, int index1, int index2){
        int temp = arr[index1];
        arr[index1] = arr[index2];
        arr[index2] = temp;
    }

    public int[] readObjMeterIntoArray(ArrayList<TenantObject> list, int length){
        int index = 0;
        int[] meterarr = new int[length];

        while(index < length){
            for(TenantObject obj: list){
                meterarr[index] = Integer.parseInt(obj.getMeternumber().substring(1));
                index++;
            }
        }
        return meterarr;
    }

    private TenantObject[] sortObjects(ArrayList<TenantObject> list, int[] arr, int length){
        int index = 0;
        TenantObject[] sortedobjs = new TenantObject[length];

        while(index < length){
            for (int j : arr) {
                for (TenantObject obj : list) {
                    if (j == Integer.parseInt(obj.getMeternumber().substring(1))) {
                        sortedobjs[index] = obj;
                        index++;
                    }
                }
            }
        }

        return sortedobjs;
    }

    private void showSort(TenantObject[] arr){
        System.out.printf("%-11s %-15s %-15s %-7s %-7d\n", "Check [0]", arr[0].getFname(), arr[0].getLname(), arr[0].getMeternumber(), arr[0].getCurrent_meter_reading());
        System.out.printf("%-11s %-15s %-15s %-7s %-7d\n", "Check [9]", arr[9].getFname(), arr[9].getLname(), arr[9].getMeternumber(), arr[9].getCurrent_meter_reading());
        System.out.printf("%-11s %-15s %-15s %-7s %-7d\n", "Last [ ]", arr[arr.length-1].getFname(), arr[arr.length-1].getLname(), arr[arr.length-1].getMeternumber(), arr[arr.length-1].getCurrent_meter_reading());
    }
}
