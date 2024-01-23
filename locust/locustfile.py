from locust import HttpUser, task, between

class APIUser(HttpUser):
    wait_time = between(1, 5)

    @task
    def perform_request(self):
        self.client.get("http://backend-service:8080")
