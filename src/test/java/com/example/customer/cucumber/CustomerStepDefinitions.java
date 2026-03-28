package com.example.customer.cucumber;

import com.example.customer.dto.CustomerRequest;
import com.example.customer.dto.CustomerResponse;
import com.example.customer.repository.CustomerRepository;
import io.cucumber.datatable.DataTable;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.*;

import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

public class CustomerStepDefinitions extends CucumberSpringConfig {

    @Autowired
    private CustomerRepository customerRepository;

    private ResponseEntity<?> lastResponse;
    private Long lastCreatedCustomerId;

    @Given("the customer database is empty")
    public void theDatabaseIsEmpty() {
        customerRepository.deleteAll();
    }

    @Given("a customer exists with name {string} and email {string}")
    public void aCustomerExists(String name, String email) {
        CustomerRequest request = new CustomerRequest();
        request.setName(name);
        request.setEmail(email);
        request.setPhone("0912345678");
        request.setAddress("Taiwan");

        ResponseEntity<CustomerResponse> response = restTemplate.postForEntity(
                baseUrl(), request, CustomerResponse.class);
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        lastCreatedCustomerId = response.getBody().getId();
    }

    // ===== Create =====

    @When("I create a customer with the following details:")
    public void iCreateCustomer(DataTable dataTable) {
        Map<String, String> data = dataTable.asMaps().get(0);
        CustomerRequest request = buildRequest(data);

        ResponseEntity<CustomerResponse> response = restTemplate.postForEntity(
                baseUrl(), request, CustomerResponse.class);
        lastResponse = response;

        if (response.getStatusCode() == HttpStatus.CREATED && response.getBody() != null) {
            lastCreatedCustomerId = response.getBody().getId();
        }
    }

    // ===== Read =====

    @When("I request all customers")
    public void iRequestAllCustomers() {
        lastResponse = restTemplate.exchange(
                baseUrl(), HttpMethod.GET, null,
                new ParameterizedTypeReference<List<CustomerResponse>>() {});
    }

    @When("I request the customer by the last created ID")
    public void iRequestCustomerByLastId() {
        lastResponse = restTemplate.getForEntity(
                baseUrl() + "/" + lastCreatedCustomerId, CustomerResponse.class);
    }

    @When("I request the customer with ID {long}")
    public void iRequestCustomerById(Long id) {
        lastResponse = restTemplate.getForEntity(
                baseUrl() + "/" + id, String.class);
    }

    // ===== Update =====

    @When("I update the last created customer with the following details:")
    public void iUpdateLastCreatedCustomer(DataTable dataTable) {
        Map<String, String> data = dataTable.asMaps().get(0);
        CustomerRequest request = buildRequest(data);

        HttpEntity<CustomerRequest> entity = new HttpEntity<>(request);
        lastResponse = restTemplate.exchange(
                baseUrl() + "/" + lastCreatedCustomerId, HttpMethod.PUT, entity, CustomerResponse.class);
    }

    @When("I update customer with ID {long} with the following details:")
    public void iUpdateCustomerById(Long id, DataTable dataTable) {
        Map<String, String> data = dataTable.asMaps().get(0);
        CustomerRequest request = buildRequest(data);

        HttpEntity<CustomerRequest> entity = new HttpEntity<>(request);
        lastResponse = restTemplate.exchange(
                baseUrl() + "/" + id, HttpMethod.PUT, entity, String.class);
    }

    // ===== Delete =====

    @When("I delete the last created customer")
    public void iDeleteLastCreatedCustomer() {
        lastResponse = restTemplate.exchange(
                baseUrl() + "/" + lastCreatedCustomerId, HttpMethod.DELETE, null, Void.class);
    }

    @When("I delete customer with ID {long}")
    public void iDeleteCustomerById(Long id) {
        lastResponse = restTemplate.exchange(
                baseUrl() + "/" + id, HttpMethod.DELETE, null, String.class);
    }

    // ===== Assertions =====

    @Then("the response status should be {int}")
    public void theResponseStatusShouldBe(int statusCode) {
        assertThat(lastResponse.getStatusCode().value()).isEqualTo(statusCode);
    }

    @And("the response should contain customer name {string}")
    public void responseShouldContainName(String name) {
        CustomerResponse body = getCustomerResponseBody();
        assertThat(body.getName()).isEqualTo(name);
    }

    @And("the response should contain customer email {string}")
    public void responseShouldContainEmail(String email) {
        CustomerResponse body = getCustomerResponseBody();
        assertThat(body.getEmail()).isEqualTo(email);
    }

    @And("the response should contain a valid customer ID")
    public void responseShouldContainValidId() {
        CustomerResponse body = getCustomerResponseBody();
        assertThat(body.getId()).isNotNull().isPositive();
    }

    @And("the customer list should have {int} entries")
    @SuppressWarnings("unchecked")
    public void customerListShouldHaveEntries(int count) {
        List<CustomerResponse> body = (List<CustomerResponse>) lastResponse.getBody();
        assertThat(body).hasSize(count);
    }

    @And("the customer should no longer exist in the database")
    public void customerShouldNotExist() {
        assertThat(customerRepository.findById(lastCreatedCustomerId)).isEmpty();
    }

    // ===== Helpers =====

    private CustomerRequest buildRequest(Map<String, String> data) {
        CustomerRequest request = new CustomerRequest();
        request.setName(data.get("name"));
        request.setEmail(data.get("email"));
        request.setPhone(data.get("phone"));
        request.setAddress(data.get("address"));
        return request;
    }

    private CustomerResponse getCustomerResponseBody() {
        Object body = lastResponse.getBody();
        if (body instanceof CustomerResponse) {
            return (CustomerResponse) body;
        }
        // Fetch by last created ID as fallback
        return restTemplate.getForEntity(
                baseUrl() + "/" + lastCreatedCustomerId, CustomerResponse.class).getBody();
    }

}
