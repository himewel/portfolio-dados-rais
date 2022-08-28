SHELL:=/bin/bash
PROJECT=caged-rais-230822
TF_BACKEND=tf-backend-270822

.PHONY: run-push
run-push:
	docker build run --tag gcr.io/${PROJECT}/ftp-to-gcs
	docker push gcr.io/${PROJECT}/ftp-to-gcs
	gcloud run deploy ftp-to-gcs \
		--region us-central1 \
		--image gcr.io/${PROJECT}/ftp-to-gcs:latest

.PHONY: tf-backend
tf-backend:
	gsutil mb gs://${TF_BACKEND}
