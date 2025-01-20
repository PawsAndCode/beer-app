# Makefile for building, deploying, and cleaning Lambda zips

# Define build directory and S3 bucket name
BUILD_DIR = build
S3_BUCKET = beer-app-lambda-deployments

# Default target to build all zips
build:
	@mkdir -p $(BUILD_DIR)
	@./build.sh

# Deploy Lambda zip to S3 bucket
deploy:
	@echo "Deploying zip files to S3 bucket $(S3_BUCKET)..."
	@for fn in $(BUILD_DIR)/*.zip; do \
		base_name=$$(basename $$fn .zip); \
		echo "Deploying $$base_name..."; \
		aws s3 cp $$fn s3://$(S3_BUCKET)/$(notdir $$fn); \
		aws lambda update-function-code --function-name $$base_name --s3-bucket $(S3_BUCKET) --s3-key $(notdir $$fn); \
	done

# Clean the build directory (remove the folder and its contents)
clean:
	@echo "Cleaning build directory..."
	@rm -rf $(BUILD_DIR)

.PHONY: build deploy clean
