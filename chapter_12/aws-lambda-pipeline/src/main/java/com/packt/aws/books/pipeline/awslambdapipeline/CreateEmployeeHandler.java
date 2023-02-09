package com.packt.aws.books.pipeline.awslambdapipeline;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import java.util.logging.Logger;


public class CreateEmployeeHandler implements RequestHandler<EmployeeEntity,String>{
    private static final Logger LOGGER =Logger.getLogger("CreateEmployeeHandler");
  
    @Override
    public String handleRequest(EmployeeEntity event, Context context){   
        LOGGER.info("Received a request in your Lambda function "
        +context.getFunctionName() 
        +" with details " + event);  
        
        return "Employee is created successfully  !";
  }  
}
