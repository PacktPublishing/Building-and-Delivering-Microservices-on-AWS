package com.packt.aws.books.pipeline;

import java.net.InetAddress;
import java.net.UnknownHostException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class WelcomeController {
	@Value("${app.name}")
	private String appName;

	@Value("${app.version}")
	private String appVersion;
	private static Logger LOGGGER=null;

	@GetMapping({ "/", "/info" })
	public String sayHello() throws UnknownHostException {
		LOGGGER =	LoggerFactory.getLogger(WelcomeController.class);
		InetAddress ip = InetAddress.getLocalHost();
		LOGGGER.info(appName+"-"+appVersion);
		return appName + "-" + appVersion+" \n "+ip;
	}
	
	@GetMapping({ "/welcome" })
	public String welcome(@RequestParam String name) {
		LOGGGER =	LoggerFactory.getLogger(WelcomeController.class);
		try {
			Thread.sleep(12000);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		LOGGGER.info("Welcome {}",name);
		return "Welcome "+name;
	}
}
