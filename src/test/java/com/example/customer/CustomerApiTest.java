package com.example.customer;

import com.example.customer.dto.CustomerRequest;
import com.example.customer.dto.CustomerResponse;
import com.example.customer.repository.CustomerRepository;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.*;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class CustomerApiTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private CustomerRepository customerRepository;

    @LocalServerPort
    private int port;

    private String baseUrl() {
        return "http://localhost:" + port + "/api/customers";
    }

    @BeforeEach
    void setUp() {
        customerRepository.deleteAll();
    }

    @Test
    @Order(1)
    void shouldCreateCustomer() {
        CustomerRequest request = new CustomerRequest();
        request.setName("John Doe");
        request.setEmail("john@example.com");
        request.setPhone("0912345678");
        request.setAddress("Taipei, Taiwan");

        ResponseEntity<CustomerResponse> response = restTemplate.postForEntity(
                baseUrl(), request, CustomerResponse.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getName()).isEqualTo("John Doe");
        assertThat(response.getBody().getEmail()).isEqualTo("john@example.com");
        assertThat(response.getBody().getId()).isNotNull();
    }

    @Test
    @Order(2)
    void shouldGetAllCustomers() {
        createTestCustomer("Alice", "alice@example.com");
        createTestCustomer("Bob", "bob@example.com");

        ResponseEntity<List<CustomerResponse>> response = restTemplate.exchange(
                baseUrl(), HttpMethod.GET, null,
                new ParameterizedTypeReference<>() {});

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).hasSize(2);
    }

    @Test
    @Order(3)
    void shouldGetCustomerById() {
        CustomerResponse created = createTestCustomer("Charlie", "charlie@example.com");

        ResponseEntity<CustomerResponse> response = restTemplate.getForEntity(
                baseUrl() + "/" + created.getId(), CustomerResponse.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody().getName()).isEqualTo("Charlie");
    }

    @Test
    @Order(4)
    void shouldUpdateCustomer() {
        CustomerResponse created = createTestCustomer("Dave", "dave@example.com");

        CustomerRequest updateRequest = new CustomerRequest();
        updateRequest.setName("Dave Updated");
        updateRequest.setEmail("dave.updated@example.com");
        updateRequest.setPhone("0987654321");
        updateRequest.setAddress("Kaohsiung, Taiwan");

        HttpEntity<CustomerRequest> entity = new HttpEntity<>(updateRequest);
        ResponseEntity<CustomerResponse> response = restTemplate.exchange(
                baseUrl() + "/" + created.getId(), HttpMethod.PUT, entity, CustomerResponse.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody().getName()).isEqualTo("Dave Updated");
        assertThat(response.getBody().getEmail()).isEqualTo("dave.updated@example.com");
    }

    @Test
    @Order(5)
    void shouldDeleteCustomer() {
        CustomerResponse created = createTestCustomer("Eve", "eve@example.com");

        ResponseEntity<Void> response = restTemplate.exchange(
                baseUrl() + "/" + created.getId(), HttpMethod.DELETE, null, Void.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.NO_CONTENT);
        assertThat(customerRepository.findById(created.getId())).isEmpty();
    }

    @Test
    @Order(6)
    void shouldRejectInvalidEmail() {
        CustomerRequest request = new CustomerRequest();
        request.setName("Invalid");
        request.setEmail("not-an-email");

        ResponseEntity<String> response = restTemplate.postForEntity(
                baseUrl(), request, String.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
    }

    @Test
    @Order(7)
    void shouldRejectDuplicateEmail() {
        createTestCustomer("First", "duplicate@example.com");

        CustomerRequest request = new CustomerRequest();
        request.setName("Second");
        request.setEmail("duplicate@example.com");
        request.setPhone("0911111111");

        ResponseEntity<String> response = restTemplate.postForEntity(
                baseUrl(), request, String.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
    }

    private CustomerResponse createTestCustomer(String name, String email) {
        CustomerRequest request = new CustomerRequest();
        request.setName(name);
        request.setEmail(email);
        request.setPhone("0912345678");
        request.setAddress("Taiwan");
        ResponseEntity<CustomerResponse> response = restTemplate.postForEntity(
                baseUrl(), request, CustomerResponse.class);
        return response.getBody();
    }
}
