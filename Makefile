
DOCKERFILES = $(shell find * -type f -name Dockerfile)
#IMAGES =  $(shell sed 's+/Dockerfile++g' $(DOCKERFILES))

MAJOR?=0
MINOR?=1
VERSION=$(MAJOR).$(MINOR)
APP_NAME = "rna-seq"



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


build-images-all: $(images_to_build)


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
		##wget  --limit-rate=500k -b -P data/raw/samples/ https://zenodo.org/record/4541751/files/GSM461177_1.fastqsanger
		##wget  --limit-rate=500k -b -P data/raw/samples/ https://zenodo.org/record/4541751/files/GSM461177_2.fastqsanger
		##wget  --limit-rate=500k -b -P data/raw/samples/ https://zenodo.org/record/4541751/files/GSM461180_1.fastqsanger
		##wget  --limit-rate=500k -b -P data/raw/samples/ https://zenodo.org/record/4541751/files/GSM461180_2.fastqsanger
		wget --limit-rate=500k  -bqc -O data/dataset1/raw-samples/MCL1-DL.fastqsanger.gz	https://zenodo.org/record/4249555/files/SRR1552455.fastq.gz
		wget --limit-rate=500k  -bqc -O data/dataset1/raw-samples/MCL1-DK.fastqsanger.gz	https://zenodo.org/record/4249555/files/SRR1552454.fastq.gz
		wget --limit-rate=500k  -bqc -O data/dataset1/raw-samples/MCL1-DJ.fastqsanger.gz	https://zenodo.org/record/4249555/files/SRR1552453.fastq.gz
		wget --limit-rate=500k  -bqc -O data/dataset1/raw-samples/MCL1-DI.fastqsanger.gz	https://zenodo.org/record/4249555/files/SRR1552452.fastq.gz
		wget --limit-rate=500k  -bqc -O data/dataset1/raw-samples/MCL1-DH.fastqsanger.gz	https://zenodo.org/record/4249555/files/SRR1552451.fastq.gz
		wget --limit-rate=500k  -bqc -O data/dataset1/raw-samples/MCL1-DG.fastqsanger.gz	https://zenodo.org/record/4249555/files/SRR1552450.fastq.gz
		wget --limit-rate=500k  -bqc -O data/dataset1/raw-samples/MCL1-LF.fastqsanger.gz	https://zenodo.org/record/4249555/files/SRR1552449.fastq.gz
		wget --limit-rate=500k  -bqc -O data/dataset1/raw-samples/MCL1-LE.fastqsanger.gz	https://zenodo.org/record/4249555/files/SRR1552448.fastq.gz
		wget --limit-rate=500k  -bqc -O data/dataset1/raw-samples/MCL1-LD.fastqsanger.gz	https://zenodo.org/record/4249555/files/SRR1552447.fastq.gz
		wget --limit-rate=500k  -bqc -O data/dataset1/raw-samples/MCL1-LC.fastqsanger.gz	https://zenodo.org/record/4249555/files/SRR1552446.fastq.gz
		wget --limit-rate=500k  -bqc -O data/dataset1/raw-samples/MCL1-LB.fastqsanger.gz	https://zenodo.org/record/4249555/files/SRR1552445.fastq.gz
		wget --limit-rate=500k  -bqc -O data/dataset1/raw-samples/MCL1-LA.fastqsanger.gz	https://zenodo.org/record/4249555/files/SRR1552444.fastq.gz


download-ref-gen-files:
		mkdir  -p ./data/dataset1/ref-gene/hisat2-index-GRCm39
		##wget --limit-rate=1000k  -bqc -P data/dataset1/ref-gene https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/635/GCF_000001635.27_GRCm39/GCF_000001635.27_GRCm39_genomic.fna.gz
		curl -OJX GET "https://api.ncbi.nlm.nih.gov/datasets/v2alpha/genome/accession/GCF_000001635.27/download?include_annotation_type=GENOME_FASTA,GENOME_GFF,RNA_FASTA,CDS_FASTA,PROT_FASTA,SEQUENCE_REPORT&filename=GCF_000001635.27.zip" -H "Accept: application/zip"
		mv GCF_000001635.27.zip  ./data/
		unzip -j ./data/GCF_000001635.27.zip ncbi_dataset/data/GCF_000001635.27/GCF_000001635.27_GRCm39_genomic.fna ncbi_dataset/data/GCF_000001635.27/genomic.gff -d ./data/dataset1/ref-gene

duild-hisat2-ref-gene-index:
		docker run --rm -v ./data/dataset1/:/data  app-bio/hisat2 hisat2-build -p 6  -f /data/ref-gene/GCF_000001635.27_GRCm39_genomic.fna  /data/ref-gene/hisat2-index-GRCm39/GRCm39


create-pipeline-folder-structure:
		mkdir  -p ./data/dataset1/raw-samples
		mkdir  -p ./data/dataset1/pipeline/01fastqc
		mkdir  -p ./data/dataset1/pipeline/02multiqc
		mkdir  -p ./data/dataset1/pipeline/03trimmomatic
		mkdir  -p ./data/dataset1/pipeline/04hisat2
		mkdir  -p ./data/dataset1/pipeline/05geneCount

clean-pipeline-run-data:
		rm -f ./data/dataset1/pipeline/01fastqc/* 
		rm -f ./data/dataset1/pipeline/02multiqc/* 
		rm -f ./data/dataset1/pipeline/03trimmomatic/* 
		rm -f ./data/dataset1/pipeline/04hisat2/*
		rm  -f ./data/dataset1/pipeline/05geneCount/*


run-pipeline-e2e:
		snakemake -s pipelines/RNASeqBasic01  --cores 4  -R geneCount_all

run-pipeline-e2e-np:
		snakemake -s pipelines/RNASeqBasic01  -np  -R geneCount_all