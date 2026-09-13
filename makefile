.PHONY: help fmt init plan apply destroy all

TF := terraform

help:
	@echo "Available targets:"
	@echo "  make fmt      - Format Terraform files recursively"
	@echo "  make init     - Initialize Terraform"
	@echo "  make plan     - Generate Terraform execution plan"
	@echo "  make apply    - Apply Terraform changes"
	@echo "  make destroy  - Destroy Terraform resources"
	@echo "  make all      - Run fmt, init, plan, and apply"

fmt:
	@echo "Running terraform fmt..."
	$(TF) fmt --recursive

init:
	@echo "Initializing Terraform..."
	$(TF) init

plan: init
	@echo "Generating Terraform plan..."
	$(TF) plan -out=tfplan -lock=false

apply: plan
	@echo "Applying Terraform changes..."
	$(TF) apply -auto-approve -lock=false tfplan

destroy:
	@echo "Destroying Terraform resources..."
	$(TF) destroy -auto-approve -lock=false

all: fmt apply