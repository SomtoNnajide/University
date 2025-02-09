import java.util.Arrays;
import java.util.Scanner;

public class Main {
    private String meterfile = "";
    private String flatfile = "";
    public Main(){}

    public static void main(String[] args){
        Main m = new Main();
        m.menu();
    }

    public void menu(){
        String menuoption;
        Scanner in = new Scanner(System.in);

        do{
            System.out.println("\nST2-2023 Assignment 1");
            System.out.printf("Meter file has been set to: %s\n", meterfile);
            System.out.printf("Flat file has been set to: %s\n", flatfile);

            options();

            System.out.println("Select Option: ");

            menuoption = in.nextLine();

            if(menuoption.compareToIgnoreCase("F") == 0){
                FlatFile ff = new FlatFile(flatfile);
                ff.printFlatRead();
            }
            if(menuoption.compareToIgnoreCase("M") == 0){
                MeterFile mf = new MeterFile(meterfile);
                mf.printMeterRead();
            }
            if(menuoption.compareToIgnoreCase("C") == 0){
                FlatFile ff = new FlatFile(flatfile);
                System.out.println("Compute bill for one Block of flats");
                ff.billForOneFlat();
            }
            if(menuoption.compareToIgnoreCase("A") == 0){
                FlatFile ff = new FlatFile(flatfile);
                ff.billForAllFlats();
            }
            if(menuoption.compareToIgnoreCase("S") == 0){
                QuickSort qs = new QuickSort(meterfile);
                qs.callQuickSort();
            }
            if(menuoption.compareToIgnoreCase("P") == 0){
                ProveSort ps = new ProveSort(meterfile);
                ps.proveSort();
            }
            if(menuoption.compareToIgnoreCase("O") == 0){
                SearchAndCompute sc = new SearchAndCompute(meterfile, flatfile);
                sc.searchAndCompute();
            }
            if(menuoption.compareToIgnoreCase("5") == 0){
                ComputeAndSummarise cs = new ComputeAndSummarise(meterfile, flatfile);
                cs.computeAndSummarise();
            }
            if(menuoption.compareToIgnoreCase("0") == 0){
                meterfile = "Data/Dev0_Meter.txt";
                flatfile = "Data/Dev0_Flat.txt";
            }
            if(menuoption.compareToIgnoreCase("1") == 0){
                meterfile = "Data/Dev1_Meter.txt";
                flatfile = "Data/Dev1_Flat.txt";
            }
            if(menuoption.compareToIgnoreCase("2") == 0){
                meterfile = "Data/test_Meter.txt";
                flatfile = "Data/test_Flat.txt";
            }
            if(menuoption.compareToIgnoreCase("3") == 0){
                meterfile = "Data/prod_Meter.txt";
                flatfile = "Data/prod_Flat.txt";
            }
        }
        while(menuoption.compareToIgnoreCase("E") != 0); //exit menu

        System.out.println("Exiting now");
    }

    public void options(){
        System.out.println("E - Exit");
        System.out.println("F - Read Flats (Task 1)");
        System.out.println("M - Read Meters (Task 1)");
        System.out.println("C - Compute BC Bill for one Flat (Task 2)");
        System.out.println("A - Compute BC Bill for all Flats (Task 2)");
        System.out.println("S - Sort the meter file into meter order (Task 3)");
        System.out.println("P - Prove meter file sort and find (Task 3)");
        System.out.println("O - Compute Full Bill For One Flat (Task4)");
        System.out.println("5 - Compute Full Bill For All Flats (Task5)");
        System.out.println("0 - Set Dev0 environment");
        System.out.println("1 - Set Dev1 environment");
        System.out.println("2 - Set Test environment");
        System.out.println("3 - Set Prod environment");
    }
}

