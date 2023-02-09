package com.packt.aws.books.pipeline.awslambdapipeline;
/**
 * Employee entity class for employee data.
 */
public class EmployeeEntity {
    private String employeeName;
    private String department;
    private String managerName;

    public String getEmployeeName() {
        return employeeName;
    }
    public void setEmployeeName(String employeeName) {
        this.employeeName = employeeName;
    }
    public String getDepartment() {
        return department;
    }
    public void setDepartment(String department) {
        this.department = department;
    }
    public String getManagerName() {
        return managerName;
    }
    public void setManagerName(String managerName) {
        this.managerName = managerName;
    }
    @Override
    public String toString() {
        return "EmployeeEntity [employeeName=" + employeeName +
         ", department=" + department + ", managerName="    + managerName + "]";
    }
}
