
DOCKERFILES = $(shell find * -type f -name Dockerfile)
#IMAGES =  $(shell sed 's+/Dockerfile++g' $(DOCKERFILES))

MAJOR?=0
MINOR?=1
VERSION=$(MAJOR).$(MINOR)
APP_NAME = "rna-seq



repository ?= app-bio
images = base base-java fastqc base-python multiqc trimmomatic hisat2 samtools subread




.PHONY: shell help build rebuild service login test clean prune


all: $(images)

help:
	@echo ''
	@echo 'Usage: make [Target] [Extra_Arguments]'


#$(echo images | sed 's+build-image-++g'): %:
#	echo "target: " $@
#	docker build -f  $(shell   echo $@ | sed 's+build-image-++g' )/Dockerfile $(shell echo $@ | sed 's+build-image-++g' )

######################### Build Images Section #############################
images_to_build = $(shell  echo $(images) | sed 's/[^ ]* */build-image-&/g')

.PHONY: $(images_to_build)
$(images_to_build): build-image-%: clean-image-%
	@echo "target: " $@
	@echo "context: " ./containers/$(shell   echo $@ | sed 's+build-image-++g' )/Dockerfile
	@docker build \
	-t $(repository)/$(shell   echo $@ | sed 's+build-image-++g'):$(VERSION) \
	-f  ./containers/$(shell   echo $@ | sed 's+build-image-++g' )/Dockerfile \
	./containers/$(shell echo $@ | sed 's+build-image-++g' )
	@docker tag ${repository}/$(shell   echo $@ | sed 's+build-image-++g'):$(VERSION) \
	${repository}/$(shell   echo $@ | sed 's+build-image-++g' ):latest
	@echo 'Done.'
	@docker images --format '{{.Repository}}:{{.Tag}}\t\t Built: {{.CreatedSince}}\t\tSize: {{.Size}}' | \
	grep ${IMAGE_NAME}:${VERSION}


######################### Build Images Section No Cache #############################
images_to_rebuild = $(shell  echo $(images) | sed 's/[^ ]* */rebuild-image-&/g')
images_to_clean = $(shell  echo $(images) | sed 's/[^ ]* */clean-image-&/g')

.PHONY: $(images_to_rebuild)
$(images_to_rebuild): %:
	@echo "target: " $@
	@docker build --no-cache \
	-f  containers/$(shell   echo $@ | sed 's+rebuild-image-++g' )/Dockerfile \
	$(shell echo $@ | sed 's+rebuild-image-++g' )


.PHONY: $(images_to_clean)
$(images_to_clean): %:
	@echo "target: " $@
	@docker rmi $(repository)/$(shell   echo $@ | sed 's+clean-image-++g'):latest  || true



download-samples-raw:
		wget  --limit-rate=500k -b -P data/raw/samples/ https://zenodo.org/record/4541751/files/GSM461177_1.fastqsanger
		wget  --limit-rate=500k -b -P data/raw/samples/ https://zenodo.org/record/4541751/files/GSM461177_2.fastqsanger
		wget  --limit-rate=500k -b -P data/raw/samples/ https://zenodo.org/record/4541751/files/GSM461180_1.fastqsanger
		wget  --limit-rate=500k -b -P data/raw/samples/ https://zenodo.org/record/4541751/files/GSM461180_2.fastqsanger


duild-hisat2-ref-gene-index:
		docker run --rm -v ./data/dataset1/:/data  app-bio/hisat2 hisat2-build -p 6  -f /data/ref-gene/GCF_000001635.27_GRCm39_genomic.fna  /data/ref-gene/hisat2-index-GRCm39/GRCm39