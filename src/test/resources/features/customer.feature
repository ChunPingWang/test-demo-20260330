Feature: Customer Management API
  As an API consumer
  I want to manage customer data through RESTful endpoints
  So that I can perform CRUD operations on customers

  Background:
    Given the customer database is empty

  # ===== Create =====

  Scenario: Successfully create a new customer
    When I create a customer with the following details:
      | name     | email             | phone      | address         |
      | John Doe | john@example.com  | 0912345678 | Taipei, Taiwan  |
    Then the response status should be 201
    And the response should contain customer name "John Doe"
    And the response should contain customer email "john@example.com"
    And the response should contain a valid customer ID

  Scenario: Create a customer with only required fields
    When I create a customer with the following details:
      | name      | email              |
      | Jane Doe  | jane@example.com   |
    Then the response status should be 201
    And the response should contain customer name "Jane Doe"

  Scenario: Fail to create a customer with invalid email
    When I create a customer with the following details:
      | name    | email        |
      | Invalid | not-an-email |
    Then the response status should be 400

  Scenario: Fail to create a customer without name
    When I create a customer with the following details:
      | email            |
      | noname@test.com  |
    Then the response status should be 400

  Scenario: Fail to create a customer with duplicate email
    Given a customer exists with name "First" and email "dup@example.com"
    When I create a customer with the following details:
      | name   | email           |
      | Second | dup@example.com |
    Then the response status should be 400

  # ===== Read =====

  Scenario: Get all customers when none exist
    When I request all customers
    Then the response status should be 200
    And the customer list should have 0 entries

  Scenario: Get all customers
    Given a customer exists with name "Alice" and email "alice@example.com"
    And a customer exists with name "Bob" and email "bob@example.com"
    When I request all customers
    Then the response status should be 200
    And the customer list should have 2 entries

  Scenario: Get a customer by ID
    Given a customer exists with name "Charlie" and email "charlie@example.com"
    When I request the customer by the last created ID
    Then the response status should be 200
    And the response should contain customer name "Charlie"
    And the response should contain customer email "charlie@example.com"

  Scenario: Get a non-existent customer
    When I request the customer with ID 99999
    Then the response status should be 400

  # ===== Update =====

  Scenario: Successfully update a customer
    Given a customer exists with name "Dave" and email "dave@example.com"
    When I update the last created customer with the following details:
      | name         | email                    | phone      | address            |
      | Dave Updated | dave.updated@example.com | 0987654321 | Kaohsiung, Taiwan  |
    Then the response status should be 200
    And the response should contain customer name "Dave Updated"
    And the response should contain customer email "dave.updated@example.com"

  Scenario: Update a non-existent customer
    When I update customer with ID 99999 with the following details:
      | name    | email          |
      | Nobody  | no@example.com |
    Then the response status should be 400

  Scenario: Fail to update a customer with duplicate email
    Given a customer exists with name "Eve" and email "eve@example.com"
    And a customer exists with name "Frank" and email "frank@example.com"
    When I update the last created customer with the following details:
      | name  | email           |
      | Frank | eve@example.com |
    Then the response status should be 400

  # ===== Delete =====

  Scenario: Successfully delete a customer
    Given a customer exists with name "Grace" and email "grace@example.com"
    When I delete the last created customer
    Then the response status should be 204
    And the customer should no longer exist in the database

  Scenario: Delete a non-existent customer
    When I delete customer with ID 99999
    Then the response status should be 400
