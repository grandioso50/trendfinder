package com.highlow;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication
@EnableAsync
public class AutomataApplication {

	public static void main(String[] args) {
		SpringApplication.run(AutomataApplication.class, args);
	}

}
