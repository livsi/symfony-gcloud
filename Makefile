include .env

create_cluster:
	gcloud container clusters create $(CLUSTER_NAME) --zone=$(ZONE) --num-nodes=3
.PHONY: create_cluster

delete_cluster:
	gcloud container clusters delete $(CLUSTER_NAME)
.PHONY: delete_cluster


