package com.highlow.Service;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.PrintStream;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;

import com.highlow.Entity.BidRequest;

import com.highlow.WebTestPrintStream;
import com.highlow.BidWorker;


@Service
@Component
public class BidService {
    
    @Value("${settings.logpath}") 
    private String logpath;

    @Autowired
    private BidWorker worker;

    public void execute(BidRequest bid) throws Exception {
        try {
            Date date1 = new Date();
            SimpleDateFormat d1 
            = new SimpleDateFormat("yyyy-MM-dd");
            String s1 = d1.format(date1);
            FileOutputStream fos = new FileOutputStream(this.logpath+s1+"-automata.log",true);
            PrintStream out = new WebTestPrintStream(fos);
            //replace file save path
            System.setOut(out);
        } catch (FileNotFoundException e) {
            e.getStackTrace();
        }
        String status = System.getProperty("progress");
        if (status != null) {
            System.out.println("already bidding in progress pair="+bid.getPair());
            return;
        }
        System.setProperty("progress", bid.getPair());
        System.out.println("bidding on "+bid.getPair()+" initiates.");

        //create thread
        worker.start(bid);
    }
}