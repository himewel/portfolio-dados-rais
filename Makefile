SHELL:=/bin/bash
PROJECT=caged-rais-230822
TF_BACKEND=tf-backend-270822

.PHONY: ftp-push
ftp-push:
	docker build run/ftp-to-gcs --tag gcr.io/${PROJECT}/ftp-to-gcs
	docker push gcr.io/${PROJECT}/ftp-to-gcs
	gcloud run deploy ftp-to-gcs \
		--region us-central1 \
		--image gcr.io/${PROJECT}/ftp-to-gcs:latest

.PHONY: 7z-push
7z-push:
	docker build run/unzip --tag gcr.io/${PROJECT}/unzip
	docker push gcr.io/${PROJECT}/unzip
	gcloud run deploy unzip \
		--region us-central1 \
		--image gcr.io/${PROJECT}/unzip:latest

.PHONY: tf-backend
tf-backend:
	gsutil mb -l us-central1 gs://${TF_BACKEND}
