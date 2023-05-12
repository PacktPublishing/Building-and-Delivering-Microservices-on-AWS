package com.packt.aws.books.pipeline;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class WelcomeController {

    @Value("${app.name}")
    private String appName;

    @Value("${app.version}")
    private String appVersion;

    @GetMapping({ "/", "/info" })
    public String sayHello() {
        return appName + "-" + appVersion;
    }
}