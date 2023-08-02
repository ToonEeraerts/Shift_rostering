import java.io.*;
import java.util.Scanner;

public class Main {
    public static void main(String[] args) throws IOException {
        Scanner sc = new Scanner(System.in);

        // Curtois
        CurtoisConvertor c = new CurtoisConvertor();
        c.convertDataset(1);
        c.convertOutput();

        // NPSLib
        NSPLibConvertor n = new NSPLibConvertor();
        n.convertCoreDatasets();

        int[] caseset1 = {1,3,5,7};
        int[] caseset2 = {2,4,6,8};
        int[] caseset3 = {9,11,13,15};
        int[] caseset4 = {10,12,14,16};

        for(int j = 1; j <= 4; j++){
            n.convertExtendedDataset(25, j*25, caseset1[j-1]);
            n.convertExtendedDataset(75, j*75, caseset1[j-1]);
        }

        for(int j = 1; j <= 4; j++){
            n.convertExtendedDataset(50, j*50, caseset2[j-1]);
            n.convertExtendedDataset(100, j*100, caseset2[j-1]);
        }

        for(int j = 1; j <= 4; j++){
            n.convertExtendedDataset(30, j*30, caseset3[j-1]);
        }

        for(int j = 1; j <= 4; j++){
            n.convertExtendedDataset(60, j*60, caseset4[j-1]);
        }
    }
}
