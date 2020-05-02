package com.highlow;

import org.openqa.selenium.By;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;

import com.codeborne.selenide.Configuration;
import com.codeborne.selenide.Selenide;
import com.codeborne.selenide.SelenideElement;
import com.codeborne.selenide.WebDriverRunner;
import com.highlow.Entity.BidRequest;

@Component
public class BidWorker {
	@Value("${settings.id}") 
	private String id;
	@Value("${settings.pass}") 
	private String pass;
	@Value("${settings.price}") 
	private Integer price;
	@Value("${settings.trial}") 
	private Integer trial;

	@Async
	public void start(BidRequest bid) throws Exception {
	    Configuration.browser = WebDriverRunner.CHROME;
	    if (this.isMac()) {
	        System.setProperty("webdriver.chrome.driver", "./lib/chromedriver");
	    }else {
	        System.setProperty("webdriver.chrome.driver", "./lib/chromedriver.exe");
	    }
        Selenide.open("https://trade.highlow.com/");
        String highorlow = bid.getIsHigh() ? "HIGH" : "LOW";
        
        //production
        /*
        SelenideElement login = Selenide.$(By.xpath("//i[./text() = 'ログイン']"));
        login.click();
        
        Selenide.$("#login-username").val(this.id);
        Selenide.$("#login-password").val(this.pass);
        
        SelenideElement loginBtn = Selenide.$(By.xpath("//button"));
        loginBtn.click();
        */
        
        //demo
        SelenideElement login = Selenide.$(By.xpath("//i[./text() = 'クイックデモ']"));
        login.click();
        //end demo
        
        SelenideElement turbo = Selenide.$(By.xpath("//span[./text() = 'Turbo']"));
        if (!turbo.exists()) {
            System.out.println("failed to login");
            System.clearProperty("progress");
            Selenide.close();
            return;
        }
        turbo.click();


        SelenideElement onemin = Selenide.$(By.cssSelector("#assetsCategoryFilterZoneRegion div:nth-child(3)"));
        onemin.click();
        
        //demo
        SelenideElement demo = Selenide.$(By.xpath("//a[./text() = '取引を始める。']"));
        demo.click(); 
        //enddemo

        if (bid.getPair().equals("AUDJPY")) {
            SelenideElement pair = Selenide.$(By.xpath("//div[./text() = 'AUD/JPY']"));
            pair.click();
        }else if(bid.getPair().equals("AUDUSD")) {
            SelenideElement rtbtn = Selenide.$(By.cssSelector("#rightButton"));
            rtbtn.click();
            SelenideElement pair = Selenide.$(By.xpath("//div[./text() = 'AUD/USD']"));
            pair.click();
        }else if(bid.getPair().equals("EURJPY")) {
            SelenideElement pair = Selenide.$(By.xpath("//div[./text() = 'EUR/JPY']"));
            pair.click();
        }else if(bid.getPair().equals("EURUSD")) {
            SelenideElement pair = Selenide.$(By.xpath("//div[./text() = 'EUR/USD']"));
            pair.click();
        }else if(bid.getPair().equals("GBPJPY")) {
            SelenideElement pair = Selenide.$(By.xpath("//div[./text() = 'GBP/JPY']"));
            pair.click();
        }else if(bid.getPair().equals("NZDJPY")) {
            SelenideElement rtbtn = Selenide.$(By.cssSelector("#rightButton"));
            rtbtn.click();
            SelenideElement pair = Selenide.$(By.xpath("//div[./text() = 'NZD/JPY']"));
            pair.click();
        }else if(bid.getPair().equals("USDJPY")) {
            SelenideElement pair = Selenide.$(By.xpath("//div[./text() = 'USD/JPY']"));
            pair.click();
        }else {
            Selenide.close();
            return;
        }
        
        Selenide.$("#amount").val(this.price.toString());
        if (bid.getIsHigh()) {
            SelenideElement dir = Selenide.$(By.cssSelector("#up_button"));
            dir.click();
        }else {
            SelenideElement dir = Selenide.$(By.cssSelector("#down_button"));
            dir.click();
        }
        
        SelenideElement hit = Selenide.$(By.xpath("//a[./text() = '今すぐ購入']"));
        hit.click(); 
        
        System.out.println("trial=1 bid for "+highorlow+" bet="+this.price.toString());
        //wait
        Thread.sleep(60000);
        SelenideElement result = Selenide.$(By.cssSelector("#tradeActionsTableBody tr:nth-child(1)"));
        if (!result.exists()) {
            System.out.println("contract fail");
            System.clearProperty("progress");
            Selenide.close();
            return;
        }
        if (result.getAttribute("class").contains("investment-winning")) {
            System.out.println("won");
        }else {
            System.out.println("lost");
            this.recover();
        }
        System.clearProperty("progress");
        Selenide.close();
	}
	
	private void recover() {
	    Integer bet = this.price * 2;
	    SelenideElement bid;
	    SelenideElement result;
        for (int i = 0; i < this.trial; i++) {
            Selenide.$("#amount").val(bet.toString());
            bid = Selenide.$(By.xpath("//a[./text() = '今すぐ購入']"));
            bid.click();
            System.out.println("trial="+(i + 2)+"  bet="+bet.toString());
            if (this.hitTilSuccess()) {
                try {
                    Thread.sleep(60000);
                } catch (InterruptedException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
                result = Selenide.$(By.cssSelector("#tradeActionsTableBody tr:nth-child(1)"));
                if (result.getAttribute("class").contains("investment-winning")) {
                    System.out.println("won");
                    return;
                }else {
                    System.out.println("lost");
                    bet = bet * 3;
                } 
            }
        }
	    System.out.println("all lost");
	}
	
	public boolean hitTilSuccess() {
	    SelenideElement result = Selenide.$(By.cssSelector("#tradeActionsTableBody tr:nth-child(1)"));
	    SelenideElement status = result.$("td:nth-child(6)");
	    if (status.exists() && status.getText().equals("取引中")) {
	        System.out.println("contract success");
	        return true;
	    }else {
            System.out.println("contract fail");
	        SelenideElement bid = Selenide.$(By.xpath("//a[./text() = '今すぐ購入']"));
            bid.click(); 
	        return this.hitTilSuccess();
	    }
	}
	
	public boolean isMac() {
	    String os = System.getProperty("os.name");
	    String mac = "Mac";
	    if (os.toLowerCase().indexOf(mac.toLowerCase()) != -1) return true;
	    return false;
	}
}
