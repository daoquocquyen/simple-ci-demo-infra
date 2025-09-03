 # Start the infra
 docker compose up --build

 # Manually go to Jenkins to approve the permission needed for seed-job
 1. Open your web browser and go to `http://localhost:8080`
 2. Log in with the credentials you set in the `docker-compose.yml` file
 3. Go to "Manage Jenkins" > "In-process Script Approval"
 4. Approve the script for the seed-job
