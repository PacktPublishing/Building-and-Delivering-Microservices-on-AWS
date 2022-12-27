package com.packt.aws.books.pipeline;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
//import software.amazon.codeguruprofilerjavaagent.Profiler;
@SpringBootApplication
public class AwsCodePipelineApplication {

	public static void main(String[] args) {
		// new Profiler.Builder() .profilingGroupName("aws-codeguru-profiling-group")
		//  .withHeapSummary(true) .build().start();
		SpringApplication.run(AwsCodePipelineApplication.class, args);
	}
}
