import java.util.Random;

public class ProveSort {
    private String file;

    public ProveSort(String file){this.file = file;}

    public void setFile(String file) {this.file = file;}

    public String getFile() {return file;}

    public void proveSort(){
        long start;
        long end;
        long diff;
        int ans, t1, t2, t3;

        QuickSort qs = new QuickSort(file);
        Search s = new Search();

        int[] arr = qs.callQuickSort();

        //pick 3 random numbers from sorted array for testing
        t1 = new Random().nextInt(arr.length);
        t2 = new Random().nextInt(arr.length);
        t3 = new Random().nextInt(arr.length);

        //test sequential search
        start = System.currentTimeMillis();
        for(int i = 0; i < 10000; i++){
            ans = s.sequentialSearch(arr, arr[t1]);
            ans = s.sequentialSearch(arr, arr[t2]);
            ans = s.sequentialSearch(arr,  arr[t3]);
        }
        end = System.currentTimeMillis();
        diff = end - start;

        System.out.println("\nSequential Search: " + " " + diff + " " + "milliseconds");

        //test binary search
        start = System.currentTimeMillis();
        for(int i = 0; i < 10000; i++){
            ans = s.binarySearch(arr, arr[t1]);
            ans = s.binarySearch(arr, arr[t2]);
            ans = s.binarySearch(arr,  arr[t3]);
        }
        end = System.currentTimeMillis();
        diff = end - start;

        System.out.println("Binary Search: " + " " + diff + " " + "milliseconds\n");
    }
}
